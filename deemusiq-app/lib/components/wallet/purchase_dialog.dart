import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:shadcn_flutter/shadcn_flutter_extension.dart';
import 'package:deemusiq/collections/deemusiq_icons.dart';
import 'package:deemusiq/components/wallet/wallet_common.dart';
import 'package:deemusiq/models/wallet/payment_method.dart';
import 'package:deemusiq/models/wallet/token_pack.dart';
import 'package:deemusiq/provider/wallet/region_provider.dart';
import 'package:deemusiq/provider/wallet/wallet_provider.dart';
import 'package:deemusiq/services/wallet/payment_service.dart';
import 'package:deemusiq/services/wallet/wallet_api.dart';
import 'package:url_launcher/url_launcher_string.dart';

Future<void> showPurchaseTokensDialog(
  BuildContext context, {
  required TokenPack pack,
}) {
  return showDialog(
    context: context,
    builder: (context) => PurchaseTokensDialog(pack: pack),
  );
}

class PurchaseTokensDialog extends HookConsumerWidget {
  final TokenPack pack;
  const PurchaseTokensDialog({super.key, required this.pack});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final region = ref.watch(regionTierProvider);
    // Default to the first rail the backend hasn't told us is down — never
    // pre-select a dead rail.
    final method = useState(PaymentMethodKind.topUpMethods.firstWhere(
      (m) => !DeeMusiqPaymentService.isMethodUnavailable(m),
      orElse: () => PaymentMethodKind.payshap,
    ));
    // When every rail is session-unavailable the fallback above can still be
    // a dead method — never let Continue fire on it.
    final methodUnavailable =
        DeeMusiqPaymentService.isMethodUnavailable(method.value);
    final loading = useState(false);
    final result = useState<PaymentResult?>(null);
    final phoneController = useTextEditingController();
    final phoneError = useState<String?>(null);
    final tracking = useState(false);

    Future<void> applyAndClose(String toast) async {
      await ref.read(walletProvider.notifier).applyTopUp(
            pack: pack,
            method: method.value,
            region: region,
          );
      if (context.mounted) {
        showWalletToast(context, toast);
        Navigator.pop(context);
      }
    }

    /// Bridges pending → confirmed: polls the intent and re-syncs the wallet
    /// so the balance updates even when no deep link brings the user back
    /// (crypto has no redirect at all; card users may close the browser tab).
    void trackIntent(String intentId) {
      if (tracking.value) return;
      // Local/offline results use a "DM-" reference, not a backend intent id.
      if (!WalletApiClient.instance.isConfigured ||
          intentId.startsWith("DM-")) {
        return;
      }
      tracking.value = true;
      unawaited(
        ref
            .read(walletProvider.notifier)
            .trackPaymentIntent(intentId)
            .then((status) {
          if (status == "completed" && context.mounted) {
            showWalletToast(
              context,
              "Payment confirmed — tokens added to your wallet 🎉",
            );
          }
        }),
      );
    }

    Future<void> runPurchase() async {
      // PayShap-by-phone: optional, but when entered it must normalise to
      // E.164 (same rules as the backend) — fail inline, not with a 400.
      String? payerPhone;
      if (method.value == PaymentMethodKind.payshap &&
          phoneController.text.trim().isNotEmpty) {
        payerPhone =
            DeeMusiqPaymentService.normalizePayerPhone(phoneController.text);
        if (payerPhone == null) {
          phoneError.value =
              "That phone number doesn't look right — use a number like +27 82 123 4567.";
          return;
        }
      }
      phoneError.value = null;
      loading.value = true;
      final res = await const DeeMusiqPaymentService().purchase(
        pack: pack,
        region: region,
        method: method.value,
        payerPhone: payerPhone,
      );
      if (!context.mounted) return;
      loading.value = false;
      if (res.status == PaymentStatus.success) {
        await applyAndClose("Added ${pack.totalTokens} tokens 🎉");
        return;
      }
      result.value = res;
      if (res.status == PaymentStatus.awaitingDeposit ||
          res.status == PaymentStatus.requiresBackend) {
        trackIntent(res.reference);
      }
    }

    final res = result.value;

    return AlertDialog(
      title: Row(
        children: [
          const Icon(DeeMusiqIcons.token, color: deeMusiqOrange),
          const Gap(8),
          Expanded(
            child: Text("Buy ${pack.totalTokens} tokens").large(),
          ),
        ],
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          child: res == null
              ? _MethodPicker(
                  pack: pack,
                  selected: method.value,
                  priceLabel: region.formatPrice(pack.basePriceZar),
                  onSelect: (m) => method.value = m,
                  showPhoneField: method.value == PaymentMethodKind.payshap,
                  phoneController: phoneController,
                  phoneError: phoneError.value,
                )
              : _ResultView(result: res),
        ),
      ),
      actions: res == null
          ? [
              Button.outline(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              Button.primary(
                onPressed:
                    loading.value || methodUnavailable ? null : runPurchase,
                child: Text(loading.value ? "Processing…" : "Continue"),
              ),
            ]
          : res.status == PaymentStatus.failed ||
                  res.status == PaymentStatus.unavailable
              ? [
                  Button.outline(
                    onPressed: () => result.value = null,
                    child: const Text("Try another method"),
                  ),
                  Button.primary(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Close"),
                  ),
                ]
              : [
                  Button.outline(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Close"),
                  ),
                  if (res.actionUrl != null)
                    Button.primary(
                      onPressed: () {
                        launchUrlString(
                          res.actionUrl!,
                          mode: LaunchMode.externalApplication,
                        );
                        Navigator.pop(context);
                      },
                      child: const Text("Open checkout"),
                    ),
                ],
    );
  }
}

