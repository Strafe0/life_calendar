import 'dart:io';

import 'package:flutter/material.dart';
import 'package:life_calendar/calendar/week.dart';

class WeekPhotos extends StatelessWidget {
  const WeekPhotos({super.key, required this.selectedWeek});

  final Week selectedWeek;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int n = 3;
    double externalPadding = 12, internalPadding = 10;
    double width = (screenWidth - 2 * externalPadding - 2 * internalPadding) / n;
    int photoNumber = selectedWeek.photos.length;
    int rowNumber = (photoNumber / 3).ceil();
    double gridHeight = width * rowNumber + internalPadding * (rowNumber + 1);

    double textHeight = Theme.of(context).textTheme.titleMedium?.height ?? 20;
    const double textPaddingBottom = 14;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: externalPadding),
      child: SizedBox(
        height: gridHeight + textHeight + textPaddingBottom,
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Фото',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.start,
              ),
            ),
            const SizedBox(height: textPaddingBottom,),
            Expanded(
              child: GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: n,
                crossAxisSpacing: internalPadding,
                mainAxisSpacing: internalPadding,
                children: List.generate(
                  selectedWeek.photos.length,
                      (index) => Material(
                    borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                    // color: Colors.transparent,
                    elevation: 2.0,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                      child: Image.file(
                        File(selectedWeek.photos[index]),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}