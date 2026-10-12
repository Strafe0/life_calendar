import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_calendar/core/constants/constants.dart';
import 'package:life_calendar/domain/models/week/week_assessment/week_assessment.dart';
import 'package:life_calendar/domain/models/week/week_tense/week_tense.dart';
import 'package:life_calendar/ui/calendar/week_screen/widgets/week_assessment/week_assessment_ui_extension.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../support.dart';

void backupTests() {
  final l10n = l10nFor(english);
  final birthDate = DateTime(1995, 3, 14);

  int currentWeekId(WidgetTester tester) => calendarWeeks(
    tester,
  ).firstWhere((w) => w.week.tense == WeekTense.current).weekId;

  WeekAssessment assessmentOf(WidgetTester tester, int weekId) => calendarWeeks(
    tester,
  ).firstWhere((w) => w.weekId == weekId).week.assessment;

  Future<void> rateWeek(
    WidgetTester tester,
    int weekId,
    WeekAssessment assessment,
  ) async {
    await tapWeek(tester, weekId);
    await tapText(tester, assessment.label(l10n));
    await closeWeek(tester);
  }

  Future<void> exportCalendar(WidgetTester tester) async {
    await openMenu(tester);
    await tapText(tester, l10n.calendarExport);
    await pumpUntilFound(tester, find.text(l10n.archiveCreationSuccess));
    // Taps the barrier to close the dialog, then closes the menu.
    await tester.tapAt(const Offset(10, 10));
    await settle(tester);
    await closeMenu(tester);
  }

  Future<void> startImport(WidgetTester tester) async {
    await openMenu(tester);
    await tapText(tester, l10n.calendarImport);
    await tapText(tester, l10n.continueButton);
  }

  Future<void> restart(WidgetTester tester) async {
    await launchApp(tester, reset: false);
    await waitForCalendar(
      tester,
      (weeks) => weeks.last.yearId == 80,
      description: 'the calendar after a restart',
    );
  }

  group('Backup', () {
    // Most people have no photos, and an archive without them takes its own
    // path through the restore.
    for (final withPhoto in [false, true]) {
      final photos = withPhoto ? 'with a photo' : 'without photos';
      appTest('an exported calendar $photos is imported on a fresh install', (
        tester,
      ) async {
        final dialogs = await _fakeFileDialogs(tester);
        await launchRegistered(tester, birthDate: birthDate);
        final weekId = currentWeekId(tester);
        await rateWeek(tester, weekId, WeekAssessment.good);
        final photo = await _imageFile('photo.jpg');
        if (withPhoto) photo.writeAsBytesSync([1, 2, 3]);

        await exportCalendar(tester);
        expect(File(dialogs.saved).existsSync(), isTrue);

        // Someone else's calendar on a fresh install.
        await launchRegistered(tester, birthDate: DateTime(1990), lifeSpan: 60);
        expect(photo.existsSync(), isFalse);

        await startImport(tester);
        await waitForCalendar(
          tester,
          (weeks) => weeks.last.yearId == 80,
          description: 'the imported calendar',
        );
        await closeMenu(tester);

        void expectImported() {
          expect(assessmentOf(tester, weekId), WeekAssessment.good);
          expect(photo.existsSync(), withPhoto);
          if (withPhoto) expect(photo.readAsBytesSync(), [1, 2, 3]);
        }

        expectImported();
        await restart(tester);
        expectImported();
      });
    }

    appTest('a failed import rolls back to the data before it', (tester) async {
      final dialogs = await _fakeFileDialogs(tester);
      await launchRegistered(tester, birthDate: birthDate);
      final weekId = currentWeekId(tester);
      await rateWeek(tester, weekId, WeekAssessment.good);
      await exportCalendar(tester);

      // The database in this archive restores fine, then the settings fail,
      // so the import has to undo the database it already replaced.
      dialogs.toPick = await _breakSettings(dialogs.saved);
      await rateWeek(tester, weekId, WeekAssessment.bad);

      await startImport(tester);
      await pumpUntilFound(tester, find.text(l10n.errorImport));
      await tapText(tester, l10n.cancel);
      await closeMenu(tester);

      await restart(tester);
      expect(assessmentOf(tester, weekId), WeekAssessment.bad);
    });
  });
}

/// Answers the system save and open dialogs, which a test cannot tap: a save
/// keeps the archive in [saved], an open picks [toPick] (or [saved]).
class _FileDialogs {
  _FileDialogs(this.dir);

  final Directory dir;
  String? toPick;

  String get saved => p.join(dir.path, 'saved.zip');
}

Future<_FileDialogs> _fakeFileDialogs(WidgetTester tester) async {
  final temp = await getTemporaryDirectory();
  final dir = Directory(p.join(temp.path, 'backup_test'));
  if (dir.existsSync()) dir.deleteSync(recursive: true);
  dir.createSync(recursive: true);
  final dialogs = _FileDialogs(dir);

  const saver = MethodChannel('file_saver');
  const picker = MethodChannel('miguelruivo.flutter.plugins.filepicker');
  final messenger = tester.binding.defaultBinaryMessenger
    ..setMockMethodCallHandler(saver, (call) async {
      final source = (call.arguments as Map)['sourcePath'] as String;
      File(source).copySync(dialogs.saved);
      return dialogs.saved;
    })
    ..setMockMethodCallHandler(picker, (call) async {
      final path = dialogs.toPick ?? dialogs.saved;
      return [
        {
          'path': path,
          'name': p.basename(path),
          'size': File(path).lengthSync(),
        },
      ];
    });
  addTearDown(() {
    messenger
      ..setMockMethodCallHandler(saver, null)
      ..setMockMethodCallHandler(picker, null);
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });
  return dialogs;
}

Future<File> _imageFile(String name) async {
  final documents = await getApplicationDocumentsDirectory();
  final images = Directory(p.join(documents.path, kImageDirName))
    ..createSync(recursive: true);
  return File(p.join(images.path, name));
}

/// A copy of [archive] whose settings file is not valid JSON.
Future<String> _breakSettings(String archive) async {
  final parent = p.dirname(archive);
  final unpacked = Directory(p.join(parent, 'unpacked'))..createSync();
  await ZipFile.extractToDirectory(
    zipFile: File(archive),
    destinationDir: unpacked,
  );
  File(p.join(unpacked.path, 'shared_prefs.json')).writeAsStringSync('{');
  final broken = File(p.join(parent, 'broken.zip'));
  await ZipFile.createFromDirectory(sourceDir: unpacked, zipFile: broken);
  return broken.path;
}
