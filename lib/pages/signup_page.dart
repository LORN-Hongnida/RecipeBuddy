import 'package:flutter/material.dart';
import 'package:recipe_app/pages/login_page.dart';
import 'package:recipe_app/pages/home_page.dart';
import 'package:recipe_app/widget/custom_text_field.dart';
import 'package:recipe_app/widget/back_button.dart';
import 'package:recipe_app/widget/password_visibility_toggle.dart';
import 'package:recipe_app/services/auth_service.dart';
import 'package:recipe_app/widget/button_state.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final AuthService _authService = AuthService();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _obscureText = true;
  bool _isSigningUp = false;
  String _errorMessage = '';
  bool _isButtonEnabled = false; // New state for button enablement

  @override
  void initState() {
    super.initState();
    _updateButtonState();
    _fullNameController.addListener(_updateButtonState);
    _emailController.addListener(_updateButtonState);
    _passwordController.addListener(_updateButtonState);
    _confirmPasswordController.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _updateButtonState() {
    setState(() {
      _isButtonEnabled = _fullNameController.text.trim().isNotEmpty &&
          _emailController.text.trim().isNotEmpty &&
          _passwordController.text.trim().isNotEmpty &&
          _passwordController.text.trim() == _confirmPasswordController.text.trim();
    });
  }

  Future<void> _handleSignUp() async {
    if (!_isButtonEnabled || _isSigningUp) {
      return;
    }

    if (_passwordController.text.trim() != _confirmPasswordController.text.trim()) {
      setState(() {
        _errorMessage = 'Passwords do not match.';
      });
      return;
    }

    final String fullName = _fullNameController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    setState(() {
      _isSigningUp = true;
      _errorMessage = '';
    });

    final String? errorCode = await _authService.signUpWithEmailAndPassword(
      fullName,
      email,
      password,
    );

    setState(() {
      _isSigningUp = false;
    });

    if (errorCode == null) {
      print('Successfully signed up');
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } else {
      String errorMessage = 'Sign up failed. Please try again.';
      switch (errorCode) {
        case 'invalid-email':
          errorMessage = 'Please enter a valid email address.';
          break;
        case 'email-already-in-use':
          errorMessage = 'This email address is already in use.';
          break;
        case 'weak-password':
          errorMessage = 'Password should be at least 6 characters.';
          break;
        case 'sign-up-failed':
          errorMessage = 'An unexpected error occurred during sign up.';
          break;
        default:
          errorMessage = 'Sign up failed: $errorCode';
          break;
      }
      setState(() {
        _errorMessage = errorMessage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 50),
                const Text(
                  'Signup',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                    color: Color.fromARGB(255, 233, 133, 82),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                const Text(
                  'Full Name',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _fullNameController,
                  hintText: 'John Doe',
                ),
                const SizedBox(height: 10),
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
                const SizedBox(height: 10),
                const Text(
                  'Password',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _passwordController,
                  hintText: '••••••••',
                  obscureText: _obscureText,
                  suffixIcon: PasswordVisibilityToggle(
                    isVisible: !_obscureText,
                    onToggleVisibility: _togglePasswordVisibility,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Confirm Password',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _confirmPasswordController,
                  hintText: '••••••••',
                  obscureText: _obscureText,
                  suffixIcon: PasswordVisibilityToggle(
                    isVisible: !_obscureText,
                    onToggleVisibility: _togglePasswordVisibility,
                  ),
                ),
                const SizedBox(height: 20),
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ButtonState(
                  text: 'Sign Up',
                  isProcessing: _isSigningUp,
                  isEnabled: _isButtonEnabled,
                  onPressed: _isButtonEnabled && !_isSigningUp ? () => _handleSignUp() : null,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account? ', style: TextStyle(color: Colors.grey)),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                            context, MaterialPageRoute(builder: (context) => const LoginPage()));
                      },
                      child: const Text('Log In', style: TextStyle(color: Colors.orange)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const BackButtonOverlay(),
          if (_isSigningUp)
            ModalBarrier(
              color: Colors.black.withOpacity(0.5),
              dismissible: false,
            ),
        ],
      ),
    );
  }
}
