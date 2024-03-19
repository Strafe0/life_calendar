import 'dart:io';

import 'package:flutter/material.dart';
import 'package:life_calendar/calendar/week.dart';
import 'package:life_calendar/views/week/photo_view_gallery.dart';
import 'package:life_calendar/views/week/week_photo.dart';

class WeekPhotos extends StatefulWidget {
  const WeekPhotos({super.key,
    required this.selectedWeek,
    required this.removePhoto,
  });

  final Week selectedWeek;
  final Future<void> Function(String path) removePhoto;

  @override
  State<WeekPhotos> createState() => _WeekPhotosState();
}

class _WeekPhotosState extends State<WeekPhotos> {
  List<Widget> fullScreenPhotos = [];
  late final List<Widget> smallPhotos;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      fullScreenPhotos = updateFullScreenPhotos();
    });
  }

  @override
  void didUpdateWidget(covariant WeekPhotos oldWidget) {
    super.didUpdateWidget(oldWidget);
    fullScreenPhotos = updateFullScreenPhotos();
  }

  @override
  Widget build(BuildContext context) {
    const double textPaddingBottom = 14;

    return LayoutBuilder(
      builder: (context, constraints) {
        debugPrint("constraints: $constraints");

        double screenWidth = constraints.maxWidth;
        int n = 3; // number of photos in one row of GridView
        double externalPadding = 12, internalPadding = 10; // padding in GridView
        double width = (screenWidth - 2 * externalPadding - 2 * internalPadding) / n; // width of one photo
        int photoNumber = widget.selectedWeek.photos.length;
        int rowNumber = (photoNumber / 3).ceil();
        double gridHeight = width * rowNumber + internalPadding * (rowNumber - 1);

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
                      photoNumber,
                      (index) => GestureDetector(
                        onLongPressStart: (details) {
                          final offset = details.globalPosition;
                          final size = MediaQuery.of(context).size;
                          showMenu(
                            context: context,
                            position: RelativeRect.fromLTRB(
                              offset.dx,
                              offset.dy,
                              size.width - offset.dx,
                              size.height - offset.dy,
                            ),
                            items: <PopupMenuEntry>[
                              PopupMenuItem(
                                onTap: () async {
                                  await widget.removePhoto(widget.selectedWeek.photos[index]);
                                },
                                child: Text(
                                  'Удалить',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          );
                        },
                        onTap: () => Navigator.push(context, PhotoViewGallery.route(fullScreenPhotos, index)),
                        child: WeekPhoto(
                          photoPath: widget.selectedWeek.photos[index],
                          removePhoto: widget.removePhoto,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      }
    );
  }

  List<Widget> updateFullScreenPhotos() {
    return widget.selectedWeek.photos.map((photoPath) => Dismissible(
      key: Key(photoPath),
      direction: DismissDirection.down,
      dismissThresholds: const {DismissDirection.down: 0.2},
      onDismissed: (direction) => Navigator.pop(context),
      child: ColoredBox(
        color: Theme.of(context).colorScheme.background,
        child: Image.file(File(photoPath)),
      ),
    )).toList();
  }
}