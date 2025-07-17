import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'package:foodapp/access_location_page.dart';
import 'package:foodapp/core/colors/colors.dart';
import 'package:foodapp/cart_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:foodapp/loginpage.dart'; // Import LoginPage
import 'package:foodapp/signup_page.dart'; // Import SignupPage
import 'package:foodapp/forgot_password_page.dart'; // Import ForgotPasswordPage
import 'package:foodapp/favorite_items_page.dart'; // Import FavoriteItemsPage
import 'package:foodapp/verification_page.dart'; // Import VerificationPage
import 'package:foodapp/app_routes.dart';
import 'package:foodapp/menu_item_details_page.dart';
import 'package:foodapp/firebase_options.dart'; // Import the generated options
import 'package:foodapp/providers/user_profile_provider.dart';
import 'package:foodapp/providers/restaurant_provider.dart'; // Import your provider
import 'package:foodapp/models/restaurant_data.dart';
import 'package:foodapp/restaurant_details_page.dart';
import 'package:go_router/go_router.dart'; // Import go_router
import 'package:foodapp/my_orders_page.dart'; // Import MyOrdersPage
import 'package:foodapp/home_page.dart';
import 'package:foodapp/my_reviews_page.dart';
import 'package:foodapp/screens/address_management_screens.dart';
import 'package:foodapp/order_details_page.dart';
import 'package:foodapp/personal_profile_screen.dart'; // Import the new screen
import 'package:provider/provider.dart'; // Import provider package
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:foodapp/services/auth_service.dart'; // Import AuthService

// 1. Wrap your runApp with ChangeNotifierProvider
void main() async { // Make main async
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => RestaurantProvider()),
        ChangeNotifierProvider(create: (context) => UserProfileProvider()),
      ],
      child: MyApp(),
    ),
  );
}

// 2. Create the GoRouter configuration
final GoRouter _router = GoRouter(
  initialLocation: AppRoutes.splash, // Keep splash as initial, it will redirect
  routes: <RouteBase>[
      GoRoute(
       name: 'home',
        path: AppRoutes.home,
        builder: (context, state) => const FoodDeliveryApp(),
      ),
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
    GoRoute(
      path: AppRoutes.restaurantDetails,
      builder: (BuildContext context, GoRouterState state) {
        final restaurant = state.extra as Restaurant;
        return RestaurantDetailsPage(restaurant: restaurant);
      },
    ),
    GoRoute(
      path: AppRoutes.menuItemDetails,
      builder: (BuildContext context, GoRouterState state) {
        final data = state.extra as Map<String, dynamic>;
        final menuItem = data['menuItem'] as MenuItem;
        final restaurant = data['restaurant'] as Restaurant;
        return MenuItemDetailsPage(menuItem: menuItem, restaurant: restaurant);
      },
    ),
    GoRoute(
      path: AppRoutes.cart,
      builder: (BuildContext context, GoRouterState state) => const CartPage(),
    ),
    GoRoute(
      path: AppRoutes.favorites,
      builder: (BuildContext context, GoRouterState state) => const FavoriteItemsPage(),
    ),
    GoRoute(
      path: AppRoutes.personalInfo,
      builder: (BuildContext context, GoRouterState state) => const PersonalProfileScreen(),
    ),
    GoRoute(
      path: AppRoutes.myOrders,
      builder: (BuildContext context, GoRouterState state) => const MyOrdersPage(),
    ),
    GoRoute(
      path: AppRoutes.orderDetails,
      builder: (context, state) {
        final order = state.extra as Order;
        return OrderDetailsPage(order: order);
      },
    ),
    GoRoute(
      path: AppRoutes.myReviews,
      builder: (BuildContext context, GoRouterState state) => const MyReviewsPage(),
    ),
    GoRoute(
      path: AppRoutes.addresses,
      builder: (context, state) => const AddressListScreen(),
    ),
    GoRoute(
      path: AppRoutes.addAddress,
      builder: (context, state) => const AddAddressScreen(),
    ),
  ],
);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) { 
    return MaterialApp.router(
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
  late StreamSubscription<User?> _authStateSubscription;

  @override
  void initState() {
    super.initState();
    // Listen to Firebase Auth state changes
    _authStateSubscription = AuthService().user.listen((User? user) {
      if (mounted) {
        if (user == null) {
          // User is signed out, navigate to onboarding/login
          Future.delayed(const Duration(seconds: 2), () {
            context.go(AppRoutes.onboarding);
          });
        } else {
          // User is signed in, navigate to home
          Future.delayed(const Duration(seconds: 2), () {
            context.go(AppRoutes.home);
          });
        }
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        child: Image(image: AssetImage("assets/logo/logo.png")));
  }

  @override
  void dispose() {
    _authStateSubscription.cancel();
    super.dispose();
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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

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
              SizedBox(
                // Make visual content responsive
                height: screenHeight * 0.4,
                width: screenWidth * 0.8,
                child: data.mainVisualContent,
              ),
              SizedBox(height: screenHeight * 0.05),
              Text(
                data.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Text(
                data.description,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 17,
                      color: Colors1.trueGrey,
                    ),
              ),
              const Spacer(),
              Image(
                image: AssetImage(data.progressIndicatorAsset),
                width: 85,
                fit: BoxFit.cover,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 62, // Keep button size consistent
                child: ElevatedButton(
                  onPressed: onNext,
                  child: Text(
                    'Next',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
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
              SizedBox(height: screenHeight * 0.02),
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
        mainVisualContent: Container( // Size is now controlled by OnboardingPageWidget
          decoration: BoxDecoration(
              //
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                  image: AssetImage('assets/onboarding/1.png'),
                  fit: BoxFit.fitWidth)
              // Example: Add an image if you have one for the first page
              ),
        ),
        title: 'All your favorites',
        description:
            'Get all your loved foods in one once place, you just place the order we do the rest',
        progressIndicatorAsset:
            'assets/slider/1.png', // Assuming you have 1.png, 2.png etc.
      ),
      OnboardingPageData(
        mainVisualContent: Container( // Size is now controlled by OnboardingPageWidget
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
        mainVisualContent: Container( // Size is now controlled by OnboardingPageWidget
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/onboarding/1.png'),
                fit: BoxFit.fitWidth),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        title: 'Order from chosen chef', // Updated title
        description:
            'Select your meal from a variety of professional chefs.', // Updated description
        progressIndicatorAsset:
            'assets/slider/3.png', // Make sure you have this asset
      ),
      OnboardingPageData(
        mainVisualContent: Container( // Size is now controlled by OnboardingPageWidget
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/onboarding/1.png'),
                fit: BoxFit.fitWidth),
            borderRadius: BorderRadius.circular(12),
          ),
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
