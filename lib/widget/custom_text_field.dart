import 'package:flutter/material.dart';

// Create this custom text field widget in lib/widget/custom_text_field.dart
class CustomTextField extends StatelessWidget {
  final String? hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final double hintOpacity;
  final double fillOpacity;
  final controller;
  const CustomTextField({
    super.key,
    this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.hintOpacity = 0.4,
    this.fillOpacity = 0.5,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Color.fromARGB(255, 246, 211, 168).withOpacity(fillOpacity), // Match input background
        hintText: hintText,
        hintStyle: TextStyle(
          color: Color.fromARGB(255, 122, 51, 15).withOpacity(hintOpacity),

        ),
        suffixIcon: suffixIcon,
      ),
      keyboardType: keyboardType,
      controller: controller,
      style: TextStyle(
        color: Color.fromARGB(255, 163, 66, 16),
      ),
      obscureText: obscureText,

    );
  }
}