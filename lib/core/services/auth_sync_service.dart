import 'dart:async';
import 'dart:convert';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import '../database/app_database.dart';
import '../database/database_global.dart';

class GoogleUserProfile {
  final String email;
  final String displayName;
  final String? photoUrl;

  const GoogleUserProfile({
    required this.email,
    required this.displayName,
    this.photoUrl,
  });
}

class _GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  _GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}

class AuthSyncService extends ChangeNotifier {
  static final AuthSyncService _instance = AuthSyncService._internal();
  factory AuthSyncService() => _instance;
  AuthSyncService._internal() {
    _initGoogleSignIn();
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      drive.DriveApi.driveAppdataScope,
      drive.DriveApi.driveFileScope,
    ],
  );

  GoogleSignInAccount? _googleAccount;
  GoogleUserProfile? _user;
  DateTime? _lastSyncTime;
  bool _isSyncing = false;
  String? _lastError;

  bool get isLoggedIn => _user != null;
  GoogleUserProfile? get user => _user;
  DateTime? get lastSyncTime => _lastSyncTime;
  bool get isSyncing => _isSyncing;
  String? get lastError => _lastError;

  void _initGoogleSignIn() {
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      _googleAccount = account;
      if (account != null) {
        _user = GoogleUserProfile(
          email: account.email,
          displayName: account.displayName ?? account.email.split('@').first,
          photoUrl: account.photoUrl,
        );
      } else {
        _user = null;
      }
      notifyListeners();
    });

    // Try silent sign in on startup if user previously authenticated
    _googleSignIn.signInSilently().catchError((e) {
      // Ignore silent sign in failure (e.g. no internet or not signed in yet)
      return null;
    });
  }

  Future<bool> signInWithGoogle() async {
    _isSyncing = true;
    _lastError = null;
    notifyListeners();

    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        // User cancelled the sign-in modal
        _isSyncing = false;
        notifyListeners();
        return false;
      }

      _googleAccount = account;
      _user = GoogleUserProfile(
        email: account.email,
        displayName: account.displayName ?? account.email.split('@').first,
        photoUrl: account.photoUrl,
      );

      // Perform initial Google Drive synchronization
      await syncNow();
      return true;
    } on PlatformException catch (pe) {
      _lastError = 'Lỗi Google Sign-In (${pe.code}): ${pe.message ?? pe.toString()}';
      _isSyncing = false;
      notifyListeners();
      return false;
    } catch (e) {
      _lastError = 'Lỗi kết nối tài khoản Google: $e';
      _isSyncing = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    _googleAccount = null;
    _user = null;
    _lastSyncTime = null;
    _lastError = null;
    notifyListeners();
  }

  Future<bool> syncNow() async {
    if (_googleAccount == null) {
      _lastError = 'Chưa đăng nhập tài khoản Google';
      notifyListeners();
      return false;
    }

    _isSyncing = true;
    _lastError = null;
    notifyListeners();

    try {
      final authHeaders = await _googleAccount!.authHeaders;
      final authClient = _GoogleAuthClient(authHeaders);
      final driveApi = drive.DriveApi(authClient);

      // 1. Export local SQLite data to structured JSON
      final localSubjects = await database.subjectDao.getAllSubjects();
      final localDocs = await database.select(database.documents).get();
      final localDeleteLogs = await database.select(database.deleteLogs).get();

      final backupPayload = {
        'version': 2,
        'appName': 'StudyHub',
        'exportDate': DateTime.now().toIso8601String(),
        'subjects': localSubjects
            .map((s) => {
                  'subjectPk': s.subjectPk,
                  'name': s.name,
                  'code': s.code,
                  'color': s.color,
                  'icon': s.icon,
                  'dateCreated': s.dateCreated.toIso8601String(),
                  'dateTimeModified': s.dateTimeModified.toIso8601String(),
                })
            .toList(),
        'documents': localDocs
            .map((d) => {
                  'documentPk': d.documentPk,
                  'name': d.name,
                  'subjectFk': d.subjectFk,
                  'type': d.type.index,
                  'category': d.category.index,
                  'filePath': d.filePath,
                  'url': d.url,
                  'fileSize': d.fileSize,
                  'note': d.note,
                  'isPinned': d.isPinned,
                  'dateCreated': d.dateCreated.toIso8601String(),
                  'dateTimeModified': d.dateTimeModified.toIso8601String(),
                })
            .toList(),
        'deleteLogs': localDeleteLogs
            .map((l) => {
                  'deleteLogPk': l.deleteLogPk,
                  'entryPk': l.entryPk,
                  'type': l.type.index,
                  'dateTimeModified': l.dateTimeModified.toIso8601String(),
                })
            .toList(),
      };

      final jsonContent = jsonEncode(backupPayload);
      final bytes = utf8.encode(jsonContent);

      // 2. Query Google Drive for existing backup file
      const backupFileName = 'studyhub_backup.json';
      final fileList = await driveApi.files.list(
        q: "name = '$backupFileName' and trashed = false",
        spaces: 'drive',
        $fields: 'files(id, name, modifiedTime)',
      );

      final existingFiles = fileList.files ?? [];

      if (existingFiles.isNotEmpty) {
        // Update existing backup on Google Drive
        final existingFileId = existingFiles.first.id!;
        final media = drive.Media(
          Stream.value(bytes),
          bytes.length,
          contentType: 'application/json',
        );

        final updateFile = drive.File()
          ..name = backupFileName
          ..description = 'StudyHub Cashew Cloud Backup';

        await driveApi.files.update(
          updateFile,
          existingFileId,
          uploadMedia: media,
        );
      } else {
        // Create new backup file on Google Drive
        final media = drive.Media(
          Stream.value(bytes),
          bytes.length,
          contentType: 'application/json',
        );

        final newFile = drive.File()
          ..name = backupFileName
          ..description = 'StudyHub Cashew Cloud Backup';

        await driveApi.files.create(
          newFile,
          uploadMedia: media,
        );
      }

      _lastSyncTime = DateTime.now();
      _isSyncing = false;
      notifyListeners();
      return true;
    } catch (e) {
      _lastError = 'Lỗi đồng bộ Google Drive: $e';
      _isSyncing = false;
      notifyListeners();
      return false;
    }
  }
}

final authSyncService = AuthSyncService();
