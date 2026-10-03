import 'package:flutter/material.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/database_global.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/cashew_bottom_sheet.dart';
import '../../../core/widgets/google_sync_dialog.dart';
import '../widgets/add_edit_subject_sheet.dart';
import '../widgets/subject_card.dart';

class SubjectsScreen extends StatefulWidget {
  const SubjectsScreen({super.key});

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  String _search = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textLightColor = getColor(context, 'textLight');
    final isDesktop = MediaQuery.of(context).size.width >= 720;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Môn học & Học phần'),
        actions: const [
          GoogleProfileAppBarButton(),
          SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF3F51B5),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Thêm môn học'),
        onPressed: () {
          showCashewModalBottomSheet(
            context: context,
            builder: (_) => const AddEditSubjectSheet(),
          );
        },
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _search = val.trim().toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm tên hoặc mã môn học...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _search.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _search = '');
                        },
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Subject>>(
              stream: database.subjectDao.watchAllSubjects(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                var subjects = snapshot.data ?? [];
                if (_search.isNotEmpty) {
                  subjects = subjects.where((s) {
                    return s.name.toLowerCase().contains(_search) ||
                        s.code.toLowerCase().contains(_search);
                  }).toList();
                }

                if (subjects.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.school_outlined,
                          size: 64,
                          color: textLightColor.withOpacity(0.5),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _search.isNotEmpty
                              ? 'Không tìm thấy môn học phù hợp'
                              : 'Chưa có môn học nào',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textLightColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        FilledButton.tonalIcon(
                          onPressed: () {
                            showCashewModalBottomSheet(
                              context: context,
                              builder: (_) => const AddEditSubjectSheet(),
                            );
                          },
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Tạo môn học đầu tiên'),
                        ),
                      ],
                    ),
                  );
                }

                if (isDesktop) {
                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 3.4,
                    ),
                    itemCount: subjects.length,
                    itemBuilder: (context, index) {
                      return SubjectCard(subject: subjects[index]);
                    },
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                  itemCount: subjects.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return SubjectCard(subject: subjects[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
