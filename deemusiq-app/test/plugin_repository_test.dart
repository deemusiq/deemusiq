import 'package:flutter_test/flutter_test.dart';
import 'package:deemusiq/models/metadata/metadata.dart';

void main() {
  group('MetadataPluginRepository', () {
    test('round-trips through JSON', () {
      final repo = MetadataPluginRepository(
        name: 'deemusiq',
        owner: 'deemusiq',
        description: "DeeMusiq's own catalog.",
        repoUrl: 'https://deemusiq.co.za/',
        topics: const ['music', 'metadata'],
      );
      final restored = MetadataPluginRepository.fromJson(repo.toJson());
      expect(restored, repo);
      expect(restored.topics, ['music', 'metadata']);
    });

    test('fromJson rejects a missing repoUrl', () {
      expect(
        () => MetadataPluginRepository.fromJson({
          'name': 'deemusiq',
          'owner': 'deemusiq',
          'description': 'x',
          'topics': ['music'],
        }),
        throwsA(isA<TypeError>()),
      );
    });
  });
}
