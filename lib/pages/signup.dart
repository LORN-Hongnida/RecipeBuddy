import 'package:flutter/material.dart';
import 'package:recipe_app/pages/login.dart';
import 'package:recipe_app/widget/roundedButton.dart';
import 'package:recipe_app/widget/customTextField.dart';
import 'package:recipe_app/widget/backButton.dart';
import 'package:recipe_app/widget/passwordVisibilityToggle.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 50), // Add some initial spacing below the back button
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
                const CustomTextField(
                  hintText: 'John Doe',
                ),
                const SizedBox(height: 10),
                const Text(
                  'Email',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const CustomTextField(
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
                  hintText: '••••••••',
                  obscureText: _obscureText,
                  suffixIcon: PasswordVisibilityToggle(
                    isVisible: !_obscureText,
                    onToggleVisibility: _togglePasswordVisibility,
                  )
                ),
                const SizedBox(height: 10),
                const Text(
                  'Confirm Password',
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
                const SizedBox(height: 20),
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
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        print('terms of use: clicked');
                      },
                      child: const Text('Terms of Use', style: TextStyle(color: Colors.black)),

                    ),
                    const Text(
                        ' and ',
                        style: TextStyle(color: Colors.grey)
                    ),
                    InkWell(
                      onTap: () {
                        print('Privacy Policy is clicked.');
                      },
                      child: const Text('Privacy Policy.', style: TextStyle(color: Colors.black),),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                RoundedButton(
                  text: 'Sign Up',
                  onPressed: () {
                    // Handle Log In action
                    print('Log In pressed');
                    // Navigator.push(...)
                  },
                  backgroundColor: Color.fromARGB(255, 233, 133, 82),
                  textColor: Colors.white,
                ),


                const SizedBox(height: 10),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text('Already have an account? ', style: TextStyle(color: Colors.grey)),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                            context, MaterialPageRoute(builder: (context) => LoginPage()));
                      },
                      child: const Text('Log In', style: TextStyle(color: Colors.orange)),
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