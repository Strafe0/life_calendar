import 'dart:io';

import 'package:flutter/material.dart';

class WeekPhoto extends StatelessWidget {
  const WeekPhoto({
    super.key,
    required this.photoPath,
    required this.removePhoto,
  });

  final String photoPath;
  final Future<void> Function(String path) removePhoto;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: const BorderRadius.all(Radius.circular(16.0)),
      elevation: 2.0,
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(16.0)),
        child: Image.file(
          File(photoPath),
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}

// Align(
// alignment: Alignment.topRight,
// child: Padding(
// padding: const EdgeInsets.all(6.0),
// child: SizedBox(
// height: 16,
// width: 16,
// child: IconButton(
// padding: EdgeInsets.zero,
// onPressed: () {},
// alignment: Alignment.center,
// icon: Container(
// decoration: BoxDecoration(
// color: Colors.white,
// borderRadius: BorderRadius.circular(100),
// ),
// alignment: Alignment.center,
// child: const Icon(
// Icons.close,
// color: Colors.black,
// size: 12,
// ),
// ),
// ),
// ),
// ),
// ),