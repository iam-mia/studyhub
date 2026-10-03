// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subject_dao.dart';

// ignore_for_file: type=lint
mixin _$SubjectDaoMixin on DatabaseAccessor<AppDatabase> {
  $SubjectsTable get subjects => attachedDatabase.subjects;
  $DocumentsTable get documents => attachedDatabase.documents;
  $DeleteLogsTable get deleteLogs => attachedDatabase.deleteLogs;
  SubjectDaoManager get managers => SubjectDaoManager(this);
}

class SubjectDaoManager {
  final _$SubjectDaoMixin _db;
  SubjectDaoManager(this._db);
  $$SubjectsTableTableManager get subjects =>
      $$SubjectsTableTableManager(_db.attachedDatabase, _db.subjects);
  $$DocumentsTableTableManager get documents =>
      $$DocumentsTableTableManager(_db.attachedDatabase, _db.documents);
  $$DeleteLogsTableTableManager get deleteLogs =>
      $$DeleteLogsTableTableManager(_db.attachedDatabase, _db.deleteLogs);
}
