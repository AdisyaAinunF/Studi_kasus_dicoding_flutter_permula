import 'package:flutter/material.dart';
import '../widgets/safe_network_image.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController controller = PageController();
  int page = 0;
  final data = [
    {
      'image': 'https://picsum.photos/id/1015/800/400',
      'title': 'Kesehatan Mental Untuk Semua',
      'desc': 'Tips, dukungan, dan direktori psikolog di Bandung.'
    },
    {
      'image': 'https://picsum.photos/id/1025/800/400',
      'title': 'Cari Praktisi Profesional',
      'desc': 'Lihat jadwal praktik dan detail pengalaman mereka.'
    },
    {
      'image': 'https://picsum.photos/id/1035/800/400',
      'title': 'Bangun Kebiasaan Sehat',
      'desc': 'Panduan harian untuk menjaga kesehatan jiwa.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: controller,
                itemCount: data.length,
                onPageChanged: (i) => setState(() => page = i),
                itemBuilder: (ctx, i) {
                  final item = data[i];
                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SafeNetworkImage(
                            url: item['image']!,
                            height: MediaQuery.of(context).orientation ==
                                    Orientation.portrait
                                ? 260
                                : 180,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            item['title']!,
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            item['desc']!,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(data.length, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.all(6),
                  width: page == i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: page == i ? Colors.lightBlue : Colors.grey,
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  if (page < data.length - 1)
                    TextButton(
                      onPressed: () => controller.jumpToPage(data.length - 1),
                      child: const Text('Lewati'),
                    ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      if (page < data.length - 1) {
                        controller.nextPage(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        Navigator.pushReplacementNamed(context, '/login');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue),
                    child: Text(page < data.length - 1 ? 'Lanjut' : 'Mulai'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
