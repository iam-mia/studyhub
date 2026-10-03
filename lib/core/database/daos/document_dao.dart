import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/documents_table.dart';
import '../tables/delete_logs_table.dart';

part 'document_dao.g.dart';

@DriftAccessor(tables: [Documents, DeleteLogs])
class DocumentDao extends DatabaseAccessor<AppDatabase>
    with _$DocumentDaoMixin {
  DocumentDao(super.db);

  Stream<List<Document>> watchAllDocuments() {
    return (select(documents)
          ..orderBy([(d) => OrderingTerm.desc(d.dateCreated)]))
        .watch();
  }

  Stream<List<Document>> watchDocumentsBySubject(String subjectPk) {
    return (select(documents)
          ..where((d) => d.subjectFk.equals(subjectPk))
          ..orderBy([(d) => OrderingTerm.desc(d.dateCreated)]))
        .watch();
  }

  Stream<List<Document>> watchFavoriteDocuments() {
    return (select(documents)
          ..where((d) => d.isPinned.equals(true))
          ..orderBy([(d) => OrderingTerm.desc(d.dateCreated)]))
        .watch();
  }

  Stream<List<Document>> watchFilteredDocuments({
    String? query,
    String? subjectPk,
    DocumentType? type,
    DocumentCategory? category,
    String sortBy = 'date', // 'date' or 'name'
    bool ascending = false,
  }) {
    final s = select(documents);

    if (query != null && query.trim().isNotEmpty) {
      final q = '%${query.trim().toLowerCase()}%';
      s.where((d) =>
          d.name.lower().like(q) |
          (d.note.isNotNull() & d.note.lower().like(q)));
    }

    if (subjectPk != null && subjectPk.isNotEmpty) {
      s.where((d) => d.subjectFk.equals(subjectPk));
    }

    if (type != null) {
      s.where((d) => d.type.equals(type.index));
    }

    if (category != null) {
      s.where((d) => d.category.equals(category.index));
    }

    s.orderBy([
      (d) {
        final column = sortBy == 'name' ? d.name : d.dateCreated;
        return OrderingTerm(
          expression: column,
          mode: ascending ? OrderingMode.asc : OrderingMode.desc,
        );
      }
    ]);

    return s.watch();
  }

  Future<Document?> getDocument(String pk) {
    return (select(documents)..where((d) => d.documentPk.equals(pk)))
        .getSingleOrNull();
  }

  Future<int> countDocumentsBySubject(String subjectPk) async {
    final countExp = documents.documentPk.count();
    final query = selectOnly(documents)
      ..addColumns([countExp])
      ..where(documents.subjectFk.equals(subjectPk));
    final result = await query.getSingle();
    return result.read(countExp) ?? 0;
  }

  Future<void> insertOrUpdateDocument(DocumentsCompanion document) async {
    final now = DateTime.now();
    final updated = document.copyWith(dateTimeModified: Value(now));
    await into(documents).insertOnConflictUpdate(updated);
  }

  Future<void> togglePinned(String pk, bool isPinned) async {
    await (update(documents)..where((d) => d.documentPk.equals(pk))).write(
      DocumentsCompanion(
        isPinned: Value(isPinned),
        dateTimeModified: Value(DateTime.now()),
      ),
    );
  }

  Future<void> deleteDocumentSafely(String pk) async {
    await transaction(() async {
      await (delete(documents)..where((d) => d.documentPk.equals(pk))).go();
      await into(deleteLogs).insert(
        DeleteLogsCompanion.insert(
          entryPk: pk,
          type: DeleteLogType.document,
          dateTimeModified: Value(DateTime.now()),
        ),
      );
    });
  }
}
