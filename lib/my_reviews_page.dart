import 'package:flutter/material.dart';
import 'package:foodapp/app_routes.dart';
import 'package:foodapp/core/colors/colors.dart';
import 'package:foodapp/models/restaurant_data.dart'; // For Restaurant and MenuItem
import 'package:foodapp/models/user_review.dart';
import 'package:foodapp/providers/restaurant_provider.dart'; // Import RestaurantProvider
import 'package:foodapp/providers/user_profile_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MyReviewsPage extends StatelessWidget {
  const MyReviewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userProfileProvider = context.watch<UserProfileProvider>();
    final reviews = userProfileProvider.userReviews;

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
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
            ),
          ),
        ),
        title: Text('My Reviews', style: GoogleFonts.sen(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
      ),
      body: reviews.isEmpty
          ? _buildEmptyReviews()
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                final userReview = reviews[index];
                return _buildReviewCard(context, userReview);
              },
            ),
    );
  }

  Widget _buildEmptyReviews() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.rate_review_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text(
            'You haven\'t written any reviews.',
            style: GoogleFonts.sen(fontSize: 20, color: Colors.grey[600]),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Text(
              'Your reviews on restaurants and food items will appear here.',
              textAlign: TextAlign.center,
              style: GoogleFonts.sen(fontSize: 16, color: Colors.grey[500]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(BuildContext context, UserReview userReview) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: () {
          final restaurantProvider = context.read<RestaurantProvider>();
          if (userReview.type == ReviewableType.menuItem) {
            final restaurantId = userReview.subject['restaurantId'] as String?;
            final menuItemId = userReview.subject['menuItemId'] as String?;
            if (restaurantId != null && menuItemId != null) {
              final restaurant = restaurantProvider.findRestaurantById(restaurantId);
              final menuItem = restaurantProvider.findMenuItemById(restaurantId, menuItemId);
              if (restaurant != null && menuItem != null) {
                context.push(AppRoutes.menuItemDetails, extra: {'menuItem': menuItem, 'restaurant': restaurant});
              }
            }
          } else if (userReview.type == ReviewableType.restaurant) {
            final restaurantId = userReview.subject['restaurantId'] as String?;
            if (restaurantId != null) {
              final restaurant = restaurantProvider.findRestaurantById(restaurantId);
              if (restaurant != null) {
                context.push(AppRoutes.restaurantDetails, extra: restaurant);
              }
            }
          }
        },
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      'Review for: ${userReview.reviewSubjectName}',
                      style: GoogleFonts.sen(fontWeight: FontWeight.bold, fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat.yMMMd().format(userReview.review.date),
                    style: GoogleFonts.sen(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildRatingStars(userReview.review.rating),
              const SizedBox(height: 12),
              Text(
                userReview.review.comment,
                style: GoogleFonts.sen(color: Colors.grey[800], height: 1.4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingStars(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 20,
        );
      }),
    );
  }
}