import 'dart:async';
import 'package:flutter/material.dart' hide Category;
import 'package:foodapp/core/colors/colors.dart';
import 'package:foodapp/models/restaurant_data.dart';
import 'package:foodapp/app_routes.dart';
import 'package:foodapp/providers/restaurant_provider.dart';
import 'package:foodapp/widgets/expandable_text_widget.dart';
import 'package:foodapp/widgets/menu_item_card.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:foodapp/services/database_service.dart'; // Import DatabaseService
import 'package:foodapp/models/user_review.dart';
import 'package:foodapp/providers/user_profile_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:intl/intl.dart';

class RestaurantDetailsPage extends StatefulWidget {
  final Restaurant restaurant;

  const RestaurantDetailsPage({super.key, required this.restaurant});

  @override
  State<RestaurantDetailsPage> createState() => _RestaurantDetailsPageState();
}

class _RestaurantDetailsPageState extends State<RestaurantDetailsPage> {
  final _pageController = PageController();
  late String _selectedMenuCategory;
  late List<MenuItem> _filteredMenuItems;
  late List<Category> _menuCategories;

  final DatabaseService _databaseService = DatabaseService();
  StreamSubscription<List<Review>>? _reviewsSubscription;
  List<Review> _currentReviews = [];
  // State for filters
  Set<String> _selectedOffers = {};
  String? _selectedDeliveryTime;
  String? _selectedPricingSort;
  int _selectedRating = 0;

