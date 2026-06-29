import 'package:flutter/material.dart';

class AuthButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color color;

  const AuthButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(backgroundColor: color),
      child: Text(label),
    );
  }
}
