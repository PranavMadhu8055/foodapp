import 'package:flutter/material.dart';
import 'package:foodapp/core/colors/colors.dart';
import 'package:foodapp/core/textfield.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:foodapp/main.dart'; // For AppRoutes

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController retypePasswordController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    retypePasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors1.darkSlateGrey,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: double.infinity,
              height: 170, // Adjusted height
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Create Account',
                    style: GoogleFonts.sen(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Text(
                      'Enter your details to sign up.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.sen(color: Colors.white70, fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20), // Added space before the white container
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30))),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SingleChildScrollView( // Added SingleChildScrollView for smaller screens
                    child: Column(
                      children: [
                        const SizedBox(height: 25), // Space from top of container
                        _buildTextField(label: 'Name', controller: nameController, hintText: 'Enter your name'),
                        const SizedBox(height: 15),
                        _buildTextField(label: 'Email', controller: emailController, hintText: 'Enter your email', keyboardType: TextInputType.emailAddress),
                        const SizedBox(height: 15),
                        _buildTextField(label: 'Password', controller: passwordController, hintText: 'Enter your password', obscureText: true),
                        const SizedBox(height: 15),
                        _buildTextField(label: 'Re-Type Password', controller: retypePasswordController, hintText: 'Confirm your password', obscureText: true),
                        const SizedBox(height: 35),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors1.primaryOrange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                            },
                            child: Text(
                              'SIGN UP',
                              style: GoogleFonts.sen(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Already have an account?", style: GoogleFonts.sen(color: Colors.grey[700])),
                            TextButton(
                              onPressed: () => context.go(AppRoutes.login),
                              child: Text(
                                'Login',
                                style: GoogleFonts.sen(color: Colors1.slateGreyBlue, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.sen(color: Colors.grey[700]),
        ),
        const SizedBox(height: 8),
        TextField1(
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            style: GoogleFonts.sen(color: Colors.black87, fontSize: 16),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: GoogleFonts.sen(color: Colors1.coolGrey),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}