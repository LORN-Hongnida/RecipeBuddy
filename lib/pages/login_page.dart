import 'package:flutter/material.dart';
import 'package:recipe_app/widget/rounded_button.dart';
import 'package:recipe_app/widget/custom_text_field.dart';
import 'package:recipe_app/widget/back_button.dart';
import 'package:recipe_app/pages/signup_page.dart';
import 'package:recipe_app/widget/password_visibility_toggle.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscureText = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
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
                const SizedBox(height: 50), // Add some initial spacing below the back button
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
                  hintText: '••••••••',
                  obscureText: _obscureText,
                  suffixIcon: PasswordVisibilityToggle(
                    isVisible: !_obscureText,
                    onToggleVisibility: _togglePasswordVisibility,
                  )
                ),
                const SizedBox(height: 30),
                RoundedButton(
                  text: 'Log In',
                  onPressed: () {
                    // Handle Log In action
                    print('Log In pressed');
                    // Navigator.push(...)
                  },
                  backgroundColor: Color.fromARGB(255, 233, 133, 82),
                  textColor: Colors.white,
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    // Handle Forgot Password? action
                    print('Forgot Password? pressed');
                    // Navigator.push(...)
                  },
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('or sign up with:', style: TextStyle(color: Colors.grey)),
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
                            context, MaterialPageRoute(builder: (context) => SignupPage())
                        );
                      },
                      child: const Text('Sign Up', style: TextStyle(color: Colors.orange)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const BackButtonOverlay( // Or your desired color
          ),
        ],
      ),
    );
  }
}