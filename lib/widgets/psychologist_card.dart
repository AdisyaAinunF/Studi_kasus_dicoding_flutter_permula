import 'package:flutter/material.dart';
import '../models/psychologist_model.dart';
import 'safe_network_image.dart';

class PsychologistCard extends StatelessWidget {
  final PsychologistModel p;
  final VoidCallback onTap;
  final VoidCallback onFavorite;
  const PsychologistCard({super.key, required this.p, required this.onTap, required this.onFavorite});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            ClipRRect(borderRadius: BorderRadius.circular(8), child: SafeNetworkImage(url: p.imageUrl, width: 72, height: 72)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(p.hospital, style: TextStyle(color: Colors.grey[700])),
                const SizedBox(height: 6),
                Row(children: [const Icon(Icons.schedule, size: 14), const SizedBox(width: 6), Text(p.schedule, style: const TextStyle(fontSize: 12))])
              ]),
            ),
            Column(children: [
              IconButton(onPressed: onFavorite, icon: const Icon(Icons.favorite_border, color: Colors.pink)),
              Row(children: [const Icon(Icons.star, color: Colors.amber, size: 16), const SizedBox(width: 4), Text(p.rating.toString())])
            ])
          ]),
        ),
      ),
    );
  }
}
