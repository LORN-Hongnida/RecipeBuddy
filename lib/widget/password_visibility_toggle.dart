import 'package:flutter/material.dart';

class PasswordVisibilityToggle extends StatelessWidget {
  final bool isVisible;
  final VoidCallback onToggleVisibility;

  const PasswordVisibilityToggle({
    super.key,
    required this.isVisible,
    required this.onToggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        isVisible ? Icons.visibility : Icons.visibility_off,
        color: Color.fromARGB(255, 122, 51, 15).withOpacity(0.4),
      ),
      onPressed: onToggleVisibility,

    );
  }
}