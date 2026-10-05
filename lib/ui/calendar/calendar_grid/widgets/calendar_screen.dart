import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:life_calendar/ui/calendar/calendar_grid/widgets/calendar_view.dart';
import 'package:life_calendar/ui/calendar/drawer/calendar_drawer_controller.dart';
import 'package:life_calendar/ui/calendar/drawer/widgets/calendar_drawer.dart';
import 'package:life_calendar/ui/core/themes/system_overlay_style.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _drawerAnim;
  late final CalendarDrawerController _drawerController;
  late final Animation<Offset> _drawerSlide;

  /// Mirrors "is the drawer showing at all" so the back-button handling only
  /// rebuilds when that flips, instead of on every animation tick.
  final _drawerOpen = ValueNotifier<bool>(false);

  static const _maxDrawerWidth = 360.0;
  static const _scrimOpacity = 0.6;

  @override
  void initState() {
    super.initState();
    _drawerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 246),
    )..addListener(_syncOpenState);
    _drawerController = CalendarDrawerController(_drawerAnim);
    _drawerSlide = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(_drawerAnim);
  }

  void _syncOpenState() {
    final isOpen = _drawerAnim.value > 0;
    if (_drawerOpen.value != isOpen) {
      _drawerOpen.value = isOpen;
    }
  }

  @override
  void dispose() {
    _drawerAnim.dispose();
    _drawerOpen.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // A back press closes the drawer while it is open, and only exits the
    // calendar once it is closed.
    return ValueListenableBuilder<bool>(
      valueListenable: _drawerOpen,
      builder: (context, isOpen, child) => PopScope(
        canPop: !isOpen,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) {
            _drawerController.close();
          }
        },
        child: child!,
      ),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: surfaceOverlayStyle(context),
        child: Scaffold(
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final drawerWidth = (constraints.maxWidth * 0.85).clamp(
                  0.0,
                  _maxDrawerWidth,
                );
                _drawerController.drawerWidth = drawerWidth;

                return RepositoryProvider<CalendarDrawerController>.value(
                  value: _drawerController,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CalendarView(constraints: constraints),
                      ),
                      Positioned.fill(child: _buildScrim()),
                      _buildDrawer(drawerWidth),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScrim() {
    return AnimatedBuilder(
      animation: _drawerAnim,
      builder: (context, _) {
        final value = _drawerAnim.value;
        if (value == 0) {
          return const SizedBox.shrink();
        }
        return GestureDetector(
          onTap: _drawerController.close,
          child: ColoredBox(
            color: Colors.black.withValues(alpha: _scrimOpacity * value),
          ),
        );
      },
    );
  }

  Widget _buildDrawer(double drawerWidth) {
    return Align(
      alignment: Alignment.centerLeft,
      // SlideTransition translates by a fraction of its child's size, so the
      // RepaintBoundary below must be the drawer-width box.
      child: SlideTransition(
        position: _drawerSlide,
        child: RepaintBoundary(
          child: GestureDetector(
            onHorizontalDragUpdate: (details) {
              _drawerAnim.value += (details.primaryDelta ?? 0) / drawerWidth;
            },
            onHorizontalDragEnd: (details) =>
                _drawerController.endDrag(details.primaryVelocity ?? 0),
            child: SizedBox(width: drawerWidth, child: const CalendarDrawer()),
          ),
        ),
      ),
    );
  }
}
