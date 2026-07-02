import 'package:yt_dlp_dart/yt_dlp_dart.dart';
import 'package:deemusiq/services/youtube_engine/yt_dlp_engine.dart';

void main() async {
  await YtDlp.instance.setBinaryLocation('yt-dlp');
  final engine = YtDlpEngine();
  
  print('=== Test getStreamManifest 6J77lFt--LM ===');
  try {
    final manifest = await engine.getStreamManifest('6J77lFt--LM');
    print('Audio streams: ${manifest.audioOnly.length}');
    for (final s in manifest.audioOnly) {
      print('  ${s.codec} ${s.bitrate.bitsPerSecond}bps container=${s.container}');
    }
  } catch (e, stack) {
    print('ERROR: $e');
    print(stack);
  }
  
  print('=== Test searchVideos "test" ===');
  try {
    final results = await engine.searchVideos('test');
    print('Results: ${results.length}');
  } catch (e) {
    print('ERROR: $e');
  }
}
