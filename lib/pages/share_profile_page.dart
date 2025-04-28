import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ShareProfilePage extends StatelessWidget {
  final String username;

  const ShareProfilePage({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    // The QR code will encode the username (e.g., "@username")
    // You can modify this to encode a URL like "https://yourapp.com/profile/@username"
    final qrData = '@$username';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Share Profile',
          style: TextStyle(
            color: Color.fromARGB(255, 255, 108, 67),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color.fromARGB(255, 255, 108, 67)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Username
              Text(
                '@$username',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 255, 108, 67),
                ),
              ),
              const SizedBox(height: 20),
              // QR Code
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: 200.0,
                  foregroundColor: Color.fromARGB(255, 255, 108, 67),
                  errorCorrectionLevel: QrErrorCorrectLevel.M,
                ),
              ),
              const SizedBox(height: 20),
              // Instruction text
              Text(
                'Scan the QR code to view my profile',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}