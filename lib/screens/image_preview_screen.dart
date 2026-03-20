
import 'package:flutter/material.dart';

class ImagePreviewScreen extends StatelessWidget {
  final String title;
  final String imageUrl;

  const ImagePreviewScreen({
    super.key,
    required this.title,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFC49B3B),
        title: Text(title),
      ),

      body: InteractiveViewer(
        child: Center(
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
