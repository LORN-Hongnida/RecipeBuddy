import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed; // Make this nullable
  final Color? backgroundColor;
  final Color? textColor;
  final bool isDisabled; // Use a boolean for disabled state

  const RoundedButton({
    super.key,
    required this.text,
    this.onPressed, // Make this nullable
    this.backgroundColor,
    this.textColor,
    this.isDisabled = false, // Default to enabled
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isDisabled ? null : onPressed, // Disable onPressed if isDisabled is true
      style: ElevatedButton.styleFrom(
        backgroundColor: isDisabled
            ? Colors.grey // Or your desired disabled color
            : (backgroundColor ?? const Color.fromARGB(255, 246, 211, 168)),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 18,
          color: isDisabled
              ? Colors.white // Or your desired disabled text color
              : (textColor ?? const Color.fromARGB(255, 233, 133, 82)),
        ),
      ),
    );
  }
}