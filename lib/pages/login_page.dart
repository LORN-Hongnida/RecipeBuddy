import 'package:flutter/material.dart';
import 'package:recipe_app/widget/custom_text_field.dart';
import 'package:recipe_app/widget/back_button.dart';
import 'package:recipe_app/pages/signup_page.dart';
import 'package:recipe_app/widget/password_visibility_toggle.dart';
import 'package:recipe_app/services/auth_service.dart'; // Import AuthService
import 'package:recipe_app/pages/home_page.dart'; // Import HomePage
import 'package:recipe_app/pages/forgot_password_page.dart';
import 'package:recipe_app/widget/button_state.dart';
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService(); // Instance of AuthService
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;
  bool _isLoggingIn = false;
  String _errorMessage = '';
  bool _isButtonEnabled = false; // New state to track button enablement

  @override
  void initState() {
    super.initState();
    // Call _updateButtonState initially in case the fields have initial values
    _updateButtonState();
    // Add listeners to the text controllers to update the button state
    _fullNameController.addListener(_updateButtonState);
    _emailController.addListener(_updateButtonState);
    _passwordController.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _updateButtonState() {
    setState(() {
      _isButtonEnabled = _emailController.text.trim().isNotEmpty &&
          _passwordController.text.trim().isNotEmpty;
    });
  }

  Future<void> _handleLogin() async {
    if (!_isButtonEnabled || _isLoggingIn) {
      return; // Prevent login if button is disabled or already logging in
    }

    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();
    final String fullName = _fullNameController.text.trim();

    setState(() {
      _isLoggingIn = true;
      _errorMessage = '';
    });

    final String? errorCode = await _authService.signInWithEmailAndPassword( // Get the error code
      email,
      password,
    );

    setState(() {
      _isLoggingIn = false;
    });

    if (errorCode == null) {
      // Login successful
      print('Successfully logged in');
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } else {
      // String errorMessage = 'Login failed. Please check your email and password.';
      String errorMessage = '';
      switch (errorCode) {
        case 'invalid-email':
          errorMessage = 'Please enter a valid email address.';
        case 'invalid-credential':
          errorMessage = 'Incorrect email or password.';
          break;
        case 'sign-in-failed':
          errorMessage = 'An unexpected error occurred during login.';
          break;
        default:
          errorMessage = 'Login failed: $errorCode'; // Display the raw error code for debugging
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                const Text(
                  'Login',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                    color: Color.fromARGB(255, 233, 133, 82),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                const Text(
                  'Email',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _emailController, // Added controller
                  hintText: 'example@example.com',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Password',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _passwordController, // Added controller
                  hintText: '••••••••',
                  obscureText: _obscureText,
                  suffixIcon: PasswordVisibilityToggle(
                    isVisible: !_obscureText,
                    onToggleVisibility: _togglePasswordVisibility,
                  ),
                ),
                const SizedBox(height: 10),
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 20),
                ButtonState( // Replace with this
                  text: 'Log In',
                  isProcessing: _isLoggingIn,
                  isEnabled: _isButtonEnabled,
                  onPressed: _handleLogin,
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                        context, MaterialPageRoute(builder: (context) => ForgotPasswordPage())
                    );
                  },
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 30),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('or sign up with:', style: TextStyle(color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(icon: const Icon(Icons.camera_alt_outlined), onPressed: () {}),
                    IconButton(icon: const Icon(Icons.mail_outline), onPressed: () {}),
                    IconButton(icon: const Icon(Icons.facebook), onPressed: () {}),
                    IconButton(icon: const Icon(Icons.phone), onPressed: () {}),
                  ],
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Don\'t have an account? ', style: TextStyle(color: Colors.grey)),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                            context, MaterialPageRoute(builder: (context) => const SignupPage()));
                      },
                      child: const Text('Sign Up', style: TextStyle(color: Colors.orange)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const BackButtonOverlay(),
          if (_isLoggingIn)
            ModalBarrier(
              color: Colors.black.withOpacity(0.5),
              dismissible: false,
            ),
        ],
      ),
    );
  }
}