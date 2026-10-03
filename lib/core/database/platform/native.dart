import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../app_database.dart';

Future<AppDatabase> constructDb(String dbName) async {
  final db = LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, '$dbName.sqlite'));

    // Cashew Concurrency Pattern:
    // Read queries on foreground, Write transactions in background isolate
    QueryExecutor foregroundExecutor = NativeDatabase(file);
    QueryExecutor backgroundExecutor = NativeDatabase.createInBackground(file);

    return MultiExecutor(
      read: foregroundExecutor,
      write: backgroundExecutor,
    );
  });
  return AppDatabase(db);
}
