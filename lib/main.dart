import 'dart:async';
import 'package:flutter/material.dart';
import 'package:foodapp/access_location_page.dart';
import 'package:foodapp/core/colors/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:foodapp/loginpage.dart'; // Import LoginPage
import 'package:foodapp/signup_page.dart'; // Import SignupPage
import 'package:foodapp/forgot_password_page.dart'; // Import ForgotPasswordPage
import 'package:foodapp/verification_page.dart'; // Import VerificationPage
import 'package:go_router/go_router.dart'; // Import go_router

void main() {
  runApp(MyApp());
}

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup'; // Add signup route
  static const String forgotPassword = '/forgot-password'; // Add forgot password route
  static const String verification = '/verification'; // Add verification route
    static const String accessLocation = '/access-location'; // Add access location route

}

// 2. Create the GoRouter configuration
final GoRouter _router = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: <RouteBase>[
    GoRoute(
      path: AppRoutes.splash,
      builder: (BuildContext context, GoRouterState state) => MyHomePage(),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (BuildContext context, GoRouterState state) => OnboardingFlowScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (BuildContext context, GoRouterState state) =>  LoginPage(),
    ),
    GoRoute( // Add route for SignupPage
      path: AppRoutes.signup,
      builder: (BuildContext context, GoRouterState state) => const SignUpPage(),
    ),
    GoRoute( // Add route for ForgotPasswordPage
      path: AppRoutes.forgotPassword,
      builder: (BuildContext context, GoRouterState state) => const ForgotPasswordPage(),
    ),
    GoRoute( // Add route for VerificationPage
      path: AppRoutes.verification,
      builder: (BuildContext context, GoRouterState state) => const VerificationPage(),
    ),
      GoRoute( // Add route for AccessLocationPage
      path: AppRoutes.accessLocation,
      builder: (BuildContext context, GoRouterState state) => const AccessLocationPage(),
    ),
  ],
);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router( // 3. Use MaterialApp.router
      routerConfig: _router,
      title: 'Food App',
      theme: ThemeData(
        textTheme: GoogleFonts.senTextTheme(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    Timer(
        const Duration(seconds: 2),
        () => context.go(AppRoutes.onboarding)); // Use go_router for navigation
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        child: Image(image: AssetImage("assets/logo/logo.png")));
  }
}

// Data model for each onboarding page
class OnboardingPageData {
  final Widget mainVisualContent;
  final String title;
  final String description;
  final String progressIndicatorAsset;

  OnboardingPageData({
    required this.mainVisualContent,
    required this.title,
    required this.description,
    required this.progressIndicatorAsset,
  });
}

// Reusable UI widget for a single onboarding page
class OnboardingPageWidget extends StatelessWidget {
  final OnboardingPageData data;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const OnboardingPageWidget({
    Key? key,
    required this.data,
    required this.onNext,
    required this.onSkip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // Removed redundant BoxDecoration with white color, Scaffold handles it.
        child: Padding(
          padding: const EdgeInsets.only(top: 125, left: 24, right: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              data.mainVisualContent,
              SizedBox(height: 68),
              Text(
                data.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      // fontSize: 26, // headlineSmall likely has a good default
                    ),
              ),
              SizedBox(height: 15),
              Text(
                data.description,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 17,
                      color: Colors1.trueGrey,
                    ),
              ),
              SizedBox(height: 40),
              Image(
                image: AssetImage(data.progressIndicatorAsset),
                width: 85,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 80),
              Container(
                width: double.infinity,
                height: 62,
                child: ElevatedButton(
                  onPressed: onNext,
                  child: Text(
                    'Next',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          // fontSize: 14 // labelLarge likely has a good default
                        ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors1.primaryOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 15),
              TextButton(
                onPressed: onSkip,
                child: Text(
                  'Skip',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors1.slateGreyBlue,
                        fontSize: 17,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingFlowScreen extends StatefulWidget {
  @override
  _OnboardingFlowScreenState createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen> {
  int _currentPageIndex = 0;

  late final List<OnboardingPageData> _onboardingPages;

  @override
  void initState() {
    super.initState();
    _onboardingPages = [
      OnboardingPageData(
        mainVisualContent: Container(
          height: 325,
          width: 270,
          decoration: BoxDecoration(
              //
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                  image: AssetImage('assets/onboarding/1.png'),
                  fit: BoxFit.fitWidth)
              // Example: Add an image if you have one for the first page
              // image: DecorationImage(image: AssetImage("assets/onboarding_image_1.png"), fit: BoxFit.cover),
              ),
        ),
        title: 'All your favorites',
        description:
            'Get all your loved foods in one once place, you just place the order we do the rest',
        progressIndicatorAsset:
            'assets/slider/1.png', // Assuming you have 1.png, 2.png etc.
      ),
      OnboardingPageData(
        mainVisualContent: Container(
          height: 325,
          width: 270,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                  image: AssetImage('assets/onboarding/1.png'),
                  fit: BoxFit.fitWidth)),
         
        ),
        title: 'Fast & Reliable Delivery',
        description:
            'Your meals delivered to your doorstep quickly and safely.',
        progressIndicatorAsset:
            'assets/slider/2.png', // Make sure you have this asset
      ),
      OnboardingPageData(
        mainVisualContent: Container(
          height: 325,
          width: 270,
          // Example: Use a different color or image for page 3
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/onboarding/1.png'),
                fit: BoxFit.fitWidth),
            borderRadius: BorderRadius.circular(12),
          ),
          // Example: Different icon or image for page 3
          
        ),
        title: 'Order from chosen chef', // Updated title
        description:
            'Select your meal from a variety of professional chefs.', // Updated description
        progressIndicatorAsset:
            'assets/slider/3.png', // Make sure you have this asset
      ),
      OnboardingPageData(
        mainVisualContent: Container(
          height: 325,
          width: 270,
          // Example: Use a different color or image for page 4
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/onboarding/1.png'),
                fit: BoxFit.fitWidth),
            borderRadius: BorderRadius.circular(12),
          ),
          // Example: Different icon or image for page 4
          
        ),
        title: 'Free delivery offers', // Updated title
        description:
            'Enjoy free delivery on select orders and save more.', // Updated description
        progressIndicatorAsset:
            'assets/slider/4.png', // Make sure you have this asset
      ),
      // Add more OnboardingPageData objects for more screens
    ];
  }

  void _nextPage() {
    if (_currentPageIndex < _onboardingPages.length - 1) {
      setState(() {
        _currentPageIndex++;
      });
    } else {
      // Last page, navigate to home
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    context.go(AppRoutes.login); // Use go_router for navigation
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingPageWidget(
      data: _onboardingPages[_currentPageIndex],
      onNext: _nextPage,
      onSkip: _navigateToLogin,
    );
  }
}
