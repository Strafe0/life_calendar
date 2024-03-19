import 'package:flutter/material.dart';

class PhotoViewGallery extends StatefulWidget {
  const PhotoViewGallery({
    super.key,
    required this.photos,
    required this.initialIndex,
  });

  final List<Widget> photos;
  final int initialIndex;

  static PageRouteBuilder route(List<Widget> photos, int initialIndex) =>
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) => PhotoViewGallery(
          photos: photos,
          initialIndex: initialIndex,
        ),
      );

  @override
  State<PhotoViewGallery> createState() => _PhotoViewGalleryState();
}

class _PhotoViewGalleryState extends State<PhotoViewGallery> with TickerProviderStateMixin {
  late PageController _pageController;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    _tabController = TabController(initialIndex: widget.initialIndex, length: widget.photos.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: widget.photos,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: TabPageSelector(
                controller: _tabController,
                color: Theme.of(context).colorScheme.background,
                selectedColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onPageChanged(int index) {
    _tabController.index = index;
  }
}

