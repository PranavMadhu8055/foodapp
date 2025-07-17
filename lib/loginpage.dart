import 'package:flutter/material.dart';
import 'package:foodapp/app_routes.dart';
import 'package:foodapp/core/colors/colors.dart';
import 'package:foodapp/core/textfield.dart';
// import 'package:foodapp/home_page.dart';
import 'package:go_router/go_router.dart';
import 'package:foodapp/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isPasswordObscured = true;
  bool _isLoading = false;
  String? _errorMessage;
  final AuthService _authService = AuthService();

  Future<void> _login() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await _authService.signInWithEmailAndPassword(
        emailController.text.trim(),
        passwordController.text.trim(),
        rememberMe: _rememberMe,
      );
      if (user != null && mounted) {
        context.go(AppRoutes.home);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          // Map common Firebase Auth error codes to user-friendly messages
          switch (e.code) {
            case 'user-not-found':
            case 'wrong-password':
              _errorMessage = 'Invalid email or password.';
              break;
            case 'invalid-email':
              _errorMessage = 'The email address is not valid.';
              break;
            case 'user-disabled':
              _errorMessage = 'This account has been disabled.';
              break;
            default:
              _errorMessage = 'Login failed: ${e.message}';
          }
        });
      }
    } on Exception catch (e) { // Catch any other unexpected exceptions
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
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
            Container(
              width: double.infinity,
              height: 220, // Adjusted height
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Text(
                    'Log In',
                    style: GoogleFonts.sen( // Using Sen Google Font
                      fontSize: 36, // Consistent font size
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20), // Added space before the white container
            Expanded(
              child: Container(
                width: double.infinity,
                // height: double.maxFinite,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30))),
                child: Padding(
                  // Added Padding for inner content
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 10), // Adjusted space at the top of the white container
                      Row(
                        children: [
                          Text(
                            'Email',
                            style: GoogleFonts.sen(color: Colors.grey[700]),
                          ),
                        ],
                      ),
                      TextField1(
                        child: TextField(
                              controller: emailController,
                              style: GoogleFonts.sen(color: Colors.black87),
                              decoration: InputDecoration(
                                // filled: true,
                                
                                // fillColor: Colors.grey[100], // Changed fillColor
                                hintText: 'example@gmail.com',
                                hintStyle: GoogleFonts.sen(color: Colors1.coolGrey),
                                border: InputBorder.none
                              ),
                            ),
                      ),
                        
                      const SizedBox(height: 20),
                             Row(
                        children: [
                          Text(
                            'Password',
                            style: GoogleFonts.sen(color: Colors.grey[700]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8), // Added space between label and text field
                      TextField1(
                        child: TextField(
                          controller: passwordController,
                          obscureText: _isPasswordObscured,
                          style: GoogleFonts.sen(color: Colors.black87),
                          decoration: InputDecoration( // Added decoration for password field
                            hintText: 'Password',
                            hintStyle: GoogleFonts.sen(color: Colors1.coolGrey),
                            suffixIcon: IconButton(
               
                              icon: Icon(
                                _isPasswordObscured ? Icons.visibility_off : Icons.visibility,
                                color: Colors1.coolGrey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordObscured = !_isPasswordObscured;
                                });
                              },
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: _rememberMe,
                                onChanged: (value) {
                                  setState(() {
                                    _rememberMe = value ?? false;
                                  });
                                },
                                activeColor: Colors1.primaryOrange,
                                checkColor: Colors
                                    .white, // Check color on orange background
                                side: BorderSide(
                                    color: Colors.grey[
                                        600]!), // Border for unchecked state on white
                              ),
                              Text(
                                'Remember me',
                                style: GoogleFonts.sen(
                                    color: Colors.grey[700]), // Changed color
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () {
                              context.go(AppRoutes.forgotPassword); // Navigate to forgot password page
                            },
                            child: Text(
                              'Forgot Password',
                              style: GoogleFonts.sen(color: Colors1.primaryOrange),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20), // Space after the "Forgot Password" row
                      Text(
                        'Please sign in to your existing account',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.sen(
                            color: Colors.grey[700], fontSize: 14),
                      ),
                      const SizedBox(height: 20), // Space before the LOG IN button
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
                          onPressed: _isLoading ? null : _login,
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
                              : Text(
                                  'LOG IN',
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
                          Text(
                            "Don’t have an account?",
                            style: GoogleFonts.sen(
                                color: Colors.grey[700]), // Changed color
                          ),
                          TextButton(
                            onPressed: () {
                              context.go(AppRoutes.signup); // Navigate to signup page
                            },
                            child: Text(
                              'SIGN UP',
                              style: GoogleFonts.sen(color: Colors1.primaryOrange),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25), // Adjusted space before "Or" divider
                      Row(
                        children: [
                          Expanded(
                              child: Divider(
                                  color: Colors.grey[300])), // Changed color
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              'Or',
                              style: GoogleFonts.sen(
                                  color: Colors.grey[700]), // Changed color
                            ),
                          ),
                          Expanded(
                              child: Divider(
                                  color: Colors.grey[300])), // Changed color
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SocialIconButton(icon: Icons.facebook),
                          const SizedBox(width: 20),
                          const SocialIconButton(icon: Icons.tiktok),
                          const SizedBox(width: 20),
                          const SocialIconButton(icon: Icons.apple),
                        ],
                      ),
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

class SocialIconButton extends StatelessWidget {
  final IconData icon;

  const SocialIconButton({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 25, // Changed background to be visible on white
      backgroundColor: Colors.grey[200],
      child: IconButton(
        icon: Icon(icon, color: Colors.black87),
        onPressed: () {},
      ),
    );
  }
}
