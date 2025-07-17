import 'package:flutter/material.dart';
import 'package:foodapp/core/colors/colors.dart';
import 'package:foodapp/models/restaurant_data.dart';
import 'package:foodapp/providers/restaurant_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:foodapp/app_routes.dart';
import 'package:go_router/go_router.dart';

class FavoriteItemsPage extends StatelessWidget {
  const FavoriteItemsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final restaurantProvider = context.watch<RestaurantProvider>();
    final favoriteItems = restaurantProvider.favoriteMenuItemsWithRestaurant.keys.toList(); // Get keys (MenuItems) as a list

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors1.circleAvatarBackGrey,
            child: IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back_ios_new,
                    color: Colors.black, size: 20)),
          ),
        ),
        title: Text('My Favorites', style: GoogleFonts.sen(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
      ),
      body: favoriteItems.isEmpty
          ? _buildEmptyFavorites()
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: favoriteItems.length,
              itemBuilder: (context, index) {
                final menuItem = favoriteItems[index];
                return _buildFavoriteItemCard(context, menuItem, restaurantProvider);
              },
            ),
    );
  }

  Widget _buildEmptyFavorites() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text(
            'No favorite items yet!',
            style: GoogleFonts.sen(fontSize: 20, color: Colors.grey[600]),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Text(
              'Tap the heart icon on menu items to add them to your favorites.',
              textAlign: TextAlign.center,
              style: GoogleFonts.sen(fontSize: 16, color: Colors.grey[500]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteItemCard(BuildContext context, MenuItem menuItem, RestaurantProvider provider) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: () {
          final restaurant = provider.favoriteMenuItemsWithRestaurant[menuItem];
          if (restaurant != null) {
            context.push(AppRoutes.menuItemDetails, extra: {
              'menuItem': menuItem,
              'restaurant': restaurant,
            });
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  (menuItem.imageUrls != null && menuItem.imageUrls!.isNotEmpty)
                      ? menuItem.imageUrls!.first
                      : 'assets/images/placeholder.png',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[200],
                    child: Icon(Icons.image_not_supported, color: Colors.grey[400]),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      menuItem.name,
                      style: GoogleFonts.sen(fontWeight: FontWeight.bold, fontSize: 18),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      menuItem.price,
                      style: GoogleFonts.sen(color: Colors1.primaryOrange, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.orange[700], size: 16),
                        Text(
                          ' ${menuItem.calculatedRating?.toStringAsFixed(1) ?? 'N/A'}', // Use calculated rating
                          style: GoogleFonts.sen(fontSize: 14)
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.favorite, color: Colors.red),
                onPressed: () {
                  final restaurant = provider.favoriteMenuItemsWithRestaurant[menuItem];
                  if (restaurant != null) {
                    provider.toggleMenuItemFavorite(menuItem, restaurant); // Remove from favorites
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${menuItem.name} removed from favorites.')),
                    );
                  }
                },
              ),
              // Add to Cart Button
              ElevatedButton(
                onPressed: () {
                  provider.addMultipleToCart(menuItem, 1); // Add 1 quantity to cart
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${menuItem.name} added to cart.')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  backgroundColor: Colors1.primaryOrange,
                  fixedSize: const Size(40, 40),
                ),
                child: const Icon(Icons.add_shopping_cart, color: Colors.white, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}