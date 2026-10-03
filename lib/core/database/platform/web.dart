import 'package:drift/web.dart';
import '../app_database.dart';

Future<AppDatabase> constructDb(String dbName) async {
  return AppDatabase(
    WebDatabase.withStorage(
      await DriftWebStorage.indexedDbIfSupported(dbName),
      logStatements: false,
    ),
  );
}
