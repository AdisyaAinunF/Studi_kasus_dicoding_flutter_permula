import 'package:flutter/material.dart';
import '../screens/image_preview_screen.dart';

class MediaTile extends StatelessWidget {
  final String imageUrl;
  const MediaTile({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ImagePreviewScreen(url: imageUrl)),
        );
      },
      child: Hero(
        tag: imageUrl,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: Image.network(imageUrl, fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }
}