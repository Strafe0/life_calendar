import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:life_calendar/core/l10n/app_localizations_extension.dart';
import 'package:life_calendar/ui/calendar/week_screen/bloc/week_cubit.dart';
import 'package:life_calendar/ui/calendar/week_screen/bloc/week_state.dart';
import 'package:life_calendar/ui/calendar/week_screen/widgets/photo_view/photo_viewer.dart';
import 'package:life_calendar/ui/calendar/week_screen/widgets/week_photos/photo_card.dart';

class WeekPhotoListWidget extends StatelessWidget {
  const WeekPhotoListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.only(left: 12, bottom: 4),
          sliver: SliverToBoxAdapter(
            child: Text(
              context.l10n.photos,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.start,
            ),
          ),
        ),
        BlocBuilder<WeekCubit, WeekState>(
          builder: (context, state) {
            final photos = state is WeekSuccess
                ? state.week.photos
                : <String>[];

            if (photos.isEmpty) {
              return SliverToBoxAdapter(
                child: Center(child: Text(context.l10n.noPhotos)),
              );
            }

            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              sliver: SliverGrid.builder(
                itemCount: photos.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemBuilder: (_, index) {
                  final path = photos[index];
                  return Hero(
                    tag: path,
                    child: PhotoCard(
                      photoUrl: path,
                      onPressed: () => _onPhotoPressed(context, photos, index),
                      onLongPressStart: (details) =>
                          _onLongPressStart(context, index, details),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  void _onPhotoPressed(
    BuildContext context,
    List<String> photos,
    int initialIndex,
  ) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, _, _) =>
            PhotoViewer(photoPathList: photos, initialIndex: initialIndex),
      ),
    );
  }

  void _onLongPressStart(
    BuildContext context,
    int index,
    LongPressStartDetails details,
  ) async {
    final offset = details.globalPosition;

    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy,
        offset.dx,
        offset.dy,
      ),
      items: [
        PopupMenuItem(
          onTap: () {
            context.read<WeekCubit>().deletePhoto(index);
          },
          child: Text(context.l10n.delete),
        ),
      ],
    );
  }
}
