import 'package:deemusiq/services/logger/logger.dart';
import 'package:deemusiq/services/wallet/wallet_api.dart';

enum BirthYearSubmitStatus {
  /// Server accepted the birth year (POST /me/birth-year 200).
  success,

  /// Server rejected the birth year: the user is under the minimum age.
  underMinAge,

  /// The backend could not be reached — the local KV flag stands until the
  /// server (the source of truth) can be synced.
  connectivity,

  /// Any other server-side rejection.
  error,
}

class BirthYearSubmitResult {
  final BirthYearSubmitStatus status;
  final String? message;
  const BirthYearSubmitResult(this.status, [this.message]);
}

/// Parses a user-entered birth year ("1990") for submission. Returns null
/// for non-numeric input and implausible years.
int? parseBirthYearInput(String input, {int? currentYear}) {
  final year = int.tryParse(input.trim());
  if (year == null) return null;
  final now = currentYear ?? DateTime.now().year;
  if (year < 1900 || year > now) return null;
  return year;
}

/// Submits the confirmed birth year to the backend (POST /me/birth-year),
/// which is the source of truth for age verification — the local KV flag is
/// only a cache. [submit] is injectable for tests.
Future<BirthYearSubmitResult> submitBirthYearToServer(
  int birthYear, {
  Future<void> Function(int birthYear)? submit,
}) async {
  try {
    await (submit ?? WalletApiClient.instance.submitBirthYear)(birthYear);
    return const BirthYearSubmitResult(BirthYearSubmitStatus.success);
  } on WalletApiException catch (e) {
    if (e.code == "under_min_age") {
      return BirthYearSubmitResult(
          BirthYearSubmitStatus.underMinAge, e.friendlyMessage);
    }
    if (e.isConnectivity) {
      return BirthYearSubmitResult(
          BirthYearSubmitStatus.connectivity, e.friendlyMessage);
    }
    return BirthYearSubmitResult(BirthYearSubmitStatus.error, e.friendlyMessage);
  } catch (e, stack) {
    AppLogger.reportError(e, stack, "submitBirthYearToServer");
    return const BirthYearSubmitResult(BirthYearSubmitStatus.connectivity);
  }
}
