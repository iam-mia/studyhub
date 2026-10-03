import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/database_global.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/cashew_bottom_sheet.dart';

class AddEditSubjectSheet extends StatefulWidget {
  final Subject? subject;

  const AddEditSubjectSheet({super.key, this.subject});

  @override
  State<AddEditSubjectSheet> createState() => _AddEditSubjectSheetState();
}

class _AddEditSubjectSheetState extends State<AddEditSubjectSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _codeController;

  static const List<int> _palette = [
    0xFF3F51B5, // Indigo
    0xFF1E88E5, // Blue
    0xFF00897B, // Teal
    0xFF43A047, // Green
    0xFFFB8C00, // Orange
    0xFFE53935, // Red
    0xFF8E24AA, // Purple
    0xFFD81B60, // Pink
    0xFF546E7A, // Blue Grey
    0xFF6D4C41, // Brown
  ];

  static const List<String> _icons = [
    'book',
    'smartphone',
    'cloud',
    'calculate',
    'computer',
    'science',
    'language',
    'code',
    'history_edu',
    'palette',
  ];

  late int _selectedColor;
  late String _selectedIcon;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.subject?.name ?? '');
    _codeController =
        TextEditingController(text: widget.subject?.code ?? '');
    _selectedColor = widget.subject?.color ?? _palette.first;
    _selectedIcon = widget.subject?.icon ?? _icons.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      if (widget.subject == null) {
        // Create new
        await database.subjectDao.insertOrUpdateSubject(
          SubjectsCompanion.insert(
            name: _nameController.text.trim(),
            code: _codeController.text.trim().toUpperCase(),
            color: drift.Value(_selectedColor),
            icon: drift.Value(_selectedIcon),
          ),
        );
      } else {
        // Update existing
        await database.subjectDao.insertOrUpdateSubject(
          widget.subject!.toCompanion(true).copyWith(
                name: drift.Value(_nameController.text.trim()),
                code: drift.Value(_codeController.text.trim().toUpperCase()),
                color: drift.Value(_selectedColor),
                icon: drift.Value(_selectedIcon),
              ),
        );
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi lưu môn học: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xoá môn học?'),
        content: Text(
          'Môn học "${widget.subject!.name}" và toàn bộ tài liệu liên kết sẽ bị xoá khỏi danh sách.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Huỷ'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: getColor(context, 'expenseAmount'),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xoá môn học'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await database.subjectDao.deleteSubjectSafely(widget.subject!.subjectPk);
      if (mounted) Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.subject != null;
    final textLightColor = getColor(context, 'textLight');

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 12, 24, bottomInset + 24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const CashewSheetHandle(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEdit ? 'Chỉnh sửa môn học' : 'Thêm môn học mới',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (isEdit)
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        color: getColor(context, 'expenseAmount'),
                      ),
                      onPressed: _delete,
                      tooltip: 'Xoá môn học',
                    ),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên môn học',
                  hintText: 'Ví dụ: Lập trình di động',
                  prefixIcon: Icon(Icons.school_rounded),
                ),
                validator: (val) =>
                    (val == null || val.trim().isEmpty) ? 'Vui lòng nhập tên môn' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _codeController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Mã học phần',
                  hintText: 'Ví dụ: CSE441',
                  prefixIcon: Icon(Icons.tag_rounded),
                ),
                validator: (val) =>
                    (val == null || val.trim().isEmpty) ? 'Vui lòng nhập mã môn' : null,
              ),
              const SizedBox(height: 20),
              Text(
                'Màu sắc đại diện',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textLightColor,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _palette.map((colorValue) {
                  final isSelected = _selectedColor == colorValue;
                  return InkWell(
                    onTap: () => setState(() => _selectedColor = colorValue),
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Color(colorValue),
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 3)
                            : null,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Color(colorValue).withOpacity(0.5),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                )
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white, size: 20)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Text(
                'Biểu tượng môn học',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textLightColor,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _icons.map((iconKey) {
                  final isSelected = _selectedIcon == iconKey;
                  return InkWell(
                    onTap: () => setState(() => _selectedIcon = iconKey),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Color(_selectedColor).withOpacity(0.2)
                            : getColor(context, 'canvasContainer'),
                        borderRadius: BorderRadius.circular(16),
                        border: isSelected
                            ? Border.all(color: Color(_selectedColor), width: 1.5)
                            : null,
                      ),
                      child: Icon(
                        Formatters.getSubjectIconData(iconKey),
                        color: isSelected
                            ? Color(_selectedColor)
                            : textLightColor,
                        size: 22,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Color(_selectedColor),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _isLoading ? null : _save,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        isEdit ? 'Lưu thay đổi' : 'Tạo môn học',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
