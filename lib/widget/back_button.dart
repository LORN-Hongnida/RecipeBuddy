import 'package:flutter/material.dart';

class BackButtonOverlay extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? iconColor;
  final EdgeInsetsGeometry? padding;
  final double? iconSize;

  const BackButtonOverlay({
    super.key,
    this.onPressed,
    this.iconColor,
    this.padding = const EdgeInsets.all(10.0),
    this.iconSize = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0, // Access top using .top
      left: 15, // Access left using .left
      child: SafeArea(
        child: IconButton(
          padding: padding ?? EdgeInsets.zero,
          icon: Icon(
            Icons.arrow_back,
            color: iconColor ?? Color.fromARGB(255, 229, 100, 35),
            size: iconSize,
          ),
          onPressed: onPressed ?? () => Navigator.pop(context),
        ),
      ),
    );
  }
}