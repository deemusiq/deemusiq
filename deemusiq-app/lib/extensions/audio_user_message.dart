import 'package:deemusiq/l10n/generated/app_localizations.dart';
import 'package:deemusiq/services/audio_player/audio_error_handler.dart';

extension AudioUserMessageL10n on AudioUserMessage {
  /// Resolves the message to localized text at the UI boundary. Server-supplied
  /// [raw] copy (already English) passes through untouched.
  String resolve(AppLocalizations l10n) {
    final rawMessage = raw;
    if (rawMessage != null) return rawMessage;
    return switch (key) {
      AudioErrorMessage.serversUnreachable =>
        l10n.audio_error_servers_unreachable,
      AudioErrorMessage.unavailableRetryOrDownload =>
        l10n.audio_error_unavailable_retry,
      AudioErrorMessage.connectionTimedOut =>
        l10n.audio_error_connection_timeout,
      AudioErrorMessage.connectionRefused => l10n.audio_error_connection_refused,
      AudioErrorMessage.noInternet => l10n.audio_error_no_internet,
      AudioErrorMessage.networkError => l10n.audio_error_network,
      AudioErrorMessage.tryingNextSource => l10n.audio_error_trying_next_source,
      AudioErrorMessage.trackUnavailableSkip =>
        l10n.audio_error_track_unavailable,
      AudioErrorMessage.trackNotFoundSkip => l10n.audio_error_track_not_found,
      AudioErrorMessage.trackRemovedSkip => l10n.audio_error_track_removed,
      AudioErrorMessage.rateLimited => l10n.audio_error_rate_limited,
      AudioErrorMessage.trackProtected => l10n.audio_error_track_protected,
      AudioErrorMessage.trackCorrupt => l10n.audio_error_track_corrupt,
      AudioErrorMessage.engineFailedStart => l10n.audio_error_engine_start,
      AudioErrorMessage.audioOutputError => l10n.audio_error_output_device,
      AudioErrorMessage.unsupportedFormat =>
        l10n.audio_error_unsupported_format,
      AudioErrorMessage.playbackErrorRetrying =>
        l10n.audio_error_playback_retrying,
      AudioErrorMessage.generic => l10n.audio_error_generic,
      AudioErrorMessage.multipleTracksFailed =>
        l10n.audio_error_multiple_failed,
      AudioErrorMessage.switchingTrack => l10n.audio_error_switching_track,
      AudioErrorMessage.playbackRestored => l10n.audio_error_playback_restored,
      AudioErrorMessage.engineRestartHint => l10n.audio_error_engine_restart,
      AudioErrorMessage.downloadRequested =>
        l10n.audio_error_download_requested,
      AudioErrorMessage.retryingIn => l10n.audio_error_retrying_in(
          seconds ?? 0,
          attempt ?? 0,
          maxRetries ?? 0,
        ),
      AudioErrorMessage.fallbackSource => l10n.audio_error_fallback_source,
      null => l10n.audio_error_generic,
    };
  }
}
