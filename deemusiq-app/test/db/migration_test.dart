import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_common.dart'
    show ValidationOptions;
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:deemusiq/models/database/app_db/schema.dart';
import 'package:deemusiq/models/database/database.dart';

// Migration tests for AppDatabase (schema v1–v12) using drift's SchemaVerifier
// against the versioned schemas generated into lib/models/database/app_db/
// (`dart run drift_dev schema generate drift_schemas/app_db
// lib/models/database/app_db`).
//
// Column CONSTRAINTS (DEFAULT clauses) are not validated: SQLite cannot alter
// an existing column's default without a full table rebuild, so databases
// upgraded from old versions legitimately keep the defaults that were current
// when their columns were added (e.g. youtube_client_engine). Those defaults
// are inert in practice — the affected rows already exist on such installs.
const _validation = ValidationOptions(validateColumnConstraints: false);

void main() {
  late SchemaVerifier verifier;

  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    verifier = SchemaVerifier(GeneratedHelper());
  });

  // migrateAndValidate migrates the database to the app's current schema
  // version, so every historical starting point is validated against v12.
  group('migration to current schema validates', () {
    for (var from = 1; from < 12; from++) {
      test('from v$from', () async {
        final db = AppDatabase.forTesting(await verifier.startAt(from));
        await verifier.migrateAndValidate(db, 12, options: _validation);
        await db.close();
      });
    }
  });

  test('oldest (v1) to current (v12) preserves existing rows', () async {
    final schema = await verifier.schemaAt(1);
    addTearDown(schema.close);

    // Fixture row in blacklist_table — present since v1 with an unchanged
    // shape and plain-text columns — inserted through the raw connection
    // (drift docs pattern).
    schema.rawDatabase.execute(
      "INSERT INTO blacklist_table (name, element_type, element_id) "
      "VALUES ('Fixture Artist', 'artist', 'fixture-artist-id')",
    );

    final db = AppDatabase.forTesting(schema.newConnection());
    await verifier.migrateAndValidate(db, 12, options: _validation);

    final row = await (db.select(db.blacklistTable)
          ..where((t) => t.elementId.equals('fixture-artist-id')))
        .getSingle();
    expect(row.name, 'Fixture Artist');
    expect(row.elementType, BlacklistedType.artist);

    await db.close();
  });

  test('v11 → v12 adds the pending actions outbox and keeps favorites', () async {
    final schema = await verifier.schemaAt(11);
    addTearDown(schema.close);

    schema.rawDatabase.execute(
      "INSERT INTO favorites_table (track_id, track_name, artist_name, "
      "created_at) VALUES ('track-9', 'Carry Me', 'Someone', 0)",
    );

    final db = AppDatabase.forTesting(schema.newConnection());
    await verifier.migrateAndValidate(db, 12, options: _validation);

    // The new outbox table exists and accepts rows.
    await db.into(db.pendingActionsTable).insert(
          PendingActionsTableCompanion.insert(
            actionType: 'sync.like',
            entityKey: 'liked:abc123',
            payloadJson: '{"songHash":"abc123"}',
          ),
        );
    expect(await db.select(db.pendingActionsTable).get(), hasLength(1));

    // Pre-existing rows survive the upgrade.
    final fav = await (db.select(db.favoritesTable)
          ..where((t) => t.trackId.equals('track-9')))
        .getSingle();
    expect(fav.trackName, 'Carry Me');

    await db.close();
  });
}
