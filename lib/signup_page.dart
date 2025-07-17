import 'package:flutter/material.dart';
import 'package:foodapp/app_routes.dart';
import 'package:foodapp/core/colors/colors.dart';
import 'package:foodapp/core/textfield.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:foodapp/main.dart'; // For AppRoutes
import 'package:foodapp/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController retypePasswordController = TextEditingController();

  final AuthService _authService = AuthService();
  bool _isPasswordObscured = true;
  bool _isRetypePasswordObscured = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    retypePasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await _authService.registerWithEmailAndPassword(
        nameController.text.trim(),
        emailController.text.trim(),
        passwordController.text.trim(),
      );
      if (user != null && mounted) {
        context.go(AppRoutes.home);
      }
    } on FirebaseAuthException catch (e) { // Catch FirebaseAuthException directly
      if (mounted) {
        setState(() {
          // Map common Firebase Auth error codes to user-friendly messages
          switch (e.code) {
            case 'email-already-in-use':
              _errorMessage = 'This email is already registered. Please log in or use a different email.';
              break;
            case 'weak-password':
              _errorMessage = 'The password provided is too weak.';
              break;
            case 'invalid-email':
              _errorMessage = 'The email address is not valid.';
              break;
            default:
              _errorMessage = 'Registration failed: ${e.message}';
          }
        });
      }
    } on Exception catch (e) { // Catch any other unexpected exceptions
      if (mounted) {
        setState(() {
          _errorMessage = 'An unexpected error occurred: ${e.toString().replaceFirst('Exception: ', '')}';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView( // Added SingleChildScrollView for smaller screens
                      child: Column(
                        children: [
                          const SizedBox(height: 25), // Space from top of container
                          _buildTextFormField(
                            label: 'Name',
                            controller: nameController,
                            hintText: 'Enter your name',
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 15),
                          _buildTextFormField(
                            label: 'Email',
                            controller: emailController,
                            hintText: 'Enter your email',
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter an email';
                              }
                              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 15),
                          _buildTextFormField(
                            label: 'Password',
                            controller: passwordController,
                            hintText: 'Enter your password',
                            obscureText: _isPasswordObscured,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                            suffixIcon: IconButton(
                              icon: Icon(_isPasswordObscured ? Icons.visibility_off : Icons.visibility),
                              onPressed: () => setState(() => _isPasswordObscured = !_isPasswordObscured),
                            ),
                          ),
                          const SizedBox(height: 15),
                          _buildTextFormField(
                            label: 'Re-Type Password',
                            controller: retypePasswordController,
                            hintText: 'Confirm your password',
                            obscureText: _isRetypePasswordObscured,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm your password';
                              }
                              if (value != passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                            suffixIcon: IconButton(
                              icon: Icon(_isRetypePasswordObscured ? Icons.visibility_off : Icons.visibility),
                              onPressed: () => setState(() => _isRetypePasswordObscured = !_isRetypePasswordObscured),
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
                              onPressed: _isLoading ? null : _signUp,
                              child: _isLoading
                                  ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
                                  : Text(
                                      'SIGN UP',
                                      style: GoogleFonts.sen(fontSize: 16, color: Colors.white),
                                    ),
                            ),
                          ),
                          if (_errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: Text(
                                _errorMessage!,
                                style: GoogleFonts.sen(color: Colors.red, fontSize: 14),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          const SizedBox(height: 10),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    String? Function(String?)? validator,
    Widget? suffixIcon,
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
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            validator: validator,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            style: GoogleFonts.sen(color: Colors.black87, fontSize: 16),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: GoogleFonts.sen(color: Colors1.coolGrey),
              border: InputBorder.none,
              suffixIcon: suffixIcon,
              suffixIconColor: Colors1.coolGrey,
            ),
          ),
        ),
      ],
    );
  }
}