import 'package:flutter/material.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/database_global.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/cashew_bottom_sheet.dart';
import '../presentation/subject_detail_screen.dart';
import 'add_edit_subject_sheet.dart';

class SubjectCard extends StatelessWidget {
  final Subject subject;

  const SubjectCard({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    final textLightColor = getColor(context, 'textLight');
    final cardColor = getColor(context, 'lightDarkAccent');
    final subjectColor = Color(subject.color);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SubjectDetailScreen(subject: subject),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: getColor(context, 'dividerColor'),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: subjectColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: subjectColor.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Icon(
                Formatters.getSubjectIconData(subject.icon),
                color: subjectColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: subjectColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          subject.code,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: subjectColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Stream count of documents in this subject
                      StreamBuilder<List<Document>>(
                        stream: database.documentDao
                            .watchDocumentsBySubject(subject.subjectPk),
                        builder: (context, snapshot) {
                          final count = snapshot.data?.length ?? 0;
                          return Text(
                            '$count tài liệu',
                            style: TextStyle(
                              fontSize: 12,
                              color: textLightColor,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subject.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.more_vert_rounded,
                color: textLightColor,
              ),
              onPressed: () {
                showCashewModalBottomSheet(
                  context: context,
                  builder: (_) => AddEditSubjectSheet(subject: subject),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
