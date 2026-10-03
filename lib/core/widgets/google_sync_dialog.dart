import 'package:flutter/material.dart';
import '../services/auth_sync_service.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';

class GoogleSyncDialog extends StatefulWidget {
  const GoogleSyncDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (ctx) => const GoogleSyncDialog(),
    );
  }

  @override
  State<GoogleSyncDialog> createState() => _GoogleSyncDialogState();
}

class _GoogleSyncDialogState extends State<GoogleSyncDialog> {
  @override
  void initState() {
    super.initState();
    authSyncService.addListener(_onAuthChange);
  }

  @override
  void dispose() {
    authSyncService.removeListener(_onAuthChange);
    super.dispose();
  }

  void _onAuthChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final textLightColor = getColor(context, 'textLight');
    final isLoggedIn = authSyncService.isLoggedIn;
    final user = authSyncService.user;
    final isSyncing = authSyncService.isSyncing;
    final lastError = authSyncService.lastError;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: getColor(context, 'lightDarkAccent'),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Row
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4285F4).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.cloud_sync_rounded,
                      color: Color(0xFF4285F4),
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tài khoản & Đồng bộ',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Google Drive Cloud Sync',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4285F4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Error banner if any
              if (lastError != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          lastError,
                          style: const TextStyle(fontSize: 12, color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              if (!isLoggedIn) ...[
                // Not logged in State
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: getColor(context, 'canvasContainer'),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: getColor(context, 'dividerColor'),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.offline_pin_rounded,
                          color: textLightColor, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Chưa đăng nhập. Toàn bộ tài liệu hiện đang được lưu an toàn tại bộ nhớ thiết bị của bạn.',
                          style: TextStyle(
                            fontSize: 13,
                            color: textLightColor,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Đăng nhập tài khoản Google thật để tự động sao lưu và đồng bộ CSDL tài liệu lên Google Drive. Nếu không đăng nhập, bạn vẫn dùng bình thường (Local-First).',
                  style: TextStyle(
                    fontSize: 13,
                    color: textLightColor,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                // Real Google Sign In Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1F1F1F),
                    elevation: 1,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(color: Color(0xFFDADCE0)),
                    ),
                  ),
                  onPressed: isSyncing
                      ? null
                      : () async {
                          final success = await authSyncService.signInWithGoogle();
                          if (context.mounted && success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Đăng nhập Google và đồng bộ Google Drive thành công!'),
                              ),
                            );
                          }
                        },
                  child: isSyncing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2),
                              child: const Icon(
                                Icons.g_mobiledata_rounded,
                                color: Color(0xFF4285F4),
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Đăng nhập bằng Google',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF3C4043),
                              ),
                            ),
                          ],
                        ),
                ),
              ] else ...[
                // Logged in State
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: getColor(context, 'canvasContainer'),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: getColor(context, 'dividerColor'),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: const Color(0xFF3F51B5),
                        backgroundImage: user?.photoUrl != null
                            ? NetworkImage(user!.photoUrl!)
                            : null,
                        child: user?.photoUrl == null
                            ? Text(
                                user?.displayName.substring(0, 1).toUpperCase() ?? 'G',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.displayName ?? '',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user?.email ?? '',
                              style: TextStyle(
                                fontSize: 13,
                                color: textLightColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF43A047),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        authSyncService.lastSyncTime != null
                            ? 'Google Drive: Đã đồng bộ lúc ${Formatters.formatDate(authSyncService.lastSyncTime!)}'
                            : 'Đang chuẩn bị đồng bộ...',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: textLightColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Real Google Drive Sync Button
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF3F51B5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: isSyncing
                      ? null
                      : () async {
                          final success = await authSyncService.syncNow();
                          if (context.mounted && success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Đồng bộ Google Drive thành công!'),
                              ),
                            );
                          }
                        },
                  icon: isSyncing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.sync_rounded),
                  label: Text(
                    isSyncing ? 'Đang đồng bộ Google Drive...' : 'Đồng bộ Google Drive ngay',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Sign Out Button
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: getColor(context, 'expenseAmount'),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    side: BorderSide(
                      color: getColor(context, 'expenseAmount').withValues(alpha: 0.5),
                    ),
                  ),
                  onPressed: () async {
                    await authSyncService.signOut();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đã đăng xuất Google')),
                      );
                    }
                  },
                  icon: const Icon(Icons.logout_rounded, size: 20),
                  label: const Text(
                    'Đăng xuất',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class GoogleProfileAppBarButton extends StatelessWidget {
  const GoogleProfileAppBarButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: authSyncService,
      builder: (context, _) {
        final isLoggedIn = authSyncService.isLoggedIn;
        final user = authSyncService.user;

        return IconButton(
          icon: isLoggedIn
              ? CircleAvatar(
                  radius: 14,
                  backgroundColor: const Color(0xFF3F51B5),
                  backgroundImage: user?.photoUrl != null
                      ? NetworkImage(user!.photoUrl!)
                      : null,
                  child: user?.photoUrl == null
                      ? Text(
                          user?.displayName.substring(0, 1).toUpperCase() ?? 'G',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                      : null,
                )
              : const Icon(Icons.account_circle_outlined, size: 26),
          tooltip: isLoggedIn
              ? 'Tài khoản: ${user?.displayName} (Google Drive Sync)'
              : 'Đăng nhập Google & Đồng bộ',
          onPressed: () => GoogleSyncDialog.show(context),
        );
      },
    );
  }
}
