import 'package:flutter/material.dart';
import 'package:foodapp/core/colors/colors.dart';
import 'package:foodapp/core/textfield.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:foodapp/main.dart'; // For AppRoutes

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
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
              height: 200, 
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Forgot Password',
                    style: GoogleFonts.sen(
                      fontSize: 32, // Slightly smaller for this context
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0), // Added padding for better text wrapping
                    child: Text(
                      'Please sign in to your existing account',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.sen(color: Colors.white70, fontSize: 15),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
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
                  child: Column(
                    children: [
                      const SizedBox(height: 30), // Space from top of container
                      Row(
                        children: [
                          Text(
                            'Email Address',
                            style: GoogleFonts.sen(color: Colors.grey[700]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField1(
                        child: TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: GoogleFonts.sen(color: Colors.black87),
                          decoration: InputDecoration(
                            hintText: 'Enter your email',
                            hintStyle: GoogleFonts.sen(color: Colors1.coolGrey),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
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
                            // Implement send code logic
                          },
                          child: Text(
                            'SEND CODE',
                            style: GoogleFonts.sen(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                      const Spacer(), // Pushes the back button to the bottom
                      TextButton(
                        onPressed: () => context.go(AppRoutes.login),
                        child: Text(
                          'Back to Login',
                          style: GoogleFonts.sen(color: Colors1.slateGreyBlue, fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 20), // Some padding at the bottom
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}