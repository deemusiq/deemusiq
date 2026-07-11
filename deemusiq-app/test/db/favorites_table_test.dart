import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:deemusiq/models/database/database.dart';
import 'package:flutter_test/flutter_test.dart';

// Exercises the schema-v11 favorites table (the local source of truth for the
// heart button) end to end against a fresh in-memory database.
void main() {
  test('favorites table round-trips a liked track at schema v11', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    expect(db.schemaVersion, 11);

    await db.into(db.favoritesTable).insert(
          FavoritesTableCompanion.insert(
            trackId: 'track-1',
            trackName: 'A Song',
            artistName: 'An Artist',
            albumName: const Value('An Album'),
            thumbnailUrl: const Value('https://img/thumb.jpg'),
            sourceUri: const Value('ytsource:abc123'),
            durationMs: const Value(180000),
          ),
        );

    final rows = await db.select(db.favoritesTable).get();
    expect(rows, hasLength(1));
    final fav = rows.single;
    expect(fav.trackId, 'track-1');
    expect(fav.trackName, 'A Song');
    expect(fav.artistName, 'An Artist');
    expect(fav.albumName, 'An Album');
    expect(fav.durationMs, 180000);
    expect(fav.createdAt, isNotNull);

    // Nullable columns tolerate absent values.
    await db.into(db.favoritesTable).insert(
          FavoritesTableCompanion.insert(
            trackId: 'track-2',
            trackName: 'Minimal',
            artistName: 'Nobody',
          ),
        );
    final byId = await (db.select(db.favoritesTable)
          ..where((t) => t.trackId.equals('track-2')))
        .getSingle();
    expect(byId.albumName, isNull);
    expect(byId.thumbnailUrl, isNull);

    // Deletion by trackId (used by unlike).
    await (db.delete(db.favoritesTable)
          ..where((t) => t.trackId.equals('track-1')))
        .go();
    expect(await db.select(db.favoritesTable).get(), hasLength(1));
  });
}
