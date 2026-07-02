import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:deemusiq/models/database/database.dart';

AppDatabase? _singleton;

final databaseProvider = Provider((ref) => _singleton ??= AppDatabase());
