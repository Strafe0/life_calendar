import 'dart:developer';
import 'dart:io';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:life_calendar/calendar/week.dart';
import 'package:life_calendar/utils/utility_variables.dart';
import 'package:life_calendar/utils/utility_functions.dart';
import 'package:life_calendar/setup.dart';
import 'package:life_calendar/database/database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';

class CalendarModel {
  late DateTime _birthday;
  late DateTime _mondayOfBirthdayWeek;
  final _db = getIt<AppDatabase>();
  late Week currentWeek;
  final List<Week> _weeks = [];

  Future<void> updateCurrentWeek() async {
    await _db.updateWeekStates();
    currentWeek = await currentWeekFromDb();

    if (DateTime.now().isAfter(currentWeek.end) || DateTime.now().isBefore(currentWeek.start)) {
      DateTime realCurrentMonday = previousMonday(DateTime.now());
      bool isCurrentWeekInPast = DateTime.now().isAfter(currentWeek.end) ? true : false;

      int realCurrentWeekIndex = _weeks.indexWhere((week) => datesIsTheSame(week.start, realCurrentMonday));
      Week realCurrentWeek = _weeks[realCurrentWeekIndex];

      for (int i = currentWeek.id; i != realCurrentWeek.id; isCurrentWeekInPast ? i++ : i--) {
        _weeks[i].state = isCurrentWeekInPast ? WeekState.past : WeekState.future;
      }

      for (int i = 0; i < realCurrentWeekIndex; i++) {
        _weeks[i].state = WeekState.past;
      }
      for (int i = realCurrentWeekIndex; i < _weeks.length; i++) {
        _weeks[i].state = WeekState.future;
      }

      realCurrentWeek.state = WeekState.current;
      // _weeks[currentWeek.id].state = isCurrentWeekInPast ? WeekState.past : WeekState.future;

      currentWeek = realCurrentWeek;
      await updateCurrentWeekInDb();
    }
  }

  Future<Week> currentWeekFromDb() async => await _db.getCurrentWeek();

  Future<void> updateCurrentWeekInDb() async => await _db.updateCurrentWeek(currentWeek.id);

  set selectedBirthday(DateTime dateTime) {
    _birthday = dateTime;
    _mondayOfBirthdayWeek = previousMonday(dateTime);
    // buildCalendar();
  }

  Future buildCalendar(bool firstTime) async {
    if (firstTime || (await _db.tableIsEmpty())) {
      await buildNewCalendar();
    } else {
      await buildFromDatabase();
    }
    await updateCurrentWeek();
  }

  DateTime get birthday => _birthday;
  DateTime get firstMonday => _mondayOfBirthdayWeek;
  DateTime get lastDay => _weeks.last.end;
  int get numberOfWeeks => _weeks.length;
  int get numberOfYears => _weeks.last.yearId + 1;

  int get currentWeekIndex =>
      weeksAmountBetweenMondays(DateTime.now(), _birthday);

  int get totalNumberOfWeeksInLife {
    DateTime maxAgeDate = DateTime(_birthday.year + userMaxAge + 1, _birthday.month, _birthday.day);
    return weeksAmountBetweenMondays(_birthday, maxAgeDate);
  }

  Future buildNewCalendar() async {
    int resultNumberOfWeeks = 0;
    var lastBirthday = _birthday;
    var yearMonday = previousMonday(lastBirthday);

    for (int yearIndex = 0; yearIndex < userMaxAge + 1; yearIndex++) {
      var nextBirthday = DateTime(lastBirthday.year + 1, lastBirthday.month, lastBirthday.day);
      // var yearSunday = previousMonday(nextBirthday).subtract(const Duration(days: 1));

      var weekMonday = DateTime(yearMonday.year, yearMonday.month, yearMonday.day);
      var weekSunday = DateTime(weekMonday.year, weekMonday.month, weekMonday.day + 6, 23, 59, 59);
      // var weekSunday = weekMonday.add(const Duration(days: 6));

      while (nextBirthday.isAfter(weekSunday)) {
        _weeks.add(Week(
          resultNumberOfWeeks,
          yearIndex,
          weekMonday,
          weekSunday,
          weekSunday.isBefore(DateTime.now()) ? WeekState.past : weekMonday.isBefore(DateTime.now()) ? WeekState.current : WeekState.future,
          WeekAssessment.poor,
          [],
          '',
        ));

        resultNumberOfWeeks++;
        weekMonday = DateTime(weekMonday.year, weekMonday.month, weekMonday.day + 7);
        // weekMonday = weekMonday.add(const Duration(days: 7));
        weekSunday = DateTime(weekSunday.year, weekSunday.month, weekSunday.day + 7, 23, 59, 59);
      }

      lastBirthday = nextBirthday;
      yearMonday = previousMonday(lastBirthday);
    }

    if (resultNumberOfWeeks == totalNumberOfWeeksInLife) {
      debugPrint('Number of weeks is the same');
    }

    if (!(await _db.tableIsEmpty())) {
      await _db.clearTable();
    }

    await _db.insertAllWeeks(_weeks);
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('firstTime', false);
  }

  Future buildFromDatabase() async {
    _weeks.clear();
    _weeks.addAll(await _db.getAllWeeks());
  }

  Week getWeek(int id) => _weeks[id];

  Future<Week> getWeekById(int id) => _db.getWeekById(id);

