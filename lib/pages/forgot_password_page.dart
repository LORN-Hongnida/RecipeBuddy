import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:recipe_app/widget/rounded_button.dart';
import 'package:recipe_app/widget/custom_text_field.dart';
import 'package:recipe_app/widget/back_button.dart';
import 'package:recipe_app/services/auth_service.dart'; // Import AuthService
import 'package:recipe_app/widget/button_state.dart';
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final AuthService _authService = AuthService(); // Instance of AuthService
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  String _message = '';
  bool _isButtonEnabled = false; // New state for button enablement

  @override
  void initState() {
    super.initState();
    // Call _updateButtonState initially in case the fields have initial values
    _updateButtonState();
    // Add listeners to the text controllers to update the button state
    _emailController.addListener(_updateButtonState);
  }
  Future<void> _handleSendPasswordResetEmail() async {
    final String email = _emailController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      setState(() {
        _message = 'Please enter a valid email address.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      await _authService.sendPasswordResetEmail(email);
      setState(() {
        _isLoading = false;
        _message = 'Password reset email sent. Check your inbox and spam folder.';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _message = 'Error sending password reset email. Please try again.';
        if (e is FirebaseException) {
          _message = 'Error: ${e.message}'; // Display Firebase specific error if available
        }
      });
    }
  }
  void _updateButtonState() {
    setState(() {
      _isButtonEnabled = _emailController.text.trim().isNotEmpty &&
          _emailController.text.trim().isNotEmpty;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButtonOverlay(), // Assuming BackButtonOverlay handles navigation
        title: const Text('Forgot Your Password', style: TextStyle(color: Color.fromARGB(255, 233, 133, 82))),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Hello There!',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 8),
            const Text(
              'Enter your email address. We will send you a link to reset your password.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),
            const Text(
              'Email',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _emailController,
              hintText: 'example@example.com',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            if (_message.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Text(
                  _message,
                  style: TextStyle(
                    color:  _message.contains('valid') ? Colors.red : _message.startsWith('Error') ? Colors.red : Colors.green,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            const Spacer(), // Push the button to the bottom
            // RoundedButton(
            //   text: _isLoading ? 'Sending...' : 'Continue',
            //   onPressed: _isLoading ? null : _handleSendPasswordResetEmail,
            //   backgroundColor: const Color.fromARGB(255, 233, 133, 82),
            //   textColor: Colors.white,
            //   isDisabled: _isLoading,
            // ),
            ButtonState(
              text: 'Sign Up',
              isProcessing: _isLoading,
              isEnabled: _isButtonEnabled,
              onPressed: _isButtonEnabled && !_isLoading ? () => _handleSendPasswordResetEmail() : null, // Wrapped in () =>
            ),
          ],
        ),
      ),
    );
  }
}