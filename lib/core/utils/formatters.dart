import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/tables/documents_table.dart';

class Formatters {
  static String formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  static String formatDate(DateTime dt) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dt);
  }

  static String formatDateOnly(DateTime dt) {
    return DateFormat('dd/MM/yyyy').format(dt);
  }

  static String formatRelativeDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inSeconds < 60) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays == 1) return 'Hôm qua';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    return DateFormat('dd/MM/yyyy').format(dt);
  }

  static String getDocumentTypeName(DocumentType type) {
    switch (type) {
      case DocumentType.pdf:
        return 'Tài liệu PDF';
      case DocumentType.word:
        return 'Văn bản Word';
      case DocumentType.ppt:
        return 'Thuyết trình PowerPoint';
      case DocumentType.link:
        return 'Liên kết web';
    }
  }

  static String getDocumentTypeShort(DocumentType type) {
    switch (type) {
      case DocumentType.pdf:
        return 'PDF';
      case DocumentType.word:
        return 'Word';
      case DocumentType.ppt:
        return 'PPT';
      case DocumentType.link:
        return 'Link';
    }
  }

  static IconData getDocumentTypeIcon(DocumentType type) {
    switch (type) {
      case DocumentType.pdf:
        return Icons.picture_as_pdf_rounded;
      case DocumentType.word:
        return Icons.description_rounded;
      case DocumentType.ppt:
        return Icons.slideshow_rounded;
      case DocumentType.link:
        return Icons.link_rounded;
    }
  }

  static String getDocumentTypeColorToken(DocumentType type) {
    switch (type) {
      case DocumentType.pdf:
        return 'pdfColor';
      case DocumentType.word:
        return 'wordColor';
      case DocumentType.ppt:
        return 'pptColor';
      case DocumentType.link:
        return 'linkColor';
    }
  }

  static String getCategoryName(DocumentCategory category) {
    switch (category) {
      case DocumentCategory.lecture:
        return 'Bài giảng';
      case DocumentCategory.reference:
        return 'Tài liệu tham khảo';
      case DocumentCategory.exercise:
        return 'Bài tập';
      case DocumentCategory.exam:
        return 'Đề kiểm tra';
    }
  }

  static IconData getCategoryIcon(DocumentCategory category) {
    switch (category) {
      case DocumentCategory.lecture:
        return Icons.school_rounded;
      case DocumentCategory.reference:
        return Icons.menu_book_rounded;
      case DocumentCategory.exercise:
        return Icons.assignment_rounded;
      case DocumentCategory.exam:
        return Icons.quiz_rounded;
    }
  }

  static IconData getSubjectIconData(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'calculate':
        return Icons.calculate_rounded;
      case 'smartphone':
        return Icons.smartphone_rounded;
      case 'cloud':
        return Icons.cloud_queue_rounded;
      case 'computer':
        return Icons.computer_rounded;
      case 'science':
        return Icons.science_rounded;
      case 'language':
        return Icons.language_rounded;
      case 'code':
        return Icons.code_rounded;
      case 'history_edu':
        return Icons.history_edu_rounded;
      case 'palette':
        return Icons.palette_rounded;
      case 'psychology':
        return Icons.psychology_rounded;
      case 'book':
      default:
        return Icons.menu_book_rounded;
    }
  }
}
