import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:deemusiq/services/storage/download_storage.dart';

void main() {
  late Directory downloadDir;
  late Directory cacheDir;
  late Directory documentsDir;

  setUp(() async {
    downloadDir = await Directory.systemTemp.createTemp('dmq-dl-');
    cacheDir = await Directory.systemTemp.createTemp('dmq-cache-');
    documentsDir = await Directory.systemTemp.createTemp('dmq-docs-');
  });

  tearDown(() async {
    for (final dir in [downloadDir, cacheDir, documentsDir]) {
      if (await dir.exists()) await dir.delete(recursive: true);
    }
  });

  Future<File> writeFile(Directory dir, String name, int bytes) async {
    final file = File('${dir.path}/$name');
    await file.create(recursive: true);
    await file.writeAsBytes(List.filled(bytes, 1));
    return file;
  }

  Future<StorageReport> scan() => DownloadStorage.scan(
        downloadLocation: downloadDir.path,
        cacheDir: cacheDir.path,
        documentsDir: documentsDir.path,
      );

  test('scan finds audio files across download + cache dirs with sizes',
      () async {
    await writeFile(downloadDir, 'song.mp3', 1000);
    // `.weba` is the extension the download manager gives webm-audio
    // containers (see DeeMusiqAudioSourceContainerPreset.getFileExtension).
    await writeFile(cacheDir, 'cached.weba', 2000);
    await writeFile(downloadDir, 'cover.jpg', 500); // not audio — ignored
    await writeFile(downloadDir, 'notes.txt', 100); // ignored

    final report = await scan();
    expect(report.entries, hasLength(2));
    expect(report.totalBytes, 3000);
    // Sorted by size, largest first.
    expect(report.entries.first.fileName, 'cached.weba');
    expect(report.entries.every((e) => !e.encrypted), isTrue);
  });

  test('scan reports encrypted .deemusiq files from the documents dir',
      () async {
    await writeFile(documentsDir, 'locked.mp3.deemusiq', 4000);
    await writeFile(documentsDir, 'plain.mp3', 999); // not encrypted — ignored

    final report = await scan();
    expect(report.entries, hasLength(1));
    expect(report.entries.single.encrypted, isTrue);
    expect(report.entries.single.sizeBytes, 4000);
  });

  test('missing directories scan as empty', () async {
    await downloadDir.delete(recursive: true);
    final report = await DownloadStorage.scan(
      downloadLocation: downloadDir.path,
      cacheDir: cacheDir.path,
      documentsDir: documentsDir.path,
    );
    expect(report.entries, isEmpty);
    expect(report.totalBytes, 0);
  });

  test('delete removes a single file; deleteAll clears the report', () async {
    final a = await writeFile(downloadDir, 'a.mp3', 100);
    final b = await writeFile(cacheDir, 'b.ogg', 100);
    var report = await scan();
    expect(report.entries, hasLength(2));

    expect(await DownloadStorage.delete(report.entries.first), isTrue);
    expect(await a.exists() || await b.exists(), isTrue);

    report = await scan();
    expect(await DownloadStorage.deleteAll(report.entries), 1);
    expect((await scan()).entries, isEmpty);
  });

  test('formatBytes renders compact human sizes', () {
    expect(DownloadStorage.formatBytes(512), '512 B');
    expect(DownloadStorage.formatBytes(2048), '2.0 KB');
    expect(DownloadStorage.formatBytes(5 * 1024 * 1024), '5.0 MB');
    expect(DownloadStorage.formatBytes(150 * 1024 * 1024), '150 MB');
    expect(DownloadStorage.formatBytes(3 * 1024 * 1024 * 1024), '3.0 GB');
  });
}
