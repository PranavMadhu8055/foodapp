import 'package:flutter/material.dart';
import 'package:foodapp/core/colors/colors.dart';
import 'package:foodapp/models/restaurant_data.dart';
import 'package:foodapp/app_routes.dart';
import 'package:foodapp/providers/restaurant_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final restaurantProvider = context.watch<RestaurantProvider>();
    final cartItems = restaurantProvider.cartItems;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors1.circleAvatarBackGrey,
            child: IconButton( // Use context.pop() for go_router compatibility
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20)),
          ),
        ),
        title: Text('My Cart', style: GoogleFonts.sen(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
      ),
      body: cartItems.isEmpty ? _buildEmptyCart() : _buildCartContent(context, restaurantProvider),
    );
  }

  Widget _buildCartContent(BuildContext context, RestaurantProvider restaurantProvider) {
    final cartItems = restaurantProvider.cartItems;
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              final menuItem = cartItems.keys.elementAt(index);
              final quantity = cartItems[menuItem]!;
              return _buildCartItem(context, menuItem, quantity, restaurantProvider);
            },
          ),
        ),
        _buildOrderSummary(context, restaurantProvider),
      ],
    );
  }

  Widget _buildCartItem(BuildContext context, MenuItem menuItem, int quantity, RestaurantProvider provider) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: GestureDetector(
        onTap: () {
          // Find the restaurant for this menu item
          final restaurant = provider.findRestaurantForMenuItem(menuItem);
          if (restaurant != null) {
            // Navigate to the details page
            context.push(
              AppRoutes.menuItemDetails,
              extra: {'menuItem': menuItem, 'restaurant': restaurant},
            );
          } else {
            // Optional: Show an error if the restaurant isn't found
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not find restaurant for this item.')),
            );
          }
        },
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                )
              ]),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    (menuItem.imageUrls != null && menuItem.imageUrls!.isNotEmpty)
                        ? menuItem.imageUrls!.first
                        : 'assets/images/placeholder.png',
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 70,
                      height: 70,
                      color: Colors.grey[200],
                      child: Icon(Icons.image_not_supported, color: Colors.grey[400]),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        menuItem.name,
                        style: GoogleFonts.sen(fontWeight: FontWeight.bold, fontSize: 16),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(menuItem.price,
                          style: GoogleFonts.sen(
                              color: Colors1.primaryOrange, fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                // The GestureDetector will not interfere with these buttons,
                // as they handle their own tap events.
                Row(
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.remove_circle_outline, color: Colors.grey),
                      onPressed: () => provider.removeFromCart(menuItem),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: SizedBox(
                        width: 24, // A fixed width to prevent layout shifts
                        child: Text(
                          '$quantity',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.sen(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(Icons.add_circle_outline, color: Colors1.primaryOrange),
                      onPressed: () => provider.addToCart(menuItem),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.close, color: Colors.redAccent),
                      onPressed: () => provider.clearItemFromCart(menuItem),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text(
            'Your cart is empty',
            style: GoogleFonts.sen(fontSize: 20, color: Colors.grey[600]),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Text(
              'Looks like you haven\'t added anything to your cart yet.',
              textAlign: TextAlign.center,
              style: GoogleFonts.sen(fontSize: 16, color: Colors.grey[500]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(BuildContext context, RestaurantProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 0, blurRadius: 10, offset: const Offset(0, -5)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total:', style: GoogleFonts.sen(fontSize: 18, color: Colors.grey[700])),
              Text('\$${provider.getCartTotal().toStringAsFixed(2)}', style: GoogleFonts.sen(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors1.primaryOrange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                if (provider.cartItems.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Your cart is empty! Add items before placing an order.'), backgroundColor: Colors.red),
                  );
                  return;
                }
                provider.placeOrder();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order placed successfully!'), backgroundColor: Colors.green));
                // Navigate to the My Orders page after placing the order
                // Using context.go() to replace the current stack with the orders page for better UX
                context.go(AppRoutes.myOrders);
              },
              child: Text('PLACE ORDER', style: GoogleFonts.sen(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors1.primaryOrange),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                context.push(AppRoutes.myOrders); // Use push to allow returning to the cart
              },
              child: Text(
                'VIEW MY ORDERS',
                style: GoogleFonts.sen(fontSize: 16, color: Colors1.primaryOrange, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}