import 'dart:async';
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _fs = FirestoreService();

  @override
  void initState() {
    super.initState();
    // seed sample data if empty
    _fs.seedIfEmpty();
    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, '/onboarding');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: const [
      Icon(Icons.mood, size: 80, color: Colors.lightBlue),
      SizedBox(height: 12),
      Text('SehatJiwaBDG', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
      SizedBox(height: 16),
      CircularProgressIndicator()
    ])));
  }
}