import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';

class ImageViewer extends StatefulWidget {
  final List<String> imagePaths;
  final int initialIndex;
  final String noteId;
  const ImageViewer({
    Key? key,
    required this.imagePaths,
    required this.initialIndex,
    required this.noteId,
  }) : super(key: key);
  @override
  _ImageViewerState createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  late PageController _pageController;
  late int _currentIndex;
  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Image ${_currentIndex + 1} of ${widget.imagePaths.length}',
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.imagePaths.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return InteractiveViewer(
                panEnabled: true,
                boundaryMargin: EdgeInsets.all(20),
                minScale: 0.5,
                maxScale: 4,
                child: Center(
                  child: Image.file(
                    File(widget.imagePaths[index]),
                    fit: BoxFit.contain,
                  ),
                ),
              );
            },
          ),
          if (widget.imagePaths.length > 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_currentIndex > 0)
                    FloatingActionButton(
                      heroTag: 'prev',
                      mini: true,
                      backgroundColor: Colors.black54,
                      child: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        _pageController.previousPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                  SizedBox(width: 20),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      widget.imagePaths.length,
                      (index) => Container(
                        width: 8,
                        height: 8,
                        margin: EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              _currentIndex == index
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  if (_currentIndex < widget.imagePaths.length - 1)
                    FloatingActionButton(
                      heroTag: 'next',
                      mini: true,
                      backgroundColor: Colors.black54,
                      child: Icon(Icons.arrow_forward, color: Colors.white),
                      onPressed: () {
                        _pageController.nextPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                ],
              ),
            ),
        ],
      ),
      bottomSheet: Container(
        color: Colors.black,
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Row(mainAxisAlignment: MainAxisAlignment.center),
      ),
    );
  }
}
