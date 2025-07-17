import 'package:flutter/material.dart';
import 'package:foodapp/app_routes.dart';
import 'package:foodapp/core/colors/colors.dart';
import 'package:foodapp/models/restaurant_data.dart';
import 'package:foodapp/providers/restaurant_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class MenuItemCard extends StatelessWidget {
  final MenuItem menuItem;
  final Restaurant restaurant;

  const MenuItemCard({
    super.key,
    required this.menuItem,
    required this.restaurant,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Use push to stack pages, so back button works as expected
        context.push(
          AppRoutes.menuItemDetails,
          extra: {
            'menuItem': menuItem,
            'restaurant': restaurant,
          },
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: (menuItem.imageUrls != null && menuItem.imageUrls!.isNotEmpty)
                    ? Image.asset(
                        menuItem.imageUrls!.first, // Display the first image
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: Icon(Icons.image_not_supported,
                            color: Colors.grey[400]),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    menuItem.name,
                    style: GoogleFonts.sen(
                        fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    restaurant.name,
                    style: GoogleFonts.sen(fontSize: 12, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        menuItem.price,
                        style: GoogleFonts.sen(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors1.primaryOrange,
                        ),
                      ),
                      Container(
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                          color: Colors1.primaryOrange,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.add,
                              color: Colors.white, size: 18),
                          onPressed: () {
                            context.read<RestaurantProvider>().addToCart(menuItem);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${menuItem.name} added to cart.'),
                                duration: const Duration(seconds: 1),
                                backgroundColor: Colors1.primaryOrange,
                              ),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}