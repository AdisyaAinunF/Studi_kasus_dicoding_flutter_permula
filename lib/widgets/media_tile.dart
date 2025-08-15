import 'package:flutter/material.dart';
import 'safe_network_image.dart';

class MediaTile extends StatelessWidget {
  final String imageUrl;
  final VoidCallback onTap;
  const MediaTile({super.key, required this.imageUrl, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(borderRadius: BorderRadius.circular(8), child: SafeNetworkImage(url: imageUrl, fit: BoxFit.cover)),
    );
  }
}