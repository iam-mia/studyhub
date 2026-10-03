import 'package:drift/drift.dart';
import '../app_database.dart';

@DataClassName('Subject')
class Subjects extends Table {
  TextColumn get subjectPk => text().clientDefault(() => uuid.v4())();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get code => text().withLength(min: 1, max: 50)();
  IntColumn get color => integer().withDefault(const Constant(0xFF4A90E2))();
  TextColumn get icon => text().withDefault(const Constant('book'))();
  DateTimeColumn get dateCreated =>
      dateTime().clientDefault(() => DateTime.now())();
  DateTimeColumn get dateTimeModified =>
      dateTime().withDefault(Constant(DateTime.now()))();

  @override
  Set<Column> get primaryKey => {subjectPk};
}
