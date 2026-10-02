import 'package:deemusiq/models/wallet/payment_method.dart';
import 'package:deemusiq/models/wallet/region_pricing.dart';
import 'package:deemusiq/models/wallet/token_pack.dart';
import 'package:deemusiq/services/integrity/integrity_service.dart';
import 'package:deemusiq/services/wallet/wallet_api.dart';

enum PaymentStatus {
  /// Tokens credited immediately (demo top-up only).
  success,

  /// Real rail is wired but settlement happens off-app and needs the DeeMusiq
  /// backend (PayShap/PayFast/Stripe redirect, or a crypto deposit watcher).
  requiresBackend,

  /// Crypto: we produced a deposit request; confirmation needs a chain watcher.
  awaitingDeposit,

  /// The rail can't take payment right now: the backend reported
  /// `requires_config` (provider keys not set) or `unavailable` (no receiving
  /// wallet / region not served). Distinct from [failed] so the UI can show a
  /// calm "unavailable right now" state instead of an error — and must NOT
  /// offer an "Open checkout" action (there is nothing to open).
  unavailable,

  failed,
}

/// Instructions for an on-chain top-up. [address] is empty until the operator
/// configures real deposit wallets (see [PaymentGatewayConfig]).
class CryptoDepositInfo {
  final String asset;
  final String network;
  final String address;
  final String amountLabel;
  final String? payAmount;

  const CryptoDepositInfo({
    required this.asset,
    required this.network,
    required this.address,
    required this.amountLabel,
    this.payAmount,
  });

  bool get isConfigured => address.isNotEmpty;
}

class PaymentResult {
  final PaymentStatus status;
  final String reference;
  final String message;

  /// Tokens to credit right now (non-zero only for demo success).
  final int creditedTokens;
  final CryptoDepositInfo? deposit;

  /// A hosted-checkout URL to open (set when a real backend returns a card
  /// redirect). When present, the UI offers an "Open checkout" action.
  final String? actionUrl;
  final String? recoveryUrl;

  /// Whether the UI may offer a "Simulate success (demo)" shortcut. True only
  /// for the local/no-backend scaffold; false for real backend responses (so a
  /// user can't fake-credit a real wallet).
  final bool allowSimulate;

  const PaymentResult({
    required this.status,
    required this.reference,
    required this.message,
    this.creditedTokens = 0,
    this.deposit,
    this.actionUrl,
    this.recoveryUrl,
    this.allowSimulate = false,
  });
}

/// Operator-supplied endpoints / wallets. Everything here is blank by default;
/// fill these (ideally from the backend, not hard-coded) to go live.
abstract class PaymentGatewayConfig {
  /// Base URL of the DeeMusiq backend that owns the wallet, payments, account
  /// linking and download authorisation. Set this to your server, e.g.
  /// `https://api.deemusiq.co.za`. `http://` URLs are REJECTED outside debug
  /// builds (H3): the secure channel seals bodies only, so bearer tokens and
  /// query strings would still travel in cleartext.
  /// Empty = no backend, so the app runs OFFLINE: online streaming + already
  /// downloaded songs only, and the wallet/payments/account screens are locked.
  ///
  /// Can be overridden at build time with `--dart-define=DEEMUSIQ_BACKEND_URL=...`.
  static const String backendBaseUrl =
      String.fromEnvironment("DEEMUSIQ_BACKEND_URL", defaultValue: "");

  /// Pre-shared 256-bit key (base64 of 32 random bytes) for the AES-256-GCM
  /// "secure channel" that encrypts every request/response body in transit.
  /// MUST equal the backend's `SECURE_CHANNEL_KEY`.
  /// Generate with: `openssl rand -base64 32`. Empty = plaintext JSON.
  ///
  /// Accepted risk (H4, documented in secure_channel.dart): this is a
  /// compile-time secret shared by every install — extractable by
  /// decompilation. Auth never depends on it (per-device Ed25519 login).
  ///
  /// Override at build time with `--dart-define=DEEMUSIQ_CHANNEL_KEY=...`.
  static const String secureChannelKey =
      String.fromEnvironment("DEEMUSIQ_CHANNEL_KEY", defaultValue: "");

  /// Zero-width wire encoding: when the secure channel is active, sealed
  /// envelopes additionally travel as invisible Unicode characters inside
  /// {"v":3,"zw":"…"} — bodies look structurally blank on the wire. Must match
  /// the backend's `ZW_WIRE`. ~12× payload expansion.
  ///
  /// Enable with `--dart-define=DEEMUSIQ_ZW_WIRE=1`.
  static const bool zwWire =
      bool.fromEnvironment("DEEMUSIQ_ZW_WIRE", defaultValue: false);

