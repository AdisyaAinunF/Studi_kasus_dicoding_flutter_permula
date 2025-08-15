import 'dart:async';

import 'package:flutter/material.dart';
import '../models/psychologist_model.dart';
import '../services/firestore_service.dart';
import '../widgets/psychologist_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final FirestoreService _fs = FirestoreService();

  final TextEditingController q = TextEditingController();
  Timer? _debounce;

  // semua data yang kita ambil dari Firestore
  List<PsychologistModel> all = [];

  // hasil pencarian yang di-render
  List<PsychologistModel> results = [];

  // status loading / error
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    // subscribe ke stream Firestore
    _fs.streamPsychologists().listen((list) {
      setState(() {
        all = list;
        _loading = false;
        _error = null;
        // jika ada query aktif, filter ulang
        if (q.text.trim().isNotEmpty) {
          _doSearch(q.text);
        }
      });
    }, onError: (e) {
      setState(() {
        _loading = false;
        _error = e?.toString() ?? 'Terjadi kesalahan';
      });
    });
  }

  @override
  void dispose() {
    q.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // debounce untuk menunda eksekusi search
  void search(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _doSearch(text);
    });
  }

  // fungsi pencarian sebenarnya (case-insensitive)
  void _doSearch(String t) {
    final s = t.toLowerCase().trim();
    if (s.isEmpty) {
      setState(() {
        results = [];
      });
      return;
    }
    final filtered = all.where((e) {
      final name = e.name.toLowerCase();
      final hospital = e.hospital.toLowerCase();
      return name.contains(s) || hospital.contains(s);
    }).toList();

    setState(() {
      results = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    final suggestions = all.take(3).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cari Psikolog'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // input pencarian
            TextField(
              controller: q,
              onChanged: search,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Cari nama atau rumah sakit',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: q.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          q.clear();
                          _doSearch('');
                        },
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 12),

            // handling loading / error
            if (_loading) ...[
              const SizedBox(height: 20),
              const Center(child: CircularProgressIndicator()),
            ] else if (_error != null) ...[
              const SizedBox(height: 20),
              Center(child: Text('Error: $_error')),
            ] else
              // content: kalau ada results tampilkan list, kalau kosong tampilkan suggestions/empty
              Expanded(
                child: results.isNotEmpty
                    ? ListView.builder(
                        itemCount: results.length,
                        itemBuilder: (ctx, i) {
                          final r = results[i];
                          return PsychologistCard(
                            p: r,
                            onTap: () => Navigator.pushNamed(context, '/detail',
                                arguments: r),
                            onFavorite: () => ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                                    content: Text('Favorit (simulasi)'))),
                          );
                        },
                      )
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            if (q.text.trim().isEmpty) ...[
                              // when query empty -> show suggestions
                              const Text('Mulai mencari psikolog',
                                  style: TextStyle(fontSize: 18)),
                              const SizedBox(height: 12),
                              const Text('Coba cari: Dr. Rina, Klinik Jiwa',
                                  style: TextStyle(color: Colors.grey)),
                              const SizedBox(height: 24),
                              const Text('Saran',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              // suggestion cards
                              ...suggestions.map((s) => PsychologistCard(
                                    p: s,
                                    onTap: () => Navigator.pushNamed(
                                        context, '/detail',
                                        arguments: s),
                                    onFavorite: () => ScaffoldMessenger.of(
                                            context)
                                        .showSnackBar(const SnackBar(
                                            content:
                                                Text('Favorit (simulasi)'))),
                                  )),
                              const SizedBox(height: 100),
                            ] else ...[
                              // query tidak kosong tapi hasil kosong -> empty state
                              const Text('Tidak ada hasil',
                                  style: TextStyle(fontSize: 18)),
                              const SizedBox(height: 12),
                              Text('Coba gunakan kata kunci lain',
                                  style: TextStyle(color: Colors.grey[600])),
                              const SizedBox(height: 24),
                              const Text('Saran',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              ...suggestions.map((s) => PsychologistCard(
                                    p: s,
                                    onTap: () => Navigator.pushNamed(
                                        context, '/detail',
                                        arguments: s),
                                    onFavorite: () => ScaffoldMessenger.of(
                                            context)
                                        .showSnackBar(const SnackBar(
                                            content:
                                                Text('Favorit (simulasi)'))),
                                  )),
                              const SizedBox(height: 100),
                            ]
                          ],
                        ),
                      ),
              ),
          ],
        ),
      ),
    );
  }
}
