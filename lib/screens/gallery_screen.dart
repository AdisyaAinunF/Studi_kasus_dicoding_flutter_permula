import 'package:flutter/material.dart';
import '../widgets/media_tile.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});
  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<String> media = const [
    'https://picsum.photos/1200/900?1',
    'https://picsum.photos/1200/900?2',
    'https://picsum.photos/1200/900?3',
    'https://picsum.photos/1200/900?4',
  ];

  void _add() {
    final q = DateTime.now().millisecondsSinceEpoch % 1000;
    setState(() {
      media = ['https://picsum.photos/1200/900?$q', ...media];
    });
  }

  @override
  Widget build(BuildContext context) {
    final cross = MediaQuery.of(context).size.width > 600 ? 4 : 2;

    return Scaffold(
      appBar: AppBar(title: const Text('Galeri')),
      floatingActionButton: FloatingActionButton(
        onPressed: _add,
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Filter media (demo)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => setState(() => media = [...media]..shuffle()),
                  child: const Text('Urut'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.count(
                crossAxisCount: cross,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                // ⬇️ TIDAK ada onTap lagi di sini
                children: media.map((m) => MediaTile(imageUrl: m)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}