class _MethodPicker extends StatelessWidget {
  final TokenPack pack;
  final PaymentMethodKind selected;
  final String priceLabel;
  final ValueChanged<PaymentMethodKind> onSelect;

  /// PayShap-by-phone: shown only when PayShap is the selected rail. The
  /// number is optional (the backend reuses a previously-stored one) but when
  /// entered it must normalise to E.164 — [phoneError] carries the inline
  /// validation message.
  final bool showPhoneField;
  final TextEditingController phoneController;
  final String? phoneError;

  const _MethodPicker({
    required this.pack,
    required this.selected,
    required this.priceLabel,
    required this.onSelect,
    required this.showPhoneField,
    required this.phoneController,
    this.phoneError,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(priceLabel).h3(),
            const Gap(6),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                pack.bonusTokens > 0
                    ? "incl. ${pack.bonusTokens} bonus"
                    : pack.label,
              ).muted().small(),
            ),
          ],
        ),
        const Gap(4),
        const Text("Choose how to pay").muted().small(),
        const Gap(12),
        for (final m in PaymentMethodKind.topUpMethods)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _MethodTile(
              method: m,
              selected: m == selected,
              unavailable: DeeMusiqPaymentService.isMethodUnavailable(m),
              onTap: () => onSelect(m),
            ),
          ),
        if (showPhoneField) ...[
          const Gap(4),
          const Text("PayShap phone number (optional)").small().semiBold(),
          const Gap(6),
          TextField(
            controller: phoneController,
            placeholder: const Text("+27 82 123 4567"),
          ),
          if (phoneError != null) ...[
            const Gap(6),
            Text(
              phoneError!,
              style:
                  TextStyle(color: context.theme.colorScheme.destructive),
            ).xSmall(),
          ] else ...[
            const Gap(6),
            const Text(
              "We'll send the payment request to this number. Leave blank to reuse your saved number.",
            ).muted().xSmall(),
          ],
        ],
      ],
    );
  }
}

class _MethodTile extends StatelessWidget {
  final PaymentMethodKind method;
  final bool selected;

  /// The backend reported this rail as not live (`requires_config` /
  /// `unavailable`) this session — render a badge and disable selection so
  /// users can't pick a rail that dead-ends.
  final bool unavailable;
  final VoidCallback onTap;

  const _MethodTile({
    required this.method,
    required this.selected,
    required this.unavailable,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const amber = Color(0xFFF59E0B);
    return Opacity(
      opacity: unavailable ? 0.55 : 1,
      child: Card(
        filled: selected && !unavailable,
        fillColor:
            selected && !unavailable ? method.accent.withValues(alpha: 0.10) : null,
        borderColor: selected && !unavailable ? method.accent : null,
        padding: EdgeInsets.zero,
        child: Button.ghost(
          onPressed: unavailable ? null : onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: method.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(method.icon, color: method.accent, size: 18),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(method.label).semiBold(),
                      Text(method.subtitle).muted().xSmall(),
                      if (unavailable) ...[
                        const Gap(2),
                        const Text(
                          "Unavailable right now",
                          style: TextStyle(color: amber, fontSize: 11),
                        ),
                      ],
                    ],
                  ),
                ),
                if (!unavailable)
                  Icon(
                    selected
                        ? DeeMusiqIcons.radioChecked
                        : DeeMusiqIcons.radioUnchecked,
                    color: selected
                        ? method.accent
                        : context.theme.colorScheme.mutedForeground,
                    size: 18,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  final PaymentResult result;
  const _ResultView({required this.result});

  @override
  Widget build(BuildContext context) {
    final deposit = result.deposit;
    final title = switch (result.status) {
      PaymentStatus.awaitingDeposit => "Awaiting deposit",
      PaymentStatus.unavailable => "Unavailable right now",
      PaymentStatus.failed => "Couldn't start checkout",
      _ => "Almost there",
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(
              result.status == PaymentStatus.awaitingDeposit
                  ? DeeMusiqIcons.bitcoin
                  : DeeMusiqIcons.info,
              color: deeMusiqOrange,
            ),
            const Gap(8),
            Expanded(
              child: Text(title).semiBold(),
            ),
          ],
        ),
        const Gap(10),
        Text(result.message),
        if (deposit != null) ...[
          const Gap(12),
          Card(
            filled: true,
            fillColor: context.theme.colorScheme.muted,
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("${deposit.asset} · ${deposit.network}").semiBold(),
                const Gap(4),
                Text("Amount: ${deposit.amountLabel}").muted().small(),
                const Gap(8),
                if (deposit.isConfigured)
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          deposit.address,
                          style: context.theme.typography.small.copyWith(
                            fontFamily: "monospace",
                          ),
                        ),
                      ),
                      IconButton.ghost(
                        icon: const Icon(DeeMusiqIcons.clipboard, size: 16),
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(text: deposit.address),
                          );
                          showWalletToast(context, "Address copied");
                        },
                      ),
                    ],
                  )
                else
                  const Text(
                    "No receiving wallet configured yet — set one in the backend / DEEMUSIQ_WALLET.md to accept this asset.",
                  ).muted().small(),
              ],
            ),
          ),
        ],
        const Gap(12),
        Text(
          result.status == PaymentStatus.awaitingDeposit
              ? "Reference ${result.reference} · tokens appear automatically once the payment confirms."
              : "Reference ${result.reference}",
        ).muted().xSmall(),
      ],
    );
  }
}
