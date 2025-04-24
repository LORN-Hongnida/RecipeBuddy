// lib/widget/auth_button.dart
import 'package:flutter/material.dart';
import 'package:recipe_app/widget/rounded_button.dart';

class ButtonState extends StatelessWidget {
  final String text;
  final bool isProcessing;
  final bool isEnabled;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color textColor;

  const ButtonState({
    super.key,
    required this.text,
    this.isProcessing = false,
    this.isEnabled = true,
    this.onPressed,
    this.backgroundColor = const Color.fromARGB(255, 233, 133, 82),
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return RoundedButton(
      text: isProcessing ? '${text.replaceAll('Sign Up', 'Signing Up').replaceAll('Log In', 'Logging In')}...' : text,
      onPressed: isEnabled && !isProcessing ? onPressed : null,
      backgroundColor: backgroundColor,
      textColor: textColor,
      isDisabled: !isEnabled || isProcessing,
    );
  }
}