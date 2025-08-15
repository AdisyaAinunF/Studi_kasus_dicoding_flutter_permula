import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../models/appointment_model.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  final FirestoreService _fs = FirestoreService();
  User? user;
  Stream<List<AppointmentModel>>? _appointmentsStream;
  StreamSubscription<User?>? _authSub;

  @override
  void initState() {
    super.initState();
    // ambil current user awal
    user = FirebaseAuth.instance.currentUser;

    // listen auth changes — simpan subscription supaya bisa dibatalkan di dispose
    _authSub = FirebaseAuth.instance.authStateChanges().listen((u) {
      // cek mounted supaya tidak memanggil setState saat widget sudah dihapus
      if (!mounted) return;
      setState(() {
        user = u;
        // update stream jika user berubah
        _appointmentsStream =
            (user != null) ? _fs.streamUserAppointments(user!.uid) : null;
      });
    });

    // set initial stream jika user sudah ada saat init
    if (user != null) {
      _appointmentsStream = _fs.streamUserAppointments(user!.uid);
    }
  }

  @override
  void dispose() {
    // batalkan subscription auth agar tidak memanggil setState setelah dispose
    _authSub?.cancel();
    _authSub = null;
    super.dispose();
  }

  String _formatDateTime(DateTime dt) {
    final local = dt.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year;
    final hour = local.hour.toString().padLeft(2, '0');
    final min = local.minute.toString().padLeft(2, '0');
    return '$day/$month/$year  $hour:$min';
  }

  Future<void> _confirmCancel(AppointmentModel appt) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Batalkan Janji'),
        content: Text(
            'Apakah Anda yakin ingin membatalkan janji pada ${_formatDateTime(appt.scheduledAt)} dengan ${appt.psychologistName}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Tidak')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Ya, batalkan')),
        ],
      ),
    );

    if (yes == true) {
      try {
        await _fs.cancelAppointment(appt.id);
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Janji dibatalkan')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Gagal membatalkan: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Jika user belum login, tampilkan prompt masuk
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Janji Saya')),
        body: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text(
                'Silakan masuk terlebih dahulu untuk melihat janji Anda.'),
            const SizedBox(height: 12),
            ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                child: const Text('Masuk'))
          ]),
        ),
      );
    }

    // Jika ada stream (user login), gunakan StreamBuilder
    return Scaffold(
      appBar: AppBar(title: const Text('Janji Saya')),
      body: StreamBuilder<List<AppointmentModel>>(
        stream: _appointmentsStream,
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snap.error}'));
          }
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final list = snap.data ?? [];
          if (list.isEmpty) {
            return Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: const [
              Icon(Icons.calendar_month_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 12),
              Text('Belum ada janji', style: TextStyle(fontSize: 16)),
              SizedBox(height: 6),
              Text('Buat janji dengan psikolog dari halaman detail.')
            ]));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (ctx, i) {
              final a = list[i];
              return Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  leading: CircleAvatar(
                      child: Text(a.psychologistName.isNotEmpty
                          ? a.psychologistName[0].toUpperCase()
                          : 'P')),
                  title: Text(a.psychologistName),
                  subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('Tanggal: ${_formatDateTime(a.scheduledAt)}'),
                        const SizedBox(height: 4),
                        Text('Status: ${a.status}',
                            style: TextStyle(
                                color: a.status == 'cancelled'
                                    ? Colors.red
                                    : Colors.green)),
                      ]),
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) {
                      if (v == 'cancel') _confirmCancel(a);
                    },
                    itemBuilder: (c) => [
                      if (a.status != 'cancelled')
                        const PopupMenuItem(
                            value: 'cancel', child: Text('Batalkan')),
                      const PopupMenuItem(
                          value: 'details', child: Text('Detail')),
                    ],
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (dCtx) => AlertDialog(
                        title: Text(a.psychologistName),
                        content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Jadwal: ${_formatDateTime(a.scheduledAt)}'),
                              const SizedBox(height: 8),
                              Text(
                                  'Catatan: ${a.note.isNotEmpty ? a.note : '-'}'),
                              const SizedBox(height: 8),
                              Text('Status: ${a.status}'),
                            ]),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(dCtx),
                              child: const Text('Tutup'))
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
