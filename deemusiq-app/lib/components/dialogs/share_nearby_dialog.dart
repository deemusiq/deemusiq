import 'package:bonsoir/bonsoir.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:deemusiq/collections/routes.dart';
import 'package:deemusiq/collections/deemusiq_icons.dart';
import 'package:deemusiq/components/ui/button_tile.dart';
import 'package:deemusiq/components/wallet/wallet_common.dart';
import 'package:deemusiq/extensions/context.dart';
import 'package:deemusiq/models/connect/connect.dart';
import 'package:deemusiq/provider/connect/clients.dart';
import 'package:deemusiq/provider/connect/share.dart';

/// Peer picker for "Send to nearby device": lists the devices currently
/// discovered over mDNS (the same list the Connect page shows) and sends the
/// share payload to the chosen one over a short-lived `/ws` connection.
class ShareNearbyDialog extends HookConsumerWidget {
  final ConnectSharePayload payload;

  const ShareNearbyDialog({super.key, required this.payload});

  static Future<void> show(BuildContext context, ConnectSharePayload payload) {
    return showDialog(
      context: context,
      builder: (context) => ShareNearbyDialog(payload: payload),
    );
  }

  Future<void> _send(
    BuildContext context,
    WidgetRef ref,
    BonsoirService peer,
  ) async {
    Navigator.of(context).pop();
    final result =
        await ref.read(connectShareProvider).send(peer, payload);
    final toastContext = rootNavigatorKey.currentContext;
    if (toastContext == null || !toastContext.mounted) return;
    switch (result) {
      case ConnectShareResult.sent:
        showWalletToast(toastContext, 'Shared with ${peer.name}',
            icon: DeeMusiqIcons.speaker);
        break;
      case ConnectShareResult.denied:
        showWalletToast(toastContext, '${peer.name} declined the share',
            icon: DeeMusiqIcons.error);
        break;
      case ConnectShareResult.unreachable:
      case ConnectShareResult.failed:
        showWalletToast(toastContext, "Couldn't reach ${peer.name}",
            icon: DeeMusiqIcons.error);
        break;
    }
  }

  @override
  Widget build(BuildContext context, ref) {
    final peers =
        ref.watch(connectClientsProvider).asData?.value.services ?? const [];

    return AlertDialog(
      title: const Text('Send to nearby device'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360, maxHeight: 320),
        child: peers.isEmpty
            ? const Text(
                'No nearby devices found. Open DeeMusiq on the other device '
                'and make sure Connect is enabled on both.',
              )
            : ListView.separated(
                shrinkWrap: true,
                itemCount: peers.length,
                separatorBuilder: (context, index) => const Gap(6),
                itemBuilder: (context, index) {
                  final peer = peers[index];
                  return ButtonTile(
                    leading: const Icon(DeeMusiqIcons.monitor),
                    title: Text(peer.name),
                    onPressed: () => _send(context, ref, peer),
                  );
                },
              ),
      ),
      actions: [
        Button.outline(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.cancel),
        ),
      ],
    );
  }
}
