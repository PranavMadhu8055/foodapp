import 'package:flutter/material.dart';
import 'package:foodapp/core/colors/colors.dart';
import 'package:foodapp/core/textfield.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:foodapp/main.dart'; // For AppRoutes

class VerificationPage extends StatefulWidget {
  const VerificationPage({super.key});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  final TextEditingController codeController = TextEditingController();

  @override
  void dispose() {
    codeController.dispose();
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
              height: 190, // Adjusted height
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Verification',
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
                      'Enter the verification code sent to your email address.',
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
                  child: Column(
                    children: [ // Space from top of container
                      const SizedBox(height: 35),
                      Row(
                        children: [
                          Text(
                            'Verification Code',
                            style: GoogleFonts.sen(color: Colors.grey[700]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField1(
                        child: TextField(
                          controller: codeController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center, // Often codes are centered
                          style: GoogleFonts.sen(color: Colors.black87, fontSize: 18, letterSpacing: 8), // Added letter spacing for code-like feel
                          decoration: InputDecoration(
                            hintText: '------',
                            hintStyle: GoogleFonts.sen(color: Colors1.coolGrey, letterSpacing: 8),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
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
                            // Implement verification logic
                          },
                          child: Text(
                            'VERIFY',
                            style: GoogleFonts.sen(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                       TextButton(
                        onPressed: () {
                          // Implement resend code logic
                        },
                        child: Text(
                          'Resend Code',
                          style: GoogleFonts.sen(color: Colors1.slateGreyBlue, fontSize: 16),
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => context.go(AppRoutes.login), // Or navigate to where it makes sense
                        child: Text(
                          'Back to Login',
                          style: GoogleFonts.sen(color: Colors1.slateGreyBlue, fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 20),
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