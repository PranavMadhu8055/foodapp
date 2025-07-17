import 'package:flutter/material.dart';
import 'package:foodapp/app_routes.dart';
import 'package:foodapp/core/colors/colors.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter

import 'package:foodapp/providers/user_profile_provider.dart';
import 'package:foodapp/services/auth_service.dart'; // Import AuthService
import 'package:provider/provider.dart';
class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userProfile = context.watch<UserProfileProvider>();
    return Drawer(
      backgroundColor: Colors.white,
      // The entire content is now wrapped in a Drawer widget
      child: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              // Profile Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  // color: Colors.blue[50],
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                child: SafeArea(
                  // Ensures content is below the status bar
                  child: Row(
                    children: [
                      const CircleAvatar( // TODO: Replace with dynamic user image
                        radius: 30,
                        backgroundImage:
                            AssetImage('assets/images/profile.jpg'),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userProfile.fullName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            userProfile.bio,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Menu Items
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors1.menuGreyBack,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  // padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      _buildMenuItem(context,
                          icon: Icons.person_outline,
                          title: 'Personal Info', onTap: () {
                        context.push(AppRoutes
                            .personalInfo); // Navigate to personal info page
                        Navigator.of(context).pop(); // Close the drawer
                      }),
                      _buildMenuItem(context,
                          icon: Icons.location_on_outlined,
                          title: 'Addresses', onTap: () {
                        // Handle Addresses tap
                        context.push(AppRoutes
                            .addresses); // Navigate to the AddressListScreen
                        Navigator.of(context).pop(); // Close the drawer
                      }),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors1.menuGreyBack,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      _buildMenuItem(context,
                          icon: Icons.shopping_cart_outlined,
                          title: 'Cart', onTap: () {
                        Navigator.of(context).pop(); // Close the drawer
                        context.push(AppRoutes.cart);
                      }),
                      _buildMenuItem(context,
                          icon: Icons.receipt_long, // Icon for orders
                          title: 'My Orders', onTap: () {
                        Navigator.of(context).pop(); // Close the drawer
                        context.push(
                            AppRoutes.myOrders); // Navigate to My Orders page
                      }),
                      _buildMenuItem(context,
                          icon: Icons.favorite_border,
                          title: 'Favourite', onTap: () {
                        Navigator.of(context).pop(); // Close the drawer
                        context.push(
                            AppRoutes.favorites); // Navigate to favorites page
                      }),
                      _buildMenuItem(context,
                          icon: Icons.notifications_none,
                          title: 'Notifications', onTap: () {
                        // Handle Notifications tap
                        Navigator.of(context).pop(); // Close the drawer
                      }),
                      _buildMenuItem(context,
                          icon: Icons.payment_outlined,
                          title: 'Payment Method', onTap: () {
                        // Handle Payment Method tap
                        Navigator.of(context).pop(); // Close the drawer
                      }),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors1.menuGreyBack,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      _buildMenuItem(context,
                          icon: Icons.help_outline, title: 'FAQs', onTap: () {
                        // Handle FAQs tap
                        Navigator.of(context).pop(); // Close the drawer
                      }),
                      _buildMenuItem(context,
                          icon: Icons.star_border,
                          title: 'User Reviews', onTap: () {
                        context.push(AppRoutes
                            .myReviews); // Navigate to the My Reviews page
                        // Handle User Reviews tap
                        Navigator.of(context).pop(); // Close the drawer
                      }),
                      _buildMenuItem(context,
                          icon: Icons.settings_outlined,
                          title: 'Settings', onTap: () {
                        // Handle Settings tap
                        Navigator.of(context).pop(); // Close the drawer
                      }),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors1.menuGreyBack,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.exit_to_app, color: Colors.red),
                    title: const Text(
                      'Log Out',
                      style: TextStyle(color: Colors.red),
                    ), // Log Out button
                    onTap: () {
                      AuthService().signOut(); // Call the signOut method
                      Navigator.of(context).pop(); // Close the drawer immediately
                      // The auth state listener in main.dart will handle navigation to login/onboarding
                      context.go(AppRoutes.login); // Explicitly navigate to login page
                    },
                  ),
                ),
              ),

              // Log Out Button
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context,
      {required IconData icon, required String title, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap ??
            () {
              // Default behavior if onTap is not provided
              Navigator.of(context)
                  .pop(); // Close the drawer after tapping an item
            },
      ),
    );
  }
}
