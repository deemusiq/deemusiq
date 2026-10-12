import 'package:audio_service/audio_service.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:deemusiq/collections/env.dart';
import 'package:deemusiq/models/metadata/metadata.dart';
import 'package:deemusiq/provider/audio_player/audio_player.dart';
import 'package:deemusiq/services/ad_roll/ad_roll_service.dart';
import 'package:deemusiq/services/audio_player/audio_player.dart';
import 'package:deemusiq/services/audio_services/mobile_audio_service.dart';
import 'package:deemusiq/services/audio_services/windows_audio_service.dart';
import 'package:deemusiq/utils/platform.dart';

const _kAndroidNotificationChannelName = 'deemusiq_playback';
const _kAndroidNotificationChannelDesc = 'DeeMusiq media controls';

class AudioServices with WidgetsBindingObserver {
  final MobileAudioService? mobile;
  final WindowsAudioService? smtc;

  AudioServices(this.mobile, this.smtc) {
    WidgetsBinding.instance.addObserver(this);
  }

  static Future<AudioServices> create(
    Ref ref,
    AudioPlayerNotifier playback,
  ) async {
    final mobile = kIsMobile || kIsMacOS || kIsLinux
        ? await AudioService.init(
            builder: () => MobileAudioService(playback),
            config: AudioServiceConfig(
              androidNotificationChannelId: switch ((
                kIsLinux,
                Env.releaseChannel
              )) {
                (true, _) => "deemusiq",
                (_, ReleaseChannel.stable) => "za.co.deemusiq.app",
                (_, ReleaseChannel.nightly) => "za.co.deemusiq.app.nightly",
              },
              androidNotificationChannelName: _kAndroidNotificationChannelName,
              androidNotificationOngoing: false,
              androidStopForegroundOnPause: false,
              androidNotificationChannelDescription: _kAndroidNotificationChannelDesc,
            ),
          )
        : null;
    final smtc = kIsWindows ? WindowsAudioService(ref, playback) : null;

    return AudioServices(mobile, smtc);
  }

  Future<void> addTrack(DeeMusiqTrackObject track) async {
    await smtc?.addTrack(track);
    mobile?.addItem(MediaItem(
      id: track.id,
      album: track.album.name,
      title: track.name,
      artist: track.artists.asString(),
      duration: Duration(milliseconds: track.durationMs),
      artUri: (track.album.images).asUri(
        placeholder: ImagePlaceholder.albumArt,
      ),
      playable: true,
    ));
  }

  void activateSession() {
    mobile?.session?.setActive(true);
  }

  void deactivateSession() {
    mobile?.session?.setActive(false);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        // Music keeps playing: audio_service (androidStopForegroundOnPause:
        // false + notification controls) is built for continuous background
        // / screen-off listening, so pausing here would contradict it. Only
        // an ad break is paused — its audio and timer freeze until the app
        // returns to the foreground.
        if (kIsMobile) {
          AdRollService.instance.setAppForegrounded(false);
        }
        break;
      case AppLifecycleState.detached:
        // App killed: pause playback and release the audio session (this is
        // where session deactivation is genuinely needed — the process is
        // going away, not just the UI).
        if (kIsMobile) {
          AdRollService.instance.setAppForegrounded(false);
          audioPlayer.pause();
          deactivateSession();
        }
        break;
      case AppLifecycleState.resumed:
        activateSession();
        if (kIsMobile) {
          // Resumes a paused ad break (audio + remaining-time timer).
          AdRollService.instance.setAppForegrounded(true);
        }
        break;
      default:
        break;
    }
  }

  void dispose() {
    smtc?.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }
}
