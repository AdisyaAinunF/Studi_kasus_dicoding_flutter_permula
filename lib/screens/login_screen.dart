import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/social_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _form = GlobalKey<FormState>();
  final _auth = AuthService();
  bool _loading = false;

  Future<void> _login() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await _auth.signInEmail(_email.text.trim(), _pass.text.trim());
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Login gagal: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _google() async {
    setState(() => _loading = true);
    try {
      final cred = await _auth.signInWithGoogle();
      if (cred != null) Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Google gagal: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Masuk'), backgroundColor: Colors.white),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  const Text('SehatJiwaBDG',
                      style:
                          TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Form(
                    key: _form,
                    child: Column(children: [
                      TextFormField(
                          controller: _email,
                          decoration: const InputDecoration(
                              labelText: 'Email', border: OutlineInputBorder()),
                          validator: (v) => v == null || !v.contains('@')
                              ? 'Email tidak valid'
                              : null),
                      const SizedBox(height: 12),
                      TextFormField(
                          controller: _pass,
                          obscureText: true,
                          decoration: const InputDecoration(
                              labelText: 'Password',
                              border: OutlineInputBorder()),
                          validator: (v) => v == null || v.length < 6
                              ? 'Min 6 karakter'
                              : null),
                      const SizedBox(height: 16),
                      ElevatedButton(
                          onPressed: _loading ? null : _login,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.lightBlue),
                          child: _loading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text('Masuk')),
                    ]),
                  ),
                  const SizedBox(height: 12),
                  SocialButton(
                      onTap: _google,
                      label: 'Masuk dengan Google',
                      color: Colors.red,
                      icon: const Icon(Icons.g_mobiledata)),
                  const SizedBox(height: 8),
                  TextButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/register'),
                      child: const Text('Belum punya akun? Daftar'))
                ]),
          ),
        ),
      ),
    );
  }
}
