part of '../database.dart';

/// Offline outbox for backend-bound user actions (likes/unlikes, playlist
/// edits) that could not reach the DeeMusiq API because of connectivity.
/// Rows are replayed FIFO by the `OfflineActionReplayService` once the device
/// is back online. [entityKey] groups actions that target the same entity
/// (e.g. `liked:<songHash>`, `playlist:<id>`) so enqueueing can collapse them
/// (last-write-wins; a delete tombstones earlier adds).
class PendingActionsTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// The replay operation, e.g. `sync.like`, `sync.unlike`,
  /// `sync.playlist.create`, `sync.playlist.update`, `sync.playlist.delete`,
  /// `recommendations.like`, `recommendations.unlike`.
  TextColumn get actionType => text()();

  /// Entity this action targets; used for last-write-wins collapsing.
  TextColumn get entityKey => text()();

  /// JSON-encoded arguments for the replay call.
  TextColumn get payloadJson => text()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  IntColumn get retryCount => integer().withDefault(const Constant(0))();
}
