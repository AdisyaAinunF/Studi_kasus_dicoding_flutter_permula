// lib/screens/detail_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/psychologist_model.dart';
import '../models/appointment_model.dart';
import '../services/firestore_service.dart';
import '../widgets/safe_network_image.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key});
  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final FirestoreService _fs = FirestoreService();
  bool _booking = false;

  Future<void> _openBookingSheet(PsychologistModel p) async {
    // if not logged in -> go to login
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // arahkan ke login (atau tampilkan dialog)
      final go = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Perlu masuk'),
          content:
              const Text('Untuk membuat janji, silakan masuk terlebih dahulu.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Batal')),
            TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Masuk')),
          ],
        ),
      );
      if (go == true) {
        Navigator.pushNamed(context, '/login');
      }
      return;
    }

    DateTime? chosenDate;
    TimeOfDay? chosenTime;
    final noteCtrl = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: StatefulBuilder(builder: (ctx2, setInner) {
            String prettyDate() {
              if (chosenDate == null) return 'Pilih tanggal';
              return '${chosenDate!.day}/${chosenDate!.month}/${chosenDate!.year}';
            }

            String prettyTime() {
              if (chosenTime == null) return 'Pilih jam';
              return chosenTime!.format(ctx2);
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: Text('Buat Janji dengan ${p.name}',
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold))),
                        IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(ctx2)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Lokasi: ${p.hospital}'),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final d = await showDatePicker(
                              context: ctx2,
                              initialDate:
                                  DateTime.now().add(const Duration(days: 1)),
                              firstDate: DateTime.now(),
                              lastDate:
                                  DateTime.now().add(const Duration(days: 365)),
                            );
                            if (d != null) setInner(() => chosenDate = d);
                          },
                          child: Text(prettyDate()),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final t = await showTimePicker(
                                context: ctx2,
                                initialTime:
                                    const TimeOfDay(hour: 10, minute: 0));
                            if (t != null) setInner(() => chosenTime = t);
                          },
                          child: Text(prettyTime()),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 12),
                    TextField(
                      controller: noteCtrl,
                      minLines: 1,
                      maxLines: 3,
                      decoration: const InputDecoration(
                          labelText: 'Catatan (opsional)',
                          border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: (chosenDate == null || chosenTime == null)
                              ? null
                              : () async {
                                  // konfirmasi booking
                                  final combined = DateTime(
                                    chosenDate!.year,
                                    chosenDate!.month,
                                    chosenDate!.day,
                                    chosenTime!.hour,
                                    chosenTime!.minute,
                                  );

                                  // show loading
                                  setInner(() {});
                                  Navigator.pop(ctx2); // tutup sheet dulu
                                  await _createAppointment(
                                      p, combined, noteCtrl.text.trim());
                                },
                          child: const Text('Konfirmasi'),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 8),
                  ]),
            );
          }),
        );
      },
    );
  }

  Future<void> _createAppointment(
      PsychologistModel p, DateTime scheduledAt, String note) async {
    setState(() => _booking = true);
    try {
      final user = FirebaseAuth.instance.currentUser!;
      final appt = AppointmentModel(
        id: '',
        psychologistId: p.id,
        psychologistName: p.name,
        userId: user.uid,
        userName: user.displayName ?? (user.email ?? 'User'),
        scheduledAt: scheduledAt,
        note: note,
        createdAt: DateTime.now(),
        status: 'pending',
      );
      await _fs.createAppointment(appt);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Janji berhasil dibuat'),
          backgroundColor: Colors.green));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal membuat janji: $e')));
    } finally {
      setState(() => _booking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final PsychologistModel? p =
        ModalRoute.of(context)!.settings.arguments as PsychologistModel?;
    final sample = p ??
        PsychologistModel(
          id: '0',
          name: 'Direktori Psikolog',
          hospital: 'RS Umum',
          schedule: 'Senin - Jumat 09:00 - 17:00',
          imageUrl: 'https://picsum.photos/id/1005/800/400',
          rating: 4.7,
        );

    return Scaffold(
      appBar: AppBar(title: Text(sample.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SafeNetworkImage(url: sample.imageUrl, height: 220)),
          const SizedBox(height: 12),
          Text(sample.name,
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Row(children: [
            Icon(Icons.location_on, size: 18, color: Colors.grey[700]),
            const SizedBox(width: 6),
            Text(sample.hospital)
          ]),
          const SizedBox(height: 12),
          Text('Jadwal praktik: ${sample.schedule}',
              style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          const Text('Tentang Psikolog',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(
              'Psikolog berpengalaman dalam menangani kecemasan, depresi, dan konseling hubungan. Menerapkan terapi berbasis bukti dan pendekatan empatik untuk membantu klien mencapai kualitas hidup terbaik.'),
          const SizedBox(height: 16),
          Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8)),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    _StatItem(label: 'Kunjungan', value: '1.2k'),
                    _StatItem(label: 'Rating', value: '4.8'),
                    _StatItem(label: 'Pengalaman', value: '8 th'),
                  ])),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _booking ? null : () => _openBookingSheet(sample),
                child: _booking
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Buat Janji'),
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Simpan (simulasi)'))),
                child: const Text('Simpan')),
          ]),
        ]),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Column(children: [
        Text(value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text(label, style: TextStyle(color: Colors.grey[700]))
      ]);
}
