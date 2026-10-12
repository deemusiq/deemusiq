import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:deemusiq/services/logger/logger.dart';
import 'package:deemusiq/services/wallet/wallet_api.dart';

/// The caller's earn-to-listen status (`GET /rewards/status`). All amounts
/// are integer tokens; [earnedToday] resets at the server's UTC day boundary
/// and never exceeds [dailyCap].
class RewardsStatus {
  /// Server-side REWARDS_ENABLED. When false the whole feature hides — the
  /// provider folds it to null, so widgets never branch on this directly.
  final bool enabled;
  final int earnedToday;
  final int dailyCap;
  final int perPlay;

  /// True when this account earns a reduced rate (new-account taper).
  final bool newAccountTaper;
  final int lifetimeEarned;

  const RewardsStatus({
    required this.enabled,
    required this.earnedToday,
    required this.dailyCap,
    required this.perPlay,
    required this.newAccountTaper,
    required this.lifetimeEarned,
  });

  factory RewardsStatus.fromJson(Map<String, dynamic> json) => RewardsStatus(
        enabled: json["enabled"] == true,
        earnedToday: (json["earnedToday"] as num?)?.toInt() ?? 0,
        dailyCap: (json["dailyCap"] as num?)?.toInt() ?? 0,
        perPlay: (json["perPlay"] as num?)?.toInt() ?? 0,
        newAccountTaper: json["newAccountTaper"] == true,
        lifetimeEarned: (json["lifetimeEarned"] as num?)?.toInt() ?? 0,
      );
}

/// Network seam for the rewards feature (same pattern as
/// [SupportersGateway]): the default implementation talks to
/// [WalletApiClient]; tests substitute a fake.
abstract class RewardsGateway {
  /// False when no backend is configured — the UI then hides the section.
  bool get isAvailable;

  /// Null when the backend predates the rewards feature (404). Throws
  /// [WalletApiException] on failure (e.g. `logged_out`, 429, 503).
  Future<RewardsStatus?> fetchStatus();
}

class WalletRewardsGateway implements RewardsGateway {
  @override
  bool get isAvailable => WalletApiClient.instance.isConfigured;

  @override
  Future<RewardsStatus?> fetchStatus() async {
    final data = await WalletApiClient.instance.fetchRewardsStatus();
    if (data == null) return null;
    return RewardsStatus.fromJson(data);
  }
}

final rewardsGatewayProvider = Provider<RewardsGateway>(
  (ref) => WalletRewardsGateway(),
);

/// The caller's rewards status, or null when the card must hide: no backend
/// configured, the endpoint is absent (404), the feature is disabled
/// server-side, or the caller is signed out (the 401 is logged, not shown —
/// the wallet page must not toast for a passive read). Real failures (429,
/// 503, connectivity) stay AsyncErrors so the card can offer a retry.
///
/// autoDispose: re-watching after the wallet page resumes refetches, which is
/// how earnedToday catches up with verified plays credited server-side.
final rewardsStatusProvider = FutureProvider.autoDispose<RewardsStatus?>(
  (ref) async {
    final gateway = ref.watch(rewardsGatewayProvider);
    if (!gateway.isAvailable) return null;
    try {
      final status = await gateway.fetchStatus();
      if (status == null || !status.enabled) return null;
      return status;
    } on WalletApiException catch (e, stack) {
      if (e.statusCode == 401) {
        AppLogger.log.w('rewardsStatusProvider: ${e.message}');
        return null;
      }
      AppLogger.reportError(e, stack, 'rewardsStatusProvider');
      rethrow;
    }
  },
);
