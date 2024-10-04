import 'package:flutter/material.dart';
import 'package:life_calendar/ad_manager.dart';
import 'package:life_calendar/controllers/calendar_controller.dart';
import 'package:life_calendar/setup.dart';
import 'package:life_calendar/calendar/week.dart';
import 'package:life_calendar/utils/event_dialog.dart';
import 'package:life_calendar/utils/snackbar.dart';
import 'package:life_calendar/utils/text_dialog.dart';
import 'package:life_calendar/utils/utility_functions.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:life_calendar/views/week/week_assessment.dart';
import 'package:life_calendar/views/week/week_events.dart';
import 'package:life_calendar/views/week/week_goals.dart';
import 'package:life_calendar/views/week/week_photos.dart';
import 'package:life_calendar/views/week/week_resume.dart';
import 'package:yandex_mobileads/mobile_ads.dart';
import 'package:image_picker/image_picker.dart';

class WeekInfo extends StatefulWidget {
  const WeekInfo({super.key});

  @override
  State<WeekInfo> createState() => _WeekInfoState();
}

class _WeekInfoState extends State<WeekInfo> {
  final CalendarController controller = getIt<CalendarController>();
  final AdManager _adManager = AdManager();
  late BannerAd _banner;
  bool _bannerInitialized = false;
  double adHeight = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _banner = BannerAd(
        // adUnitId: 'demo-banner-yandex',
        adUnitId: 'R-M-2265467-1',
        adSize: adSize,
        adRequest: AdRequest(
          age: controller.age,
        ),
        onAdLoaded: () {
          if (!mounted) {
            _banner.destroy();
            return;
          }
          _banner.adSize.getCalculatedHeight().then((value) {
            setState(() {
              adHeight = value.toDouble();
            });
          });
        },
      );
      setState(() {
        _bannerInitialized = true;
      });
    });

    _adManager.createRewardedAdLoader();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _adManager.loadRewardedAd(age: controller.age, brightness: Theme.of(context).brightness);
    });
  }

  BannerAdSize get adSize {
    final screenWidth = MediaQuery.of(context).size.width.round();
    return BannerAdSize.sticky(width: screenWidth);
  }

  Week get week => controller.selectedWeek;

  @override
  Widget build(BuildContext context) {
    // rebuilds when keyboard appears
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Неделя ${formatDate(week.start)} - ${formatDate(week.end)}'),
        titleSpacing: 0,
        leadingWidth: 48,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 20.0,),
                  Assessment(
                    changeAssessment: controller.changeAssessment,
                    initialAssessment: week.assessment,
                  ),
                  const SizedBox(height: 20.0,),
                  WeekGoals(
                    selectedWeek: week,
                    changeGoalCompletion: controller.changeGoalCompletion,
                    changeGoalTitle: controller.changeGoalTitle,
                    deleteGoal: controller.deleteGoal,
                  ),
                  const SizedBox(height: 20.0,),
                  WeekEvents(
                    week: week,
                    deleteEvent: controller.deleteEvent,
                    changeEvent: controller.changeEvent,
                  ),
                  const SizedBox(height: 20.0,),
                  WeekPhotos(
                    selectedWeek: week,
                    removePhoto: (String photoPath) async {
                      await controller.deletePhoto(photoPath);
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 20.0,),
                  WeekResume(
                    week: week,
                    addResume: addResume,
                    deleteResume: controller.deleteResume,
                  ),
                  SizedBox(height: adHeight + 20,),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _bannerInitialized ? AdWidget(bannerAd: _banner) : null,
          ),
        ],
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        spaceBetweenChildren: 16,
        children: [
          SpeedDialChild(
            labelWidget: const Padding(
              padding: EdgeInsets.only(right: 20),
              child: Text('Итог'),
            ),
            child: const Icon(Icons.edit),
            onTap: addResume,
            backgroundColor: Theme.of(context).cardTheme.color,
            foregroundColor: Theme.of(context).colorScheme.primary,
            shape: const CircleBorder(),
          ),
          SpeedDialChild(
            labelWidget: const Padding(
              padding: EdgeInsets.only(right: 20),
              child: Text('Событие'),
            ),
            child: const Icon(Icons.calendar_today),
            onTap: onAddEventTap,
            backgroundColor: Theme.of(context).cardTheme.color,
            foregroundColor: Theme.of(context).colorScheme.primary,
            shape: const CircleBorder(),
          ),
          SpeedDialChild(
            labelWidget: const Padding(
              padding: EdgeInsets.only(right: 20),
              child: Text('Цель'),
            ),
            child: const Icon(Icons.check),
            onTap: onAddGoalTap,
            backgroundColor: Theme.of(context).cardTheme.color,
            foregroundColor: Theme.of(context).colorScheme.primary,
            shape: const CircleBorder(),
          ),
          SpeedDialChild(
            labelWidget: const Padding(
              padding: EdgeInsets.only(right: 20),
              child: Text('Фото'),
            ),
            child: const Icon(Icons.photo),
            onTap: onAddPhotoTap,
            backgroundColor: Theme.of(context).cardTheme.color,
            foregroundColor: Theme.of(context).colorScheme.primary,
            shape: const CircleBorder(),
          ),
        ],
      ),
    );
  }

  Future<void> onAddEventTap() async {
    if (week.events.length >= 3) {
      bool success = await _adManager.showAd(age: controller.age, brightness: Theme.of(context).brightness);

      if (success) {
        if (!mounted) return;
        addEvent();
      }
      return;
    }

    addEvent();
  }

  Future<void> addEvent() async {
    Event? newEvent = await eventDialog(context,
      initialDate: week.start,
      title: "Создание события",
      weekStartDate: week.start,
      weekEndDate: week.end,
    );
    if (newEvent != null) {
      controller.addEvent(newEvent);
    }
  }

  Future<void> onAddGoalTap() async {
    if (week.goals.length >= 3) {
      bool success = await _adManager.showAd(age: controller.age, brightness: Theme.of(context).brightness);

      if (success) {
        if (!mounted) return;
        addGoal();
      }
      return;
    }

    addGoal();
  }

  Future<void> addGoal() async {
    String? goalTitle = await textDialog(context, title: 'Создание цели');
    if (goalTitle != null && goalTitle.isNotEmpty) {
      controller.addGoal(goalTitle);
    }
  }

  Future<void> onAddPhotoTap() async {
    //TODO: add rewarded ad
    if (week.photos.length >= 3) {
      bool success = await _adManager.showAd(age: controller.age, brightness: Theme.of(context).brightness);

      if (success) {
        if (!mounted) return;
        addPhoto();
      }
      return;
    }

    addPhoto();
  }

  Future<void> addPhoto() async {
    ImagePicker picker = ImagePicker();

    XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      controller.addPhoto(file).then((value) => setState(() {}));
    } else {
      if (!mounted) return;
      showSnackBar(context, "Фото не добавлено");
    }
  }

  Future<void> addResume() async {
    String? newResume = await textDialog(context,
      title: "Запишите ваши мысли о неделе",
      initialText: week.resume,
    );
    if (newResume != null) {
      controller.addResume(newResume);
    }
  }
}
