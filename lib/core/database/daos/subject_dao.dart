import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/subjects_table.dart';
import '../tables/documents_table.dart';
import '../tables/delete_logs_table.dart';

part 'subject_dao.g.dart';

@DriftAccessor(tables: [Subjects, Documents, DeleteLogs])
class SubjectDao extends DatabaseAccessor<AppDatabase> with _$SubjectDaoMixin {
  SubjectDao(super.db);

  Stream<List<Subject>> watchAllSubjects() {
    return (select(subjects)
          ..orderBy([(s) => OrderingTerm.asc(s.name)]))
        .watch();
  }

  Future<List<Subject>> getAllSubjects() {
    return (select(subjects)
          ..orderBy([(s) => OrderingTerm.asc(s.name)]))
        .get();
  }

  Future<Subject?> getSubject(String pk) {
    return (select(subjects)..where((s) => s.subjectPk.equals(pk)))
        .getSingleOrNull();
  }

  Future<void> insertOrUpdateSubject(SubjectsCompanion subject) async {
    final now = DateTime.now();
    final updated = subject.copyWith(dateTimeModified: Value(now));
    await into(subjects).insertOnConflictUpdate(updated);
  }

  Future<void> deleteSubjectSafely(String pk) async {
    await transaction(() async {
      // Find all documents for this subject to log tombstone
      final docsToDelete = await (select(documents)
            ..where((d) => d.subjectFk.equals(pk)))
          .get();

      for (final doc in docsToDelete) {
        await (delete(documents)
              ..where((d) => d.documentPk.equals(doc.documentPk)))
            .go();
        await into(deleteLogs).insert(
          DeleteLogsCompanion.insert(
            entryPk: doc.documentPk,
            type: DeleteLogType.document,
            dateTimeModified: Value(DateTime.now()),
          ),
        );
      }

      // Delete subject
      await (delete(subjects)..where((s) => s.subjectPk.equals(pk))).go();
      await into(deleteLogs).insert(
        DeleteLogsCompanion.insert(
          entryPk: pk,
          type: DeleteLogType.subject,
          dateTimeModified: Value(DateTime.now()),
        ),
      );
    });
  }
}
