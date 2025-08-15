import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _form = GlobalKey<FormState>();
  final _auth = AuthService();
  bool _loading = false;

  Future<void> _register() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await _auth.registerEmail(_email.text.trim(), _pass.text.trim());
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Registrasi gagal: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Daftar')), body: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(20), child: ConstrainedBox(constraints: BoxConstraints(maxWidth: 600), child: Column(children: [
      Form(key: _form, child: Column(children: [
        TextFormField(controller: _email, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()), validator: (v) => v == null || !v.contains('@') ? 'Email tidak valid' : null),
        const SizedBox(height: 12),
        TextFormField(controller: _pass, obscureText: true, decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()), validator: (v) => v == null || v.length < 6 ? 'Min 6 karakter' : null),
        const SizedBox(height: 16),
        ElevatedButton(onPressed: _loading ? null : _register, style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlue), child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Daftar')),
      ])),
    ])))));
  }
}