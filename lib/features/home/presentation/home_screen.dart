import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/cashew_bottom_sheet.dart';
import '../../documents/presentation/documents_screen.dart';
import '../../documents/widgets/add_edit_document_sheet.dart';
import '../../favorites/presentation/favorites_screen.dart';
import '../../subjects/presentation/subjects_screen.dart';
import '../../subjects/widgets/add_edit_subject_sheet.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final ThemeMode currentThemeMode;

  const HomeScreen({
    super.key,
    required this.onToggleTheme,
    required this.currentThemeMode,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DocumentsScreen(),
    SubjectsScreen(),
    FavoritesScreen(),
  ];

  void _showAddDialog() {
    showCashewModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const CashewSheetHandle(),
            const SizedBox(height: 8),
            const Text(
              'Tạo mới',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF3F51B5).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.note_add_rounded,
                    color: Color(0xFF3F51B5)),
              ),
              title: const Text('Thêm tài liệu mới',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: const Text('PDF, Word, PowerPoint hoặc liên kết web'),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              onTap: () {
                Navigator.pop(ctx);
                showCashewModalBottomSheet(
                  context: context,
                  builder: (_) => const AddEditDocumentSheet(),
                );
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF43A047).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.school_rounded,
                    color: Color(0xFF43A047)),
              ),
              title: const Text('Thêm môn học mới',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: const Text('Tạo danh mục để phân loại tài liệu'),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              onTap: () {
                Navigator.pop(ctx);
                showCashewModalBottomSheet(
                  context: context,
                  builder: (_) => const AddEditSubjectSheet(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 720;
    final isDark = widget.currentThemeMode == ThemeMode.dark ||
        (widget.currentThemeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    if (isDesktop) {
      return Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFF3F51B5),
          foregroundColor: Colors.white,
          onPressed: _showAddDialog,
          tooltip: 'Tạo mới',
          child: const Icon(Icons.add_rounded),
        ),
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _currentIndex,
              onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
              labelType: NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Column(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3F51B5),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.local_library_rounded,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'StudyHub',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: IconButton(
                      icon: Icon(
                        isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                      ),
                      tooltip: isDark ? 'Chế độ sáng' : 'Chế độ tối',
                      onPressed: widget.onToggleTheme,
                    ),
                  ),
                ),
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.folder_outlined),
                  selectedIcon: Icon(Icons.folder_rounded),
                  label: Text('Tài liệu'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.school_outlined),
                  selectedIcon: Icon(Icons.school_rounded),
                  label: Text('Môn học'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.star_outline_rounded),
                  selectedIcon: Icon(Icons.star_rounded),
                  label: Text('Quan trọng'),
                ),
              ],
            ),
            const VerticalDivider(width: 1, thickness: 1),
            Expanded(child: _pages[_currentIndex]),
          ],
        ),
      );
    }

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        backgroundColor: getColor(context, 'lightDarkAccent'),
        elevation: 2,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder_rounded),
            label: 'Tài liệu',
          ),
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school_rounded),
            label: 'Môn học',
          ),
          NavigationDestination(
            icon: Icon(Icons.star_outline_rounded),
            selectedIcon: Icon(Icons.star_rounded),
            label: 'Quan trọng',
          ),
        ],
      ),
    );
  }
}
