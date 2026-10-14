import 'dart:io';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:life_calendar/core/constants/constants.dart';
import 'package:life_calendar/core/extensions/string/file_string_extension.dart';
import 'package:life_calendar/core/logger/logger.dart';
import 'package:life_calendar/data/services/backup/backup_strategy.dart';
import 'package:life_calendar/data/services/database_service.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class CacheBackupStrategy implements BackupStrategy {
  const CacheBackupStrategy({required DatabaseService databaseService})
    : _databaseService = databaseService;

  final DatabaseService _databaseService;

  @override
  String get id => 'cache';

  @override
  Future<void> backup(Directory destinationDir) async {
    // Photos are persisted in the app documents directory (not the temporary
    // directory), so the canonical image library lives here.
    final appDocDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory(p.join(appDocDir.path, kImageDirName));

    // Always emit the archive (possibly empty) so restore is deterministic:
    // an empty archive unambiguously means "no photos".
    if (!imagesDir.existsSync()) {
      await imagesDir.create(recursive: true);
    }

    final cacheArchiveFile = File(
      p.join(destinationDir.path, 'cache_archive.zip'),
    );

    await ZipFile.createFromDirectory(
      sourceDir: imagesDir,
      zipFile: cacheArchiveFile,
      recurseSubDirs: true,
    );
  }

  @override
  Future<void> restore(Directory sourceDir) async {
    final cacheZip = File(p.join(sourceDir.path, 'cache_archive.zip'));
    final legacyCacheZip = File(p.join(sourceDir.path, 'cache_archive'));

    File? zipToExtract;
    if (cacheZip.existsSync()) {
      zipToExtract = cacheZip;
    } else if (legacyCacheZip.existsSync()) {
      zipToExtract = legacyCacheZip;
    }

    if (zipToExtract == null) {
      // No photo archive in this backup: leave the current library untouched.
      return;
    }

    final appDocDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory(p.join(appDocDir.path, kImageDirName));
    final stagingDir = Directory(p.join(appDocDir.path, 'temp_cache_dir'));

    try {
      // Extract into staging first; only touch the live library once the
      // archive has been successfully unpacked.
      if (stagingDir.existsSync()) {
        stagingDir.deleteSync(recursive: true);
      }
      // On Android an archive without photos extracts nothing and leaves the
      // folder uncreated, which made the listing below fail the import.
      stagingDir.createSync(recursive: true);
      await ZipFile.extractToDirectory(
        zipFile: zipToExtract,
        destinationDir: stagingDir,
      );

      // Replace semantics: wipe the current library, then repopulate from the
      // archive. A recursive search handles both the current format (images at
      // the archive root) and the legacy format (images nested in
      // sub-directories).
      if (imagesDir.existsSync()) {
        imagesDir.deleteSync(recursive: true);
      }
      imagesDir.createSync(recursive: true);

      for (final entity in stagingDir.listSync(recursive: true)) {
        if (entity is File && entity.path.isImage) {
          entity.copySync(p.join(imagesDir.path, p.basename(entity.path)));
        }
      }

      // Fix up photo paths in the DB
      await _databaseService.normalizePhotoPaths();
    } catch (e, s) {
      // Propagate so the import orchestrator can roll back the whole operation.
      logger.e('Failed to restore cache', error: e, stackTrace: s);
      rethrow;
    } finally {
      if (stagingDir.existsSync()) {
        try {
          stagingDir.deleteSync(recursive: true);
        } catch (e) {
          logger.w('Failed to clean up staging cache dir', error: e);
        }
      }
    }
  }
}
