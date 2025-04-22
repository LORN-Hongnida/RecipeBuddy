import 'package:flutter/material.dart';
import 'package:recipe_app/pages/login_page.dart';
import 'package:recipe_app/pages/home_page.dart';
import 'package:recipe_app/widget/rounded_button.dart';
import 'package:recipe_app/widget/custom_text_field.dart';
import 'package:recipe_app/widget/back_button.dart';
import 'package:recipe_app/widget/password_visibility_toggle.dart';
import 'package:recipe_app/services/auth_service.dart';

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

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Future<void> _handleSignUp() async {
    if (_passwordController.text.trim() != _confirmPasswordController.text.trim()) {
      setState(() {
        _errorMessage = 'Passwords do not match.';
      });
      return;
    }

    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    setState(() {
      _isSigningUp = true;
      _errorMessage = '';
    });

    final String? errorCode = await _authService.signUpWithEmailAndPassword( // Changed the type here
      email,
      password,
    );

    setState(() {
      _isSigningUp = false;
    });

    if (errorCode == null) {
      // Sign up was successful, you likely need to fetch the User object differently now
      // For example, you can access it via _authService.currentUser if needed immediately after signup.
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
          errorMessage = 'Sign up failed: $errorCode'; // Display the raw error code for debugging
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
                  'Date of Birth',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const CustomTextField(
                  hintText: 'DD/MM/YY',
                  keyboardType: TextInputType.datetime,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'By continuing, you agree to ',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                Wrap(
                  alignment: WrapAlignment.center,
                  // crossAxisAlignment: WrapCrossAxisAlignment.center, // Removed potentially problematic line
                  children: [
                    InkWell(
                      onTap: () {
                        print('terms of use: clicked');
                      },
                      child: const Text('Terms of Use', style: TextStyle(color: Colors.black)),
                    ),
                    const Text(' and ', style: TextStyle(color: Colors.grey)),
                    InkWell(
                      onTap: () {
                        print('Privacy Policy is clicked.');
                      },
                      child: const Text(
                        'Privacy Policy.',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                RoundedButton(
                  text: _isSigningUp ? 'Signing Up...' : 'Sign Up',
                  onPressed: _isSigningUp ? null : _handleSignUp,
                  backgroundColor: const Color.fromARGB(255, 233, 133, 82),
                  textColor: Colors.white,
                  isDisabled: _isSigningUp, // Assuming your RoundedButton has this parameter
                ),
                const SizedBox(height: 20),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center, // Removed potentially problematic line
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