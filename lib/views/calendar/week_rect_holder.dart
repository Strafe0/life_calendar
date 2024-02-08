import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

class WeekRectHolder {
  final List<WeekRect> _weekRects = [];

  void add(int id, Rect rect) => _weekRects.add(WeekRect(weekId: id, rect: rect));

  void clear() => _weekRects.clear();

  int? findWeekFromPoint(Offset offset) {
    return _weekRects
        .firstWhereOrNull((weekRect) =>
            weekRect.rect.left <= offset.dx &&
            offset.dx <= weekRect.rect.right &&
            weekRect.rect.top <= offset.dy &&
            offset.dy <= weekRect.rect.bottom)
        ?.weekId;
  }
}

class WeekRect {
  final int weekId;
  final Rect rect;

  WeekRect({required this.weekId, required this.rect});
}