  @override
  void initState() {
    super.initState();
    // Initially, show all menu items for this restaurant
    _filteredMenuItems = widget.restaurant.menu;
    _selectedMenuCategory = 'All';

    // Derive unique categories from the menu, and add 'All'
    final uniqueCategories =
        widget.restaurant.menu.map((item) => item.category).toSet();
    _menuCategories = [
      Category(name: 'All', iconAsset: 'assets/icons/Cart.png'), // Placeholder
      ...uniqueCategories.map(
          (cat) => Category(name: cat, iconAsset: 'assets/icons/Cart.png')),
    ];

    _reviewsSubscription = _databaseService.getRestaurantReviewsStream(widget.restaurant.id).listen((reviews) {
      setState(() {
        _currentReviews = reviews;
      });
    }, onError: (error) {
      print("Error fetching restaurant reviews: $error");
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _reviewsSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final restaurantProvider = context.watch<RestaurantProvider>();
    return Scaffold(
      backgroundColor: Colors.white,
      // Using SingleChildScrollView to prevent overflow when content is long
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stack for the top image and overlaying a back button
            Stack(
              children: [
                // Restaurant Image Slider
                Container(
                  height: 350,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: widget.restaurant.imageUrls?.length ?? 1,
                      itemBuilder: (context, index) {
                        final imageUrl = (widget.restaurant.imageUrls != null &&
                                widget.restaurant.imageUrls!.isNotEmpty)
                            ? widget.restaurant.imageUrls![index]
                            : 'assets/images/placeholder.png'; // Fallback
                        return Image.asset(
                          imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        );
                      },
                    ),
                  ),
                ),
                // Back and Favorite Buttons
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors1.circleAvatarBackGrey,
                          child: IconButton(
                              onPressed: () => context.pop(), // Use context.pop() for go_router
                              icon: const Icon(Icons.arrow_back_ios_new,
                                  color: Colors.black, size: 20)),
                        ),
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          child: IconButton(
                            onPressed: _showFilterDialog,
                            icon: const Icon(Icons.filter_list_outlined,
                                color: Colors.black, size: 20)),
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
                      count: widget.restaurant.imageUrls?.length ?? 1,
                      effect: ExpandingDotsEffect(
                        dotHeight: 6, // Slightly smaller dots for consistency
                        dotWidth: 8,
                        activeDotColor: Colors.orange,
                        dotColor: Colors.white70,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Restaurant details content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.restaurant.name,
                    style: GoogleFonts.sen(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ExpandableTextWidget(text: widget.restaurant.description),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text('Menu',
                      style: GoogleFonts.sen(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  // Category Chips for the Menu
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _menuCategories.map((category) {
                        return _buildCategoryChip(
                          category,
                          isSelected: category.name == _selectedMenuCategory,
                          onTap: () => _filterMenu(category.name),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Dynamically built menu items
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // 2 items per row
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.9, // Adjust this ratio to fit content
                    ),
                    itemCount: _filteredMenuItems.length,
                    itemBuilder: (context, index) {
                      final menuItem = _filteredMenuItems[index];
                      return MenuItemCard(menuItem: menuItem, restaurant: widget.restaurant);
                    },
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildReviewsSection(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _applyFilters() {
    setState(() {
      // Create a mutable copy of the original menu to filter/sort
      List<MenuItem> tempFilteredMenu = List.from(widget.restaurant.menu);

      // NOTE: The current MenuItem model doesn't support filtering by offers,
      // delivery time, or rating. The UI is present, but filtering for these
      // is not implemented.

      // Sorting by price
      if (_selectedPricingSort != null) {
        tempFilteredMenu.sort((a, b) {
          // Helper to parse price string like '$9.99' to double
          double priceA =
              double.tryParse(a.price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
          double priceB =
              double.tryParse(b.price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;

          if (_selectedPricingSort == 'low-high') {
            return priceA.compareTo(priceB);
          } else if (_selectedPricingSort == 'high-low') {
            return priceB.compareTo(priceA);
          }
          return 0;
        });
      }

      _filteredMenuItems = tempFilteredMenu;
      // Reset category filter when applying global filters
      _selectedMenuCategory = 'All';
    });
    Navigator.of(context).pop(); // Close the dialog
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Use a StatefulBuilder to manage the state of the dialog content
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text('Filter Properties', style: GoogleFonts.sen(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Offers', style: GoogleFonts.sen(fontWeight: FontWeight.bold)),
                    Wrap(
                      spacing: 8.0,
                      children: ['Delivery', 'Pick Up', 'Offer', 'Online payment available'].map((offer) {
                        return FilterChip(
                          label: Text(offer, style: GoogleFonts.sen()),
                          selected: _selectedOffers.contains(offer),
                          onSelected: (selected) {
                            setDialogState(() {
                              if (selected) { _selectedOffers.add(offer); } else { _selectedOffers.remove(offer); }
                            });
                          },
                          selectedColor: Colors1.lightyellow,
                          checkmarkColor: Colors.black,
                          backgroundColor: Colors.white,
                        );
                      }).toList(),
                    ),
                    const Divider(),
                    Text('Deliver Time', style: GoogleFonts.sen(fontWeight: FontWeight.bold)),
                    Wrap(
                      spacing: 8.0,
                      children: ['10-15 min', '20 min', '30 min'].map((time) {
                        return ChoiceChip(
                          label: Text(time, style: GoogleFonts.sen()),
                          selected: _selectedDeliveryTime == time,
                          onSelected: (selected) => setDialogState(() => _selectedDeliveryTime = selected ? time : null),
                          selectedColor: Colors1.lightyellow,
                          backgroundColor: Colors.white,
                        );
                      }).toList(),
                    ),
                    const Divider(),
                    Text('Pricing', style: GoogleFonts.sen(fontWeight: FontWeight.bold)),
                    Wrap(
                      spacing: 8.0,
                      children: ['low-high', 'high-low'].map((sort) {
                        return ChoiceChip(
                          label: Text(sort, style: GoogleFonts.sen()),
                          selected: _selectedPricingSort == sort,
                          onSelected: (selected) => setDialogState(() => _selectedPricingSort = selected ? sort : null),
                          selectedColor: Colors1.lightyellow,
                          backgroundColor: Colors.white,
                        );
                      }).toList(),
                    ),
                    const Divider(),
                    Text('Rating', style: GoogleFonts.sen(fontWeight: FontWeight.bold)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return CircleAvatar(
                          backgroundColor: Colors.transparent,
                          child: IconButton(
                            icon: Icon( index < _selectedRating ? Icons.star : Icons.star_border, color: Colors1.primaryOrange),
                            onPressed: () => setDialogState(() => _selectedRating = index + 1),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors1.primaryOrange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    onPressed: _applyFilters,
                    child: Text('Filter', style: GoogleFonts.sen(color: Colors.white)),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _filterMenu(String category) {
    setState(() {
      _selectedMenuCategory = category;
      if (category == 'All') {
        _filteredMenuItems = widget.restaurant.menu;
      } else {
        _filteredMenuItems = widget.restaurant.menu
            .where((item) => item.category == category)
            .toList();
      }
    });
  }

  Widget _buildCategoryChip(Category category,
      {required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8.0, bottom: 8.0),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors1.lightyellow : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Text(
          category.name,
          style: GoogleFonts.sen(
              color: isSelected ? Colors.black87 : Colors.black),
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

  void _showAddRestaurantReviewDialog(BuildContext context) {
    final reviewController = TextEditingController();
    double currentRating = 3.0;
    final userProfileProvider = context.read<UserProfileProvider>();
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            title: Text("Rate this Restaurant", style: GoogleFonts.sen(fontWeight: FontWeight.bold)),
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
                onPressed: () async { // Make the onPressed callback async
                  if (reviewController.text.isNotEmpty) {
                    final newReview = Review(userName: userProfileProvider.fullName, userImageUrl: "https://randomuser.me/api/portraits/men/1.jpg", rating: currentRating, comment: reviewController.text, date: DateTime.now());

                    // Add review to the user's personal review history
                    final userReview = UserReview(
                      review: newReview,
                      reviewSubjectName: widget.restaurant.name,
                      type: ReviewableType.restaurant,
                      subject: {'restaurantId': widget.restaurant.id}, // Pass a map with the ID
                    );
                    await userProfileProvider.addUserReview(userReview); // Await the call

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

  Widget _buildReviewsSection(BuildContext context) {
    final reviews = _currentReviews; // Use the streamed reviews
    final double avgRating = widget.restaurant.calculatedRating;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Restaurant Reviews (${reviews.length})',
              style: GoogleFonts.sen(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            if (reviews.isNotEmpty) // Calculate average rating from streamed reviews
              Row(
                children: [
                  Text(
                    (reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length).toStringAsFixed(1),
                    style: GoogleFonts.sen(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.star, color: Colors.amber, size: 20),
                ],
              )
            else if (widget.restaurant.rating > 0) // Fallback to initial rating if no reviews yet
              Text(
                widget.restaurant.rating.toStringAsFixed(1),
                style: GoogleFonts.sen(fontSize: 16, fontWeight: FontWeight.bold),
              )
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.edit_outlined),
            label: Text("Write a Review", style: GoogleFonts.sen()),
            onPressed: () => _showAddRestaurantReviewDialog(context),
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
              child: Text("No reviews yet. Be the first!", style: GoogleFonts.sen(color: Colors.grey, fontSize: 16)),
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
}
