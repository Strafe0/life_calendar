import 'package:flutter/material.dart';
import 'package:life_calendar/calendar/week.dart';
import 'package:life_calendar/views/week/week_photo.dart';

class WeekPhotos extends StatelessWidget {
  const WeekPhotos({super.key,
    required this.selectedWeek,
    required this.removePhoto,
  });

  final Week selectedWeek;
  final Future<void> Function(String path) removePhoto;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int n = 3; // number of photos in one row of GridView
    double externalPadding = 12, internalPadding = 10; // padding in GridView
    double width = (screenWidth - 2 * externalPadding - 2 * internalPadding) / n; // width of one photo
    int photoNumber = selectedWeek.photos.length;
    int rowNumber = (photoNumber / 3).ceil();
    double gridHeight = width * rowNumber/* + internalPadding * (rowNumber + 1)*/;

    const double textPaddingBottom = 14;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: externalPadding),
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
          if (photoNumber == 0)
            const Text('Нет фото'),
          if (photoNumber > 0)
            const SizedBox(height: textPaddingBottom,),
          if (photoNumber > 0)
            SizedBox(
              height: gridHeight,
              child: GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: n,
                crossAxisSpacing: internalPadding,
                mainAxisSpacing: internalPadding,
                shrinkWrap: true,
                children: List.generate(
                  photoNumber, (index) => WeekPhoto(
                    photoPath: selectedWeek.photos[index],
                    removePhoto: removePhoto,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}