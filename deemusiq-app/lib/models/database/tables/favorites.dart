part of '../database.dart';

class FavoritesTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get trackId => text()();

  TextColumn get trackName => text()();

  TextColumn get artistName => text()();

  TextColumn get albumName => text().nullable()();

  TextColumn get thumbnailUrl => text().nullable()();

  TextColumn get sourceUri => text().nullable()();

  IntColumn get durationMs => integer().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
