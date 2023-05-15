import 'package:flutter/material.dart';
import 'package:life_calendar/views/calendar/calendar_widget.dart';
import 'package:life_calendar/controllers/calendar_controller.dart';
import 'package:life_calendar/setup.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> with SingleTickerProviderStateMixin {
  final CalendarController controller = getIt<CalendarController>();
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Календарь жизни в неделях'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(onPressed: () => Navigator.pushNamed(context, '/thanks'), icon: Icon(Icons.handshake_outlined, color: Theme.of(context).iconTheme.color)),
        ],
      ),
      body: InteractiveViewer(
        maxScale: 5,
        child: SafeArea(
          child: Stack(
            children: [
              CalendarWidget(),
              PositionedTransition(
                rect: RelativeRectTween(
                  begin: const RelativeRect.fromLTRB(0, 0, 0, 0),
                  end: RelativeRect.fromLTRB(0, MediaQuery.of(context).size.height, 0, 0),
                ).animate(_animationController),
                child: Container(color: Theme.of(context).colorScheme.background),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Перейти к текущей неделе',
        child: const Icon(Icons.location_searching),
        onPressed: () {
          var week = controller.currentWeek;
          controller.selectWeek(week.id, week.yearId);
          Navigator.pushNamed(context, '/weekInfo');
        },
      ),
    );
  }
}
