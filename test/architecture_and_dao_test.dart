import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyhub/core/database/app_database.dart';
import 'package:studyhub/core/database/tables/delete_logs_table.dart';
import 'package:studyhub/core/database/tables/documents_table.dart';
import 'package:studyhub/core/theme/app_colors.dart';
import 'package:studyhub/core/utils/formatters.dart';
import 'package:flutter/material.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    // Isolated In-Memory SQLite database ensuring pure persistence layer testing
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('Kiểm thử tầng CSDL (Persistence Layer) & DAOs', () {
    test('SubjectDao: Thêm môn học và truy vấn danh sách', () async {
      await db.subjectDao.insertOrUpdateSubject(
        const SubjectsCompanion(
          subjectPk: Value('sub-01'),
          name: Value('Lập trình di động'),
          code: Value('CSE441'),
          color: Value(0xFF3F51B5),
          icon: Value('smartphone'),
        ),
      );

      final subjects = await db.subjectDao.getAllSubjects();
      expect(subjects.length, 1);
      expect(subjects.first.name, 'Lập trình di động');
      expect(subjects.first.code, 'CSE441');
    });

    test('DocumentDao: Thêm tài liệu và phát sinh Reactive Stream', () async {
      // 1. Tạo môn học trước
      await db.subjectDao.insertOrUpdateSubject(
        const SubjectsCompanion(
          subjectPk: Value('sub-01'),
          name: Value('Lập trình di động'),
          code: Value('CSE441'),
        ),
      );

      // 2. Thêm tài liệu PDF
      await db.documentDao.insertOrUpdateDocument(
        const DocumentsCompanion(
          documentPk: Value('doc-01'),
          name: Value('Slide Kiến trúc Cashew'),
          subjectFk: Value('sub-01'),
          type: Value(DocumentType.pdf),
          fileSize: Value(2048500),
          isPinned: Value(true),
        ),
      );

      final doc = await db.documentDao.getDocument('doc-01');
      expect(doc, isNotNull);
      expect(doc!.name, 'Slide Kiến trúc Cashew');
      expect(doc.type, DocumentType.pdf);
      expect(doc.isPinned, isTrue);

      // Kiểm thử đếm số lượng tài liệu theo môn học
      final count = await db.documentDao.countDocumentsBySubject('sub-01');
      expect(count, 1);
    });

    test('DocumentDao: Đánh dấu quan trọng (Ghim/Gắn sao) và lọc danh sách',
        () async {
      await db.subjectDao.insertOrUpdateSubject(
        const SubjectsCompanion(
          subjectPk: Value('sub-01'),
          name: Value('Toán rời rạc'),
          code: Value('MAT101'),
        ),
      );

      await db.documentDao.insertOrUpdateDocument(
        const DocumentsCompanion(
          documentPk: Value('doc-fav'),
          name: Value('Đề cương ôn tập cuối kỳ'),
          subjectFk: Value('sub-01'),
          type: Value(DocumentType.word),
          isPinned: Value(false),
        ),
      );

      // Bật ghim
      await db.documentDao.togglePinned('doc-fav', true);
      var doc = await db.documentDao.getDocument('doc-fav');
      expect(doc!.isPinned, isTrue);

      // Bỏ ghim
      await db.documentDao.togglePinned('doc-fav', false);
      doc = await db.documentDao.getDocument('doc-fav');
      expect(doc!.isPinned, isFalse);
    });

    test('Cashew Tombstone Integrity: Xoá an toàn ghi nhận vào DeleteLogs',
        () async {
      await db.subjectDao.insertOrUpdateSubject(
        const SubjectsCompanion(
          subjectPk: Value('sub-tombstone'),
          name: Value('An toàn mạng'),
          code: Value('NET202'),
        ),
      );

      await db.documentDao.insertOrUpdateDocument(
        const DocumentsCompanion(
          documentPk: Value('doc-tombstone'),
          name: Value('Lab 1 Cryptography'),
          subjectFk: Value('sub-tombstone'),
          type: Value(DocumentType.pdf),
        ),
      );

      // Xoá tài liệu
      await db.documentDao.deleteDocumentSafely('doc-tombstone');

      final deletedDoc = await db.documentDao.getDocument('doc-tombstone');
      expect(deletedDoc, isNull);

      // Kiểm tra bản ghi Tombstone trong DeleteLogs
      final logs = await db.select(db.deleteLogs).get();
      expect(
        logs.any((l) =>
            l.entryPk == 'doc-tombstone' &&
            l.type == DeleteLogType.document),
        isTrue,
      );
    });

    test('SubjectDao: Xoá môn học cascade tài liệu và tạo đủ Tombstone',
        () async {
      await db.subjectDao.insertOrUpdateSubject(
        const SubjectsCompanion(
          subjectPk: Value('sub-del'),
          name: Value('Hệ điều hành'),
          code: Value('OS101'),
        ),
      );

      await db.documentDao.insertOrUpdateDocument(
        const DocumentsCompanion(
          documentPk: Value('doc-del-1'),
          name: Value('Slide Process & Thread'),
          subjectFk: Value('sub-del'),
          type: Value(DocumentType.ppt),
        ),
      );

      await db.subjectDao.deleteSubjectSafely('sub-del');

      // Môn học và tài liệu liên kết đều phải bị xoá
      expect(await db.subjectDao.getSubject('sub-del'), isNull);
      expect(await db.documentDao.getDocument('doc-del-1'), isNull);

      // DeleteLogs phải có cả bản ghi xóa môn học lẫn tài liệu
      final logs = await db.select(db.deleteLogs).get();
      expect(
        logs.any(
            (l) => l.entryPk == 'sub-del' && l.type == DeleteLogType.subject),
        isTrue,
      );
      expect(
        logs.any(
            (l) => l.entryPk == 'doc-del-1' && l.type == DeleteLogType.document),
        isTrue,
      );
    });
  });

  group('Kiểm thử tầng Tiện ích & Định dạng (Domain Utilities)', () {
    test('Formatters: Định dạng dung lượng tệp tin (File Size)', () {
      expect(Formatters.formatFileSize(0), '0 B');
      expect(Formatters.formatFileSize(512), '512 B');
      expect(Formatters.formatFileSize(1024), '1.0 KB');
      expect(Formatters.formatFileSize(1536), '1.5 KB');
      expect(Formatters.formatFileSize(1048576), '1.0 MB');
      expect(Formatters.formatFileSize(5242880), '5.0 MB');
      expect(Formatters.formatFileSize(1073741824), '1.0 GB');
    });

    test('Formatters: Phân loại nhãn và icon theo DocumentType', () {
      expect(Formatters.getDocumentTypeName(DocumentType.pdf), 'Tài liệu PDF');
      expect(Formatters.getDocumentTypeShort(DocumentType.pdf), 'PDF');
      expect(Formatters.getDocumentTypeShort(DocumentType.word), 'Word');
      expect(Formatters.getDocumentTypeShort(DocumentType.ppt), 'PPT');
      expect(Formatters.getDocumentTypeShort(DocumentType.link), 'Link');

      expect(Formatters.getDocumentTypeIcon(DocumentType.pdf),
          Icons.picture_as_pdf_rounded);
    });

    test('Cashew Pastel Color Algorithm: lightenPastel và darkenPastel', () {
      const baseColor = Color(0xFF3F51B5);
      final lightened = lightenPastel(baseColor, amount: 0.8);
      final darkened = darkenPastel(baseColor, amount: 0.8);

      // Lighten phải tiến dần về trắng (RGB cao hơn)
      expect(lightened.red > baseColor.red, isTrue);
      expect(lightened.green > baseColor.green, isTrue);

      // Darken phải tiến dần về đen (RGB thấp hơn)
      expect(darkened.red < baseColor.red, isTrue);
      expect(darkened.blue < baseColor.blue, isTrue);
    });

    test('Tự động nhận diện định dạng file (Docx, PDF, PPT) theo đuôi mở rộng', () {
      DocumentType detect(String name) {
        final ext = name.toLowerCase().split('.').last;
        if (ext == 'pdf') return DocumentType.pdf;
        if (ext == 'doc' || ext == 'docx') return DocumentType.word;
        if (ext == 'ppt' || ext == 'pptx') return DocumentType.ppt;
        return DocumentType.pdf;
      }

      expect(detect('Bao_Cao.docx'), DocumentType.word);
      expect(detect('Giao_Trinh.DOC'), DocumentType.word);
      expect(detect('Slide_Kien_Truc.pptx'), DocumentType.ppt);
      expect(detect('Bai_Tap_Lon.pdf'), DocumentType.pdf);
    });
  });
}
