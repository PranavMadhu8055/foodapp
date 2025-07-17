import 'package:flutter/material.dart';
import 'package:foodapp/core/colors/colors.dart';
import 'package:foodapp/models/restaurant_data.dart';
import 'package:foodapp/providers/restaurant_provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:foodapp/models/user_review.dart';
import 'package:foodapp/providers/user_profile_provider.dart';
import 'package:intl/intl.dart';

class MenuItemDetailsPage extends StatefulWidget {
  final MenuItem menuItem;
  final Restaurant restaurant;

  const MenuItemDetailsPage({
    super.key,
    required this.menuItem,
    required this.restaurant,
  });

  @override
  State<MenuItemDetailsPage> createState() => _MenuItemDetailsPageState();
}

class _MenuItemDetailsPageState extends State<MenuItemDetailsPage> {
  final _pageController = PageController();
  int _quantity = 1;

  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildInfoColumn(IconData icon, Color color, String text) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 4),
        Text(text, style: GoogleFonts.sen()),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final restaurantProvider = context.watch<RestaurantProvider>(); // Watch the provider
    final isFavorited = restaurantProvider.isMenuItemFavorite(widget.menuItem); // Get favorite status from provider

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                // Menu Item Image
                SizedBox(
                  height: screenHeight * 0.4,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: widget.menuItem.imageUrls?.length ?? 1,
                      itemBuilder: (context, index) {
                        final imageUrl = (widget.menuItem.imageUrls != null &&
                                widget.menuItem.imageUrls!.isNotEmpty)
                            ? widget.menuItem.imageUrls![index]
                            : 'assets/images/placeholder.png'; // Fallback
                        return Image.asset(
                          imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            color: Colors.grey[200],
                            child: Icon(Icons.image_not_supported,
                                color: Colors.grey[400]),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Back Button
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors1.circleAvatarBackGrey,
                          child: IconButton( // Use context.pop() for go_router
                            onPressed: () => context.pop(),
                            icon: const Icon(Icons.arrow_back_ios_new,
                                color: Colors.black, size: 20),
                          ),
                        ),
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          child: IconButton(
                            onPressed: () { // Toggle favorite status via provider
                              restaurantProvider.toggleMenuItemFavorite(widget.menuItem, widget.restaurant);
                            },
                            icon: Icon(
                              isFavorited // Use the provider's state
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFavorited ? Colors.red : Colors.black,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Page Indicator
                Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: SmoothPageIndicator(
                      controller: _pageController,
                      count: widget.menuItem.imageUrls?.length ?? 1,
                      effect: const ExpandingDotsEffect(
                          dotHeight: 6,
                          dotWidth: 8,
                          activeDotColor: Colors.orange,
                          dotColor: Colors.white70),
                    ),
                  ),
                ),
              ],
            ),
            // Details content
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.menuItem.name,
                    style: GoogleFonts.sen(
                        fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'From ${widget.restaurant.name}',
                    style: GoogleFonts.sen(
                        fontSize: 16, color: Colors1.trueGrey),
                  ),
                  const SizedBox(height: 16),
                  // Info row for the restaurant
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoColumn(
                          Icons.star,
                          Colors.orange,
                          '${widget.menuItem.calculatedRating?.toStringAsFixed(1) ?? widget.restaurant.calculatedRating.toStringAsFixed(1)} Rating'),
                      _buildInfoColumn(Icons.delivery_dining, Colors.blue,
                          widget.menuItem.deliveryFee ?? widget.restaurant.deliveryFee),
                      _buildInfoColumn(Icons.timer_outlined, Colors.green,
                          widget.menuItem.deliveryTime ?? widget.restaurant.deliveryTime),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    'Description',
                    style: GoogleFonts.sen(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    // Placeholder description, as MenuItem doesn't have one.
                    widget.menuItem.description ??
                        'A delicious and well-prepared ${widget.menuItem.name}, a specialty from ${widget.restaurant.name}. Made with the finest ingredients.',
                    style: GoogleFonts.sen(
                        fontSize: 16, color: Colors.grey[700], height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  // Reviews Section
                  _buildReviewsSection(context, restaurantProvider),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.menuItem.price,
                  style: GoogleFonts.sen(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors1.primaryOrange,
                  ),
                ),
                // Quantity Selector
                Container(
                  decoration: BoxDecoration(
                    color: Colors1.lightyellow,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: _decrementQuantity,
                        color: Colors1.primaryOrange,
                      ),
                      Text(
                        '$_quantity',
                        style: GoogleFonts.sen(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _incrementQuantity,
                        color: Colors1.primaryOrange,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors1.primaryOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  final provider = context.read<RestaurantProvider>();
                  provider.addMultipleToCart(widget.menuItem, _quantity);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          '$_quantity x ${widget.menuItem.name} added to cart.'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                  context.pop(); // Use context.pop() for go_router
                },
                child: Text(
                  'ADD TO CART',
                  style: GoogleFonts.sen(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
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
          size: 16,
        );
      }),
    );
  }

  Widget _buildReviewItem(Review review) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(review.userImageUrl),
            radius: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      review.userName,
                      style: GoogleFonts.sen(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      DateFormat.yMMMd().format(review.date),
                      style: GoogleFonts.sen(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                _buildRatingStars(review.rating),
                const SizedBox(height: 6),
                Text(
                  review.comment,
                  style: GoogleFonts.sen(color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection(BuildContext context, RestaurantProvider provider) {
    final reviews = widget.menuItem.reviews;
    final double avgRating = widget.menuItem.calculatedRating ?? 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Reviews (${reviews.length})',
              style: GoogleFonts.sen(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            if (avgRating > 0)
              Row(
                children: [
                  Text(
                    avgRating.toStringAsFixed(1),
                    style: GoogleFonts.sen(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.star, color: Colors.amber, size: 20),
                ],
              )
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.edit_outlined),
            label: Text("Write a Review", style: GoogleFonts.sen()),
            onPressed: () => _showAddReviewDialog(context, provider),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors1.primaryOrange,
              side: BorderSide(color: Colors1.primaryOrange.withOpacity(0.5)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (reviews.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Center(
              child: Text(
                "No reviews yet. Be the first!",
                style: GoogleFonts.sen(color: Colors.grey, fontSize: 16),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: reviews.length,
            itemBuilder: (context, index) => _buildReviewItem(reviews[index]),
            separatorBuilder: (context, index) => const Divider(height: 1),
          ),
      ],
    );
  }

  void _showAddReviewDialog(BuildContext context, RestaurantProvider provider) {
    final reviewController = TextEditingController();
    double currentRating = 3.0;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            title: Text("What do you think?", style: GoogleFonts.sen(fontWeight: FontWeight.bold)),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (index) {
                return IconButton(
                  onPressed: () => setDialogState(() => currentRating = index + 1.0),
                  icon: Icon(index < currentRating ? Icons.star : Icons.star_border, color: Colors.amber, size: 30),
                );
              })),
              const SizedBox(height: 16),
              TextField(controller: reviewController, maxLines: 3, decoration: InputDecoration(hintText: "Share your experience...", border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)))),
            ]),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: Text("CANCEL", style: GoogleFonts.sen(color: Colors.grey))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors1.primaryOrange),
                onPressed: () {
                  if (reviewController.text.isNotEmpty) {
                    final userProfileProvider = context.read<UserProfileProvider>();
                    final newReview = Review(
                      userName: userProfileProvider.fullName,
                      userImageUrl: "https://randomuser.me/api/portraits/men/1.jpg", // Placeholder
                      rating: currentRating,
                      comment: reviewController.text,
                      date: DateTime.now());
                    
                    // Add review to the item itself
                    provider.addReviewToMenuItem(menuItem: widget.menuItem, restaurant: widget.restaurant, review: newReview);
                    
                    // Add review to the user's personal review history
                    final userReview = UserReview(review: newReview, reviewSubjectName: widget.menuItem.name, type: ReviewableType.menuItem, subject: { 'menuItem': widget.menuItem, 'restaurant': widget.restaurant });
                    userProfileProvider.addUserReview(userReview);
                    
                    // Update the subject to store IDs for Firestore
                    userReview.subject = {'restaurantId': widget.restaurant.id, 'menuItemId': widget.menuItem.id};
                    
                    Navigator.of(context).pop();
                  }
                },
                child: Text("SUBMIT", style: GoogleFonts.sen(color: Colors.white)),
              ),
            ],
          );
        });
      },
    );
  }
}
