import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:life_calendar/core/constants/constants.dart';
import 'package:life_calendar/core/logger/logger.dart';
import 'package:life_calendar/data/services/analytics/analytics_service_interface.dart';
import 'package:life_calendar/data/services/backup/backup_strategy.dart';
import 'package:life_calendar/data/services/shared_preferences_service.dart';
import 'package:life_calendar/domain/services/local_backup_service.dart';
import 'package:life_calendar/utils/result.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class LocalBackupServiceImpl implements LocalBackupService {
  const LocalBackupServiceImpl({
    required List<BackupStrategy> strategies,
    required AnalyticsService analytics,
    required SharedPreferencesService sharedPreferencesService,
  }) : _strategies = strategies,
       _analytics = analytics,
       _sharedPreferencesService = sharedPreferencesService;

  final List<BackupStrategy> _strategies;
  final AnalyticsService _analytics;
  final SharedPreferencesService _sharedPreferencesService;

  @override
  Future<bool> exportCalendar() async {
    File? zipFile;
    Directory? sourceDir;

    try {
      zipFile = await _createZipFile();
      if (zipFile == null) {
        return false;
      }

      // In case a leftover remains from a previous run
      if (zipFile.existsSync()) {
        zipFile.deleteSync();
      }

      sourceDir = await _createSourceDir();
      if (sourceDir == null) {
        return false;
      }

      // 1. Run the strategies
      // If an error is thrown here, we go straight to catch -> finally
      for (final strategy in _strategies) {
        await strategy.backup(sourceDir);
      }

      // 2. Archiving
      await ZipFile.createFromDirectory(
        sourceDir: sourceDir,
        zipFile: zipFile,
        recurseSubDirs: true,
      );

      // 3. Saving
      final formattedDate = fileDateFormat.format(DateTime.now());
      final resultPath = await FileSaver.instance.saveAs(
        name: 'life-calendar-$formattedDate',
        file: zipFile,
        fileExtension: 'zip',
        mimeType: MimeType.zip,
      );

      return resultPath != null;
    } catch (e, s) {
      logger.e('Failed to export calendar', error: e, stackTrace: s);
      return false;
    } finally {
      unawaited(_analytics.logBackup(BackupEvent.export));

      // Cleanup
      if (sourceDir != null && sourceDir.existsSync()) {
        try {
          sourceDir.deleteSync(recursive: true);
        } catch (e) {
          logger.w('Failed to clean up sourceDir', error: e);
        }
      }
      if (zipFile != null && zipFile.existsSync()) {
        try {
          zipFile.deleteSync();
        } catch (e) {
          logger.w('Failed to clean up zipFile', error: e);
        }
      }
    }
  }

  @override
  Future<Result<bool>> importCalendar() async {
    Directory? restoreTempDir;
    Directory? rollbackDir;
    // Tracks whether we have started mutating live state, so we only attempt a
    // rollback once there is something to revert.
    bool applyStarted = false;

    try {
      final pickedFile = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['zip'],
      );

      if (pickedFile == null) {
        logger.w('File was not picked');
        return const Result.ok(false);
      }

      final zipFile = File(pickedFile.path!);
      final docsDir = await getApplicationDocumentsDirectory();

      restoreTempDir = Directory(p.join(docsDir.path, 'restore_temp'));
      rollbackDir = Directory(p.join(docsDir.path, 'rollback_snapshot'));

      // Prepare clean folders
      _recreateDir(restoreTempDir);
      _recreateDir(rollbackDir);

      // 1. Extract the archive
      await ZipFile.extractToDirectory(
        zipFile: zipFile,
        destinationDir: restoreTempDir,
      );

      // 2. Snapshot the current live state into [rollbackDir] using the same
      // strategies. Because each strategy's backup/restore is a faithful
      // inverse pair, restoring this snapshot reverts the whole import as one
      // unit.
      for (final strategy in _strategies) {
        await strategy.backup(rollbackDir);
      }

      // 3. Apply the imported data (fail-fast). If any strategy throws, the
      // exception propagates to the outer catch, which rolls everything back.
      applyStarted = true;
      for (final strategy in _strategies) {
        logger.d('Starting restore strategy: ${strategy.id}');
        await strategy.restore(restoreTempDir);
      }

      // The imported data represents a fully set-up user, so force the
      // first-launch flags off. Older backups may predate these keys (which the
      // prefs restore wipes via clear()); left null they would send the user to
      // onboarding and make getUser() ignore the imported profile.
      await _sharedPreferencesService.setFirstLaunch(isFirstLaunch: false);
      await _sharedPreferencesService.setFirstLaunchV3(isFirstLaunch: false);

      return const Result.ok(true);
    } catch (error, stackTrace) {
      logger.e(
        'Failed to import calendar',
        error: error,
        stackTrace: stackTrace,
      );

      if (applyStarted && rollbackDir != null) {
        await _rollback(rollbackDir);
      }

      return Result.error(error);
    } finally {
      unawaited(_analytics.logBackup(BackupEvent.import));

      // Cleanup
      _safeDelete(restoreTempDir);
      _safeDelete(rollbackDir);
    }
  }

  /// Reverts a partially-applied import by restoring the pre-import snapshot.
  ///
  /// Best-effort: a failure here is logged but cannot itself be rolled back, so
  /// the original import error is still the one surfaced to the caller.
  Future<void> _rollback(Directory rollbackDir) async {
    try {
      for (final strategy in _strategies) {
        await strategy.restore(rollbackDir);
      }
      logger.i('Import rolled back to the pre-import snapshot');
    } catch (error, stackTrace) {
      logger.e(
        'Failed to roll back after a failed import',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  void _recreateDir(Directory dir) {
    if (dir.existsSync()) {
      dir.deleteSync(recursive: true);
    }
    dir.createSync(recursive: true);
  }

  void _safeDelete(Directory? dir) {
    if (dir != null && dir.existsSync()) {
      try {
        dir.deleteSync(recursive: true);
      } catch (e) {
        logger.w('Failed to clean up ${dir.path}', error: e);
      }
    }
  }

  Future<File?> _createZipFile() async {
    final externalStorageDir = await getApplicationCacheDirectory();
    return File(p.join(externalStorageDir.path, 'life-calendar.zip'));
  }

  Future<Directory?> _createSourceDir() async {
    try {
      final docsDir = await getApplicationDocumentsDirectory();
      final archiveDir = Directory(p.join(docsDir.path, 'archive_source'));

      if (archiveDir.existsSync()) {
        archiveDir.deleteSync(recursive: true);
      }
      archiveDir.createSync(recursive: true);
      return archiveDir;
    } catch (e) {
      logger.e('Critical error creating source dir', error: e);
      return null;
    }
  }
}
