import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:life_calendar/core/constants/constants.dart';
import 'package:life_calendar/core/l10n/app_localizations.dart';

String getLocalizedHint({
  required String pattern,
  required AppLocalizations l10n,
  List<int>? segmentLengths,
}) {
  // 1. Find the char indices to determine the order (d, M, y)
  final dIndex = pattern.indexOf('d');
  final mIndex = pattern.indexOf('M');
  final yIndex = pattern.indexOf('y');

  final indexMap = <int, String>{};
  if (dIndex != -1) indexMap[dIndex] = 'd';
  if (mIndex != -1) indexMap[mIndex] = 'M';
  if (yIndex != -1) indexMap[yIndex] = 'y';

  // Sort: whichever appears earlier in the string comes first
  final sortedIndices = indexMap.keys.toList()..sort();

  // 2. Auto-detect lengths (ISO vs Local)
  List<int> effectiveLengths = segmentLengths ?? [];
  if (effectiveLengths.isEmpty) {
    // If the year comes before the day (yyyy-MM-dd), treat it as ISO
    final isYearFirst = yIndex != -1 && (dIndex == -1 || yIndex < dIndex);
    effectiveLengths = isYearFirst ? [4, 2, 2] : [2, 2, 4];
  }

  String result = pattern;

  // 3. Walk through in order and replace GROUPS of characters
  for (int i = 0; i < sortedIndices.length; i++) {
    // Safely get the length
    final length = (i < effectiveLengths.length)
        ? effectiveLengths[i]
        : (effectiveLengths.isNotEmpty ? effectiveLengths.last : 2);

    final charOriginalIndex = sortedIndices[i];
    final char = indexMap[charOriginalIndex]!;

    // Pick the localized symbol
    String localizedSymbol;
    switch (char) {
      case 'd':
        localizedSymbol = l10n.daySymbol;
      case 'M':
        localizedSymbol = l10n.monthSymbol;
      case 'y':
        localizedSymbol = l10n.yearSymbol;
      default:
        localizedSymbol = char;
    }

    result = result.replaceFirst(RegExp('$char+'), localizedSymbol * length);
  }

  return result;
}

DateFormat getLocalDateFormat(Locale locale) {
  return DateFormat.yMd(locale.toString());
}

String getLocalDateSeparator(Locale locale) {
  final dateFormat = getLocalDateFormat(locale);
  final pattern = dateFormat.pattern ?? dateFormatPattern;

  return getLocalDateSeparatorByPattern(pattern);
}

String getLocalDateSeparatorByPattern(String pattern) {
  // Determine the separator (first non-letter character)
  final separatorMatch = RegExp('[^a-zA-Z]').firstMatch(pattern);
  return separatorMatch?.group(0) ?? '.';
}