  /// DeeMusiq currently settles in South Africa only. When true the app prices
  /// and charges in ZAR and the backend rejects non-ZA checkouts. Mirrors the
  /// backend's `PAYMENTS_ZA_ONLY`.
  static const bool paymentsZaOnly = true;

  // NOTE: deposit addresses are NOT configured app-side. The backend owns the
  // receiving wallets (env `CRYPTO_ADDR_*`) and returns them per-checkout in
  // the `/payments/checkout` crypto response (see [CryptoDepositInfo]).

  static const Map<PaymentMethodKind, String> cryptoNetworks = {
    PaymentMethodKind.bitcoin: "Bitcoin mainnet",
    PaymentMethodKind.ethereum: "Ethereum (ERC-20)",
    PaymentMethodKind.monero: "Monero",
    PaymentMethodKind.usdt: "Tether (ERC-20 / TRC-20)",
  };
}

abstract class PaymentService {
  Future<PaymentResult> purchase({
    required TokenPack pack,
    required RegionTier region,
    required PaymentMethodKind method,
    String? payerPhone,
  });
}

/// Default implementation.
///
/// - `demoCredit` settles instantly so the wallet is fully usable offline.
/// - Fiat rails return [PaymentStatus.requiresBackend]: a real build POSTs to
///   [PaymentGatewayConfig.backendBaseUrl] to open a PayShap/PayFast/Stripe
///   checkout.
/// - Crypto rails return [PaymentStatus.awaitingDeposit] with a deposit request;
///   a backend chain-watcher credits the tokens once the deposit confirms.
///
/// No real money moves in this build — by design. The seams (backend URL,
/// wallet addresses) are the only things missing to go live.
class DeeMusiqPaymentService implements PaymentService {
  const DeeMusiqPaymentService();

  /// Rails the backend told us are not live (`requires_config` / `unavailable`
  /// checkout responses) this session. The method picker can render these with
  /// an "unavailable right now" state instead of letting the user discover the
  /// dead-end after tapping Continue. Session-scoped on purpose: an operator
  /// going live with a provider shouldn't require an app update, just a
  /// restart/re-fetch.
  static final Set<PaymentMethodKind> unavailableMethods = {};

  static bool isMethodUnavailable(PaymentMethodKind method) =>
      unavailableMethods.contains(method);

  /// Loose E.164 check shared with the backend (`normalizeE164` in
  /// backend/src/util/phone.ts): up to 15 digits, optional leading +.
  static final RegExp _e164Re = RegExp(r'^\+?[1-9]\d{6,14}$');

  /// Normalise a phone number to canonical E.164 (`+<cc><nsn>`), mirroring the
  /// backend's `normalizeE164` exactly (ZA country code 27 by default) so a
  /// PayShap checkout never round-trips a 400 `bad_phone`:
  /// `073 725 3454` and `+27 73 725 3454` both become `+27737253454`.
  /// Returns null when the input can't be a plausible MSISDN.
  static String? normalizePayerPhone(
    String input, {
    String defaultCountryCode = "27",
  }) {
    var raw = input.trim().replaceAll(RegExp(r'[\s\-().]'), '');
    if (raw.isEmpty) return null;
    if (raw.startsWith('+')) raw = raw.substring(1);
    if (!RegExp(r'^\d+$').hasMatch(raw)) return null;

    // Already carries a country code (length heuristic, as on the backend).
    if (raw.startsWith(defaultCountryCode) &&
        raw.length >= defaultCountryCode.length + 7) {
      final candidate = '+$raw';
      return _e164Re.hasMatch(candidate) ? candidate : null;
    }
    // National number: drop the trunk 0 and prefix the country code.
    if (raw.startsWith('0')) raw = raw.substring(1);
    final candidate = '+$defaultCountryCode$raw';
    return _e164Re.hasMatch(candidate) ? candidate : null;
  }

  String _reference() =>
      "DM-${DateTime.now().millisecondsSinceEpoch.toRadixString(36).toUpperCase()}";

  String? _recoveryUrl(Map<String, dynamic> response) {
    for (final key in const ["recoveryUrl", "statusUrl", "recoveryPath"]) {
      final value = response[key];
      if (value is String && value.isNotEmpty) return value;
    }
    final intentId = response["intentId"];
    if (intentId is String && intentId.isNotEmpty) {
      return "/payments/${Uri.encodeComponent(intentId)}";
    }
    return null;
  }

