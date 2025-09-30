import 'package:flutter/material.dart';

class ImagePreviewScreen extends StatelessWidget {
  final String url;
  const ImagePreviewScreen({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Preview'),
      ),
      body: SafeArea(
        // Pastikan viewport SELALU selebar & setinggi layar yang tersedia
        child: SizedBox.expand(
          // FittedBox(BoxFit.contain) menjamin gambar selalu muat,
          // baik portrait maupun landscape — tidak akan overflow.
          child: FittedBox(
            fit: BoxFit.contain,
            child: Image.network(url),
          ),
        ),
      ),
    );
  }
}