  List<Week> getWeeksInYear(int yearId) {
    List<Week> result = [];
    int lowerBound = yearId * 52;
    int upperBound = (yearId + 1) * 53;
    if (upperBound > _weeks.length) {
      upperBound = _weeks.length;
    }
    for (int id = lowerBound; id < upperBound; id++) {
      if (_weeks[id].yearId == yearId) {
        result.add(_weeks[id]);
      }
    }
    return result;
  }

  void updateAssessment(Week week) {
    _db.updateAssessment(week);
  }

  Future updateEvent(Week week) async {
    await _db.updateEvents(week);
  }

  Future updateGoal(Week week) async {
    await _db.updateGoals(week);
  }

  Future updateResume(Week week) async {
    await _db.updateResume(week);
  }

  Future updatePhoto(Week week) async {
    await _db.updatePhoto(week);
  }

  Future<File?> export() async {
    try {
      final zipFile = await _createZipFile();
      if (zipFile != null) {
        final Directory? sourceDir = await _createSourceDir();
        if (sourceDir != null) {
          await ZipFile.createFromDirectory(
            sourceDir: sourceDir,
            zipFile: zipFile,
            recurseSubDirs: true,
          );

          String formattedDate = dateFileFormat.format(DateTime.now());
          FileSaver.instance.saveAs(
            name: "life-calendar-$formattedDate",
            file: zipFile,
            ext: "zip",
            mimeType: MimeType.zip,
          );
        } else {
          return null;
        }
      }

      if (zipFile?.existsSync() ?? false) {
        return zipFile!;
      }
      return null;
    } catch (e, stackTrace) {
      log("Error creating archive during export", error: e, stackTrace: stackTrace);
      return null;
    }
  }

  Future<File?> _createZipFile() async {
    Directory? externalStorageDir = await getExternalStorageDirectory();
    if (externalStorageDir?.existsSync() ?? false) {
      File file = File("${externalStorageDir!.path}/life-calendar.zip");
      return file;
    } else {
      log("Error creating zip file in external storage directory");
      return null;
    }
  }

  Future<Directory?> _createSourceDir() async {
    Directory tempDir = await getTemporaryDirectory();
    Directory appDir = tempDir.parent;

    // creating the directory that will be archived
    Directory result = Directory("${appDir.path}/archive_source");
    if (result.existsSync()) {
      result.deleteSync(recursive: true);
    }
    result.createSync();

    // copying db to the directory
    File dbFile = File("${appDir.path}/databases/TheCalendarDatabase");
    if (dbFile.existsSync()) {
      dbFile.copySync("${result.path}/TheCalendarDatabase");
    } else {
      log("Creating archive", error: "DB file does not exist");
      return null;
    }

    // copying shared_prefs to the directory
    File sharedPrefsFile = File("${appDir.path}/shared_prefs/FlutterSharedPreferences.xml");
    if (sharedPrefsFile.existsSync()) {
      sharedPrefsFile.copySync("${result.path}/FlutterSharedPreferences.xml");
    } else {
      log("Creating archive", error: "SharedPrefs file does not exist");
      return null;
    }

    // copying images to the directory as archive
    File cacheArchive = File("${result.path}/cache_archive");
    await ZipFile.createFromDirectory(
      sourceDir: tempDir,
      zipFile: cacheArchive,
      recurseSubDirs: true,
      onZipping: (String filePath, bool isDirectory, double progress) {
        if (isDirectory && filePath.contains("WebView")) {
          return ZipFileOperation.skipItem;
        } else {
          return ZipFileOperation.includeItem;
        }
      },
    );

    return result;
  }

  Future<ImportResult> import() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ["zip"],
      );

      if (result != null) {
        File file = File(result.files.single.path!);

        Directory tempDir = await getTemporaryDirectory();
        Directory appDir = tempDir.parent;

        // creating a directory in which the archive will be extracted
        Directory archiveExtractDir = Directory("${appDir.path}/archive_source");
        if (archiveExtractDir.existsSync()) {
          archiveExtractDir.deleteSync(recursive: true);
        }
        archiveExtractDir.createSync();

        await ZipFile.extractToDirectory(
          zipFile: file,
          destinationDir: archiveExtractDir,
        );

        // replacing db
        File oldDbFile = File("${appDir.path}/databases/TheCalendarDatabase");
        oldDbFile.deleteSync(recursive: true);
        File newDbFile = File("${archiveExtractDir.path}/TheCalendarDatabase");
        newDbFile.copySync("${appDir.path}/databases/TheCalendarDatabase");

        // replacing shared_preferences
        File oldPrefs = File("${appDir.path}/shared_prefs/FlutterSharedPreferences.xml");
        oldPrefs.deleteSync(recursive: true);
        File newPrefs = File("${archiveExtractDir.path}/FlutterSharedPreferences.xml");
        newPrefs.copySync("${appDir.path}/shared_prefs/FlutterSharedPreferences.xml");

        // deleting old images
        tempDir.listSync().forEach((element) => element.deleteSync(recursive: true));

        // extracting new images
        File imageArchive = File("${archiveExtractDir.path}/cache_archive");
        await ZipFile.extractToDirectory(
          zipFile: imageArchive,
          destinationDir: tempDir,
        );

        return ImportResult.success;
      } else {
        return ImportResult.cancel;
      }
    } catch (error, stackTrace) {
      log("Import", error: error, stackTrace: stackTrace);
      return ImportResult.error;
    }
  }
}

enum ImportResult {
  success,
  cancel,
  error
}