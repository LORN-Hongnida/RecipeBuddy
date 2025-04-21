import 'package:flutter/material.dart';

class ImageCard extends StatelessWidget {
  final String imageUrl;
  final VoidCallback? onTap;

  const ImageCard({
    super.key,
    required this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: onTap,
        child: AspectRatio(
          aspectRatio: 1, // To make them square
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
              if (loadingProgress == null) {
                return child;
              }
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
            errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
              return const Center(child: Icon(Icons.error_outline, color: Colors.red));
            },
          ),
        ),
      ),
    );
  }
}