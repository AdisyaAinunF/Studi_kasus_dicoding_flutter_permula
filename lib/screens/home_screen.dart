import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/firestore_service.dart';
import '../models/psychologist_model.dart';
import '../widgets/psychologist_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _fs = FirestoreService();

  // fallback kosong jika tidak ada data
  final List<PsychologistModel> fallback = [];

  @override
  void initState() {
    super.initState();
    // seed data jika koleksi kosong (opsional untuk dev)
    _fs.seedIfEmpty().catchError((e) {
      debugPrint('Seed error: $e');
    });
  }

  Future<void> _openWhatsApp(String phone, {String? message}) async {
    // Pastikan nomor dalam format internasional tanpa + atau spasi:
    // Contoh Indonesia: +62 812-3456-7890 -> 6281234567890
    final cleanPhone = phone.replaceAll(RegExp(r'[\s+\-]'), '');
    final text = message ?? 'Halo, saya butuh bantuan dari SehatJiwaBDG.';
    final encoded = Uri.encodeComponent(text);

    final uriApp = Uri.parse('whatsapp://send?phone=$cleanPhone&text=$encoded');
    final uriWeb = Uri.parse('https://wa.me/$cleanPhone?text=$encoded');

    try {
      // Jika di web, langsung buka wa.me di browser (lebih andal)
      if (kIsWeb) {
        if (await canLaunchUrl(uriWeb)) {
          await launchUrl(uriWeb, mode: LaunchMode.externalApplication);
          return;
        }
      } else {
        // Coba buka aplikasi WhatsApp (mobile)
        if (await canLaunchUrl(uriApp)) {
          await launchUrl(uriApp);
          return;
        }

        // Kalau app tidak tersedia, coba buka wa.me (web)
        if (await canLaunchUrl(uriWeb)) {
          await launchUrl(uriWeb, mode: LaunchMode.externalApplication);
          return;
        }
      }

      // Kalau sampai sini, keduanya tidak bisa dibuka
      _showWhatsAppFallbackDialog(context, uriWeb.toString());
    } on PlatformException catch (e) {
      debugPrint('PlatformException openWhatsApp: $e');
      _showWhatsAppFallbackDialog(context, uriWeb.toString());
    } catch (e) {
      debugPrint('openWhatsApp failed: $e');
      _showWhatsAppFallbackDialog(context, uriWeb.toString());
    }
  }

  void _showWhatsAppFallbackDialog(BuildContext ctx, String url) {
    showDialog(
      context: ctx,
      builder: (dCtx) => AlertDialog(
        title: const Text('Bantuan via WhatsApp'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Tidak dapat membuka WhatsApp di perangkat ini.'),
            const SizedBox(height: 8),
            SelectableText(url, style: const TextStyle(fontSize: 13)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dCtx);
              Clipboard.setData(ClipboardData(text: url));
              ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Link disalin ke clipboard')));
            },
            child: const Text('Salin link'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dCtx);
              final uri = Uri.parse(url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } else {
                ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                    content: Text('Tidak dapat membuka browser')));
              }
            },
            child: const Text('Buka di browser'),
          ),
          TextButton(
              onPressed: () => Navigator.pop(dCtx), child: const Text('Tutup')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SehatJiwaBDG'), actions: [
        IconButton(
            onPressed: () => Navigator.pushNamed(context, '/search'),
            icon: const Icon(Icons.search)),
        IconButton(
            onPressed: () => Navigator.pushNamed(context, '/gallery'),
            icon: const Icon(Icons.photo_library)),
      ]),
      body: StreamBuilder<List<PsychologistModel>>(
        stream: _fs.streamPsychologists(),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snap.error}'));
          }
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final list =
              (snap.hasData && snap.data!.isNotEmpty) ? snap.data! : fallback;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(children: [
              // highlight card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFFEAF6FF), Colors.white]),
                    borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                        Text('Jaga Kesehatan Jiwamu',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text(
                            'Tips harian dan direktori psikolog terpercaya di Bandung.')
                      ])),
                  ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                          'https://picsum.photos/id/1005/120/120',
                          width: 88,
                          height: 88,
                          fit: BoxFit.cover)),
                ]),
              ),

              // quick actions
              Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(children: [
                    _quick(
                        icon: Icons.calendar_today,
                        label: 'Acara',
                        onTap: () => Navigator.pushNamed(context, '/detail')),
                    _quick(
                        icon: Icons.chat,
                        label: 'Bantuan',
                        onTap: () => _openWhatsApp('+6281312609696',
                            message:
                                'Halo, saya butuh bantuan mengenai SehatJiwaBDG.')),
                    _quick(
                        icon: Icons.book,
                        label: 'Direktori',
                        onTap: () => Navigator.pushNamed(context, '/detail')),
                    _quick(
                      icon: Icons.person,
                      label: 'Profile',
                      onTap: () => Navigator.pushNamed(context, '/profile'),
                    ),
                  ])),

              const SizedBox(height: 8),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Jadwal Praktik Terdekat',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('Lihat semua',
                            style: TextStyle(color: Colors.lightBlue))
                      ])),
              const SizedBox(height: 8),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: list.length,
                itemBuilder: (ctx, i) {
                  final d = list[i];
                  return PsychologistCard(
                      p: d,
                      onTap: () =>
                          Navigator.pushNamed(context, '/detail', arguments: d),
                      onFavorite: () => ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(
                              content:
                                  Text('Ditambahkan ke favorit (simulasi)'))));
                },
              ),
            ]),
          );
        },
      ),
    );
  }

  Widget _quick(
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return Expanded(
        child: InkWell(
            onTap: onTap,
            child: Column(children: [
              Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: Colors.lightBlue[50],
                      borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: Colors.lightBlue, size: 26)),
              const SizedBox(height: 6),
              Text(label)
            ])));
  }
}
