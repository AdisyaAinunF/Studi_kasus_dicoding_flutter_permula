import 'package:flutter/material.dart';

class SocialButton extends StatelessWidget {
  final VoidCallback onTap;
  final String label;
  final Color color;
  final Widget icon;
  const SocialButton({super.key, required this.onTap, required this.label, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: icon,
      label: Text(label),
      style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white, minimumSize: const Size.fromHeight(46)),
    );
  }
}