  @override
  Future<PaymentResult> purchase({
    required TokenPack pack,
    required RegionTier region,
    required PaymentMethodKind method,
    String? payerPhone,
  }) async {
    // Refuse to move money from a build flagged as tampered/repackaged.
    if (IntegrityService.instance.walletLocked) {
      return PaymentResult(
        status: PaymentStatus.failed,
        reference: _reference(),
        message:
            "Top-ups are disabled because this app may be modified. Reinstall the official DeeMusiq.",
      );
    }
    // DeeMusiq tokens are purchased ONLINE only — the backend is the single
    // source of truth for balances, so there is no local or "demo" crediting.
    if (PaymentGatewayConfig.backendBaseUrl.isEmpty) {
      return PaymentResult(
        status: PaymentStatus.requiresBackend,
        reference: _reference(),
        message:
            "Token top-ups are online only. Connect to the internet and DeeMusiq to buy tokens.",
      );
    }
    if (method == PaymentMethodKind.demoCredit) {
      return PaymentResult(
        status: PaymentStatus.failed,
        reference: _reference(),
        message:
            "Demo top-ups are off — DeeMusiq tokens are purchased securely online.",
      );
    }
    // PayShap-by-phone: normalise to E.164 client-side (same rules as the
    // backend) so a typo fails here with a readable message instead of a
    // 400 bad_phone after the intent round-trip.
    String? e164Phone;
    if (payerPhone != null && payerPhone.trim().isNotEmpty) {
      e164Phone = normalizePayerPhone(payerPhone);
      if (e164Phone == null) {
        return PaymentResult(
          status: PaymentStatus.failed,
          reference: _reference(),
          message:
              "That phone number doesn't look right — use a number like +27 82 123 4567.",
        );
      }
    }
    return _purchaseViaBackend(
      pack: pack,
      region: region,
      method: method,
      payerPhone: e164Phone,
    );
  }

  /// Talks to the DeeMusiq backend `/payments/checkout`. Maps the server's
  /// response to a [PaymentResult]. No `allowSimulate` here — real settlement
  /// only happens through the provider + webhook.
  Future<PaymentResult> _purchaseViaBackend({
    required TokenPack pack,
    required RegionTier region,
    required PaymentMethodKind method,
    String? payerPhone,
  }) async {
    try {
      final res = await WalletApiClient.instance.createCheckout(
        packId: pack.id,
        method: method.name,
        region: region.code,
        payerPhone: payerPhone,
      );
      final reference = (res["intentId"] as String?) ?? _reference();
      final recoveryUrl = _recoveryUrl(res);

      switch (res["status"] as String?) {
        case "redirect":
          unavailableMethods.remove(method);
          return PaymentResult(
            status: PaymentStatus.requiresBackend,
            reference: reference,
            message:
                "Open the secure ${method.label} checkout to pay. Tokens are added once payment confirms.",
            actionUrl: (res["payUrl"] as String?) ?? recoveryUrl,
            recoveryUrl: recoveryUrl,
          );
        case "crypto":
          unavailableMethods.remove(method);
          final d = res["deposit"] as Map?;
          return PaymentResult(
            status: PaymentStatus.awaitingDeposit,
            reference: reference,
            message: "Send the exact amount below to confirm your top-up.",
            deposit: CryptoDepositInfo(
              asset: (d?["asset"] ?? method.label).toString(),
              network: (d?["network"] ?? method.label).toString(),
              address: (d?["address"] ?? "").toString(),
              amountLabel: (d?["amountLabel"] ?? "").toString(),
              payAmount: d?["payAmount"]?.toString(),
            ),
            recoveryUrl: recoveryUrl,
          );
        case "pending":
          return PaymentResult(
            status: PaymentStatus.requiresBackend,
            reference: reference,
            message:
                "Checkout is still being prepared. Use the recovery link to check its status.",
            actionUrl: recoveryUrl,
            recoveryUrl: recoveryUrl,
          );
        case "requires_config":
        case "unavailable":
          // Config-level refusal (provider keys missing, no receiving wallet,
          // region not served): remember it so the picker can mark this rail
          // "unavailable right now", and never offer an "Open checkout" action
          // — the recovery link is a status page, not a payment page.
          unavailableMethods.add(method);
          return PaymentResult(
            status: PaymentStatus.unavailable,
            reference: reference,
            message: (res["message"] ??
                    "${method.label} isn't available right now — pick another method or try again later.")
                .toString(),
            recoveryUrl: recoveryUrl,
          );
        case "completed":
          return PaymentResult(
            status: PaymentStatus.requiresBackend,
            reference: reference,
            message:
                "Payment completed. Tokens will appear after confirmation.",
            recoveryUrl: recoveryUrl,
          );
        default:
          return PaymentResult(
            status: PaymentStatus.failed,
            reference: reference,
            message:
                (res["message"] ?? "Checkout could not be started.").toString(),
            recoveryUrl: recoveryUrl,
          );
      }
    } on WalletApiException catch (e) {
      return PaymentResult(
        status: PaymentStatus.failed,
        reference: _reference(),
        message: e.friendlyMessage,
      );
    }
  }
}
