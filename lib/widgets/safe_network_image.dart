import 'package:flutter/material.dart';

class SafeNetworkImage extends StatelessWidget {
  final String url;
  final double? width, height;
  final BoxFit fit;
  const SafeNetworkImage({super.key, required this.url, this.width, this.height, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return _placeholder();
    return Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (ctx, child, progress) {
        if (progress == null) return child;
        return SizedBox(height: height ?? 150, child: const Center(child: CircularProgressIndicator()));
      },
      errorBuilder: (ctx, err, st) => _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      width: width ?? double.infinity,
      height: height ?? 150,
      color: Colors.grey.shade200,
      child: const Center(child: Icon(Icons.broken_image, size: 40, color: Colors.grey)),
    );
  }
}