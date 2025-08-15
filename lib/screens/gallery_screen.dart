import 'package:flutter/material.dart';
import '../widgets/media_tile.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});
  @override State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<String> media = [
    'https://picsum.photos/400/300?1',
    'https://picsum.photos/400/300?2',
    'https://picsum.photos/400/300?3',
    'https://picsum.photos/400/300?4'
  ];

  void _add() {
    setState(() => media.insert(0, 'https://picsum.photos/400/300?${DateTime.now().millisecondsSinceEpoch % 1000}'));
  }

  void _open(String url) {
    showDialog(context: context, builder: (ctx) => Dialog(child: Column(mainAxisSize: MainAxisSize.min, children: [Image.network(url), TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tutup'))])));
  }

  @override
  Widget build(BuildContext context) {
    final cross = MediaQuery.of(context).size.width > 600 ? 4 : 2;
    return Scaffold(
      appBar: AppBar(title: const Text('Galeri')),
      floatingActionButton: FloatingActionButton(onPressed: _add, child: const Icon(Icons.add)),
      body: Padding(padding: const EdgeInsets.all(12), child: Column(children: [
        Row(children: [Expanded(child: TextField(decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: 'Filter media (demo)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))))), const SizedBox(width: 8), ElevatedButton(onPressed: () => setState(() => media.shuffle()), child: const Text('Urut'))]),
        const SizedBox(height: 12),
        Expanded(child: GridView.count(crossAxisCount: cross, crossAxisSpacing: 8, mainAxisSpacing: 8, children: media.map((m) => MediaTile(imageUrl: m, onTap: () => _open(m))).toList()))
      ])),
    );
  }
}