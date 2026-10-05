import 'package:flutter/material.dart';

/// Axis a single-finger gesture at rest scale is locked to once it clears the
/// direction slop, so a horizontal drawer pull and a vertical pull never fight.
enum _DragAxis { horizontal, vertical }

class CalendarInteractiveViewer extends StatefulWidget {
  const CalendarInteractiveViewer({
    super.key,
    required this.controller,
    required this.maxDragDistance,
    required this.onDragStart,
    required this.onDrag,
    required this.onDragEnd,
    required this.onHorizontalDragUpdate,
    required this.onHorizontalDragEnd,
    required this.child,
  });

  final TransformationController controller;
  final double maxDragDistance;
  final void Function() onDragStart;
  final void Function(double dragDistance) onDrag;
  final void Function(double dragDistance) onDragEnd;

  /// Continuous rightward travel (in logical pixels, from where the horizontal
  /// drag was claimed) while the calendar is at rest scale — used to pull the
  /// drawer out under the finger. There is no horizontal panning to do at
  /// scale 1, so the full-width gesture is free for the drawer.
  final void Function(double dx) onHorizontalDragUpdate;

  /// Release of a horizontal drag, with the horizontal fling velocity (px/s).
  final void Function(double velocityX) onHorizontalDragEnd;
  final Widget child;

  @override
  State<CalendarInteractiveViewer> createState() =>
      _CalendarInteractiveViewerState();
}

class _CalendarInteractiveViewerState extends State<CalendarInteractiveViewer>
    with SingleTickerProviderStateMixin {
  Offset? _initialFocalPoint;
  double? _scale = 1;
  double _dragDistance = 0;
  _DragAxis? _lockedAxis;
  double _horizontalOrigin = 0;

  // Travel (in logical pixels) before a gesture commits to an axis.
  static const _directionSlop = 18.0;

  late final AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_controllerListener);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  void _controllerListener() {
    _scale = widget.controller.value.getMaxScaleOnAxis();
  }

  bool get _isAtRestScale => ((_scale ?? 1) - 1).abs() < 0.001;

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      transformationController: widget.controller,
      onInteractionStart: (details) {
        _initialFocalPoint = details.focalPoint;
        _dragDistance = 0;
        _lockedAxis = null;
        widget.onDragStart();
      },
      onInteractionUpdate: (details) {
        if (!_isAtRestScale || details.pointerCount != 1) {
          return;
        }

        final initial = _initialFocalPoint ?? details.focalPoint;
        final dx = details.focalPoint.dx - initial.dx;
        final dy = details.focalPoint.dy - initial.dy;

        // Commit to an axis once the finger clears the slop, then stay on it
        // for the rest of the gesture.
        if (_lockedAxis == null) {
          if (dx.abs() < _directionSlop && dy.abs() < _directionSlop) {
            return;
          }
          if (dx.abs() > dy.abs()) {
            _lockedAxis = _DragAxis.horizontal;
            _horizontalOrigin = details.focalPoint.dx;
          } else {
            _lockedAxis = _DragAxis.vertical;
          }
        }

        if (_lockedAxis == _DragAxis.horizontal) {
          widget.onHorizontalDragUpdate(
            details.focalPoint.dx - _horizontalOrigin,
          );
          return;
        }

        _dragDistance = dy.clamp(
          -widget.maxDragDistance,
          widget.maxDragDistance,
        );
        widget.onDrag(_dragDistance);
      },
      onInteractionEnd: (details) {
        if (_lockedAxis == _DragAxis.horizontal) {
          widget.onHorizontalDragEnd(details.velocity.pixelsPerSecond.dx);
          _lockedAxis = null;
          return;
        }

        final dragDistance = _dragDistance;
        if (_isAtRestScale) {
          _animation =
              Tween<double>(begin: _dragDistance, end: 0).animate(
                CurvedAnimation(
                  parent: _animationController,
                  curve: Curves.easeOut,
                ),
              )..addListener(() {
                _dragDistance = _animation.value;
                widget.onDrag(_animation.value);
              });
          _animationController.forward(from: 0);
        }
        widget.onDragEnd(dragDistance);
        _lockedAxis = null;
      },
      minScale: 1,
      maxScale: 5,
      child: widget.child,
    );
  }

  @override
  void dispose() {
    widget.controller.removeListener(_controllerListener);
    _animationController.dispose();
    super.dispose();
  }
}
