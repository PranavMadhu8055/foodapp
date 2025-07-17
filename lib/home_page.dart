import 'package:flutter/material.dart' hide Category;
import 'package:foodapp/app_routes.dart';
import 'package:foodapp/core/colors/colors.dart';
import 'package:foodapp/core/textfield.dart';
import 'package:foodapp/models/restaurant_data.dart';
import 'package:foodapp/providers/restaurant_provider.dart';
import 'package:foodapp/menu_page.dart';
// import 'package:foodapp/restaurant_details_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class FoodDeliveryApp extends StatefulWidget {
  const FoodDeliveryApp({super.key});

  @override
  State<FoodDeliveryApp> createState() => _FoodDeliveryAppState();
}

class _FoodDeliveryAppState extends State<FoodDeliveryApp> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();

  void _onSearchChanged() {
    context.read<RestaurantProvider>().filterBySearch(_searchController.text);
    setState(() {});
  }

  void _onFocusChanged() {
    setState(() {});
  }
  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    const int alertMessageFlag = 1; 
    _searchFocusNode.addListener(_onFocusChanged);
    if (alertMessageFlag == 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showCouponDialog(context);
      });
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchFocusNode.removeListener(_onFocusChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final restaurantProvider = context.watch<RestaurantProvider>();
    final bool isSearching = _searchFocusNode.hasFocus || _searchController.text.isNotEmpty;
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const MenuPage(),
      body: Builder( // Add Builder here
        builder: (BuildContext innerContext) { // Use innerContext for Scaffold.of()
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0, left: 20, right: 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          Scaffold.of(innerContext).openDrawer(); // Use innerContext
                        },
                        child: const CircleAvatar(
                          radius: 25,
                          backgroundImage: AssetImage('assets/icons/Menu.png'),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'DELIVER TO',
                                    style: GoogleFonts.sen(
                                        fontSize: 12,
                                        color: Colors1.primaryOrange,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Halal Lab office',
                                    style: GoogleFonts.sen(
                                        fontSize: 14, color: Colors1.trueGrey),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.keyboard_arrow_down),
                                    iconSize: 20.0,
                                    onPressed: () {},
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Stack(
                        children: [
                          InkWell(
                            onTap: () {
                              context.push(AppRoutes.cart);
                            },
                            child: const CircleAvatar(
                              radius: 25,
                              backgroundImage: AssetImage('assets/icons/Cart.png'),
                            ),
                          ),
                          if (restaurantProvider.cartItems.isNotEmpty)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 18,
                                  minHeight: 18,
                                ),
                                child: Text(
                                  '${restaurantProvider.cartItemCount}',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 12),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),

                  // Rest of the content
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        'Hey Halal, Good Afternoon!',
                        style: GoogleFonts.sen(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),
                      // Search bar
                      TextField1(
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          onSubmitted: (query) {
                            if (query.trim().isNotEmpty) {
                              context.read<RestaurantProvider>().addSearchQuery(query.trim());
                            }
                          },
                          style: GoogleFonts.sen(color: Colors.black87),
                          decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.search),
                              prefixIconColor: Colors1.coolGrey,
                              hintText: 'Search dishes, restaurants',
                              hintStyle: GoogleFonts.sen(color: Colors1.coolGrey),
                              border: InputBorder.none,
                              suffixIcon: isSearching ? IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  _searchController.clear();
                                  _searchFocusNode.unfocus();
                                },
                              ) : null,
                              ),
                        ),
                      ),
                      // Conditional UI for default home or search results
                      isSearching
                          ? _buildSearchResultsView(restaurantProvider)
                          : _buildDefaultHomeView(restaurantProvider),
                    ],
                  ),
                ],
              ),
          ));
  }),
      );
  }

  Widget _buildDefaultHomeView(RestaurantProvider restaurantProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        // Categories section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'All Categories',
              style: GoogleFonts.sen(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {},
              child: Text('See All',
                  style: GoogleFonts.sen(color: Theme.of(context).primaryColor)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: restaurantProvider.categories.map((category) {
                return _buildCategoryChip(
                  category,
                  isSelected: category.name == restaurantProvider.selectedCategory,
                  onTap: () => restaurantProvider.filterByCategory(category.name),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Popular Items Section
        _buildPopularItemsSection(restaurantProvider),
        const SizedBox(height: 24),
        _buildMostBoughtSection(restaurantProvider),
        const SizedBox(height: 24),
        // Open restaurants section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Open Restaurants',
              style: GoogleFonts.sen(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {},
              child: Text('See All',
                  style: GoogleFonts.sen(color: Theme.of(context).primaryColor)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Use ListView.builder to dynamically build restaurant cards
        ListView.builder(
          shrinkWrap: true, // Important for nested scroll views
          physics: const NeverScrollableScrollPhysics(), // Disable scrolling for this list
          itemCount: restaurantProvider.filteredRestaurants.length,
          itemBuilder: (context, index) {
            final restaurant = restaurantProvider.filteredRestaurants[index];
            return _buildRestaurantCard(restaurant);
          },
        ),
      ],
    );
  }

  Widget _buildSearchResultsView(RestaurantProvider provider) {
    final recentSearches = provider.recentSearches;
    final searchResults = provider.filteredRestaurants;
    final filteredItems = provider.filteredMenuItems;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Recent Searches
        if (recentSearches.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text('Recent Searches', style: GoogleFonts.sen(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: recentSearches.map((term) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ActionChip(
                    label: Text(term, style: GoogleFonts.sen()),
                    onPressed: () {
                      _searchController.text = term;
                      _searchController.selection = TextSelection.fromPosition(TextPosition(offset: _searchController.text.length));
                      provider.addSearchQuery(term);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],

        // Suggested Items
        if (filteredItems.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text('Matching Dishes', style: GoogleFonts.sen(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SizedBox(
            height: 230, // Constrain height for horizontal list
            child: ListView.builder(
              scrollDirection: Axis.horizontal, // Set scroll direction to horizontal
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final entry = filteredItems[index];
                return _buildSearchItemCard(entry.key, entry.value);
              },
            ),
          ),
        ],

        // Suggested Restaurants
        if (searchResults.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text('Suggested Restaurants', style: GoogleFonts.sen(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: searchResults.length,
            itemBuilder: (context, index) {
              final restaurant = searchResults[index];
              return _buildRestaurantCard(restaurant);
            },
          ),
        ],

        // No results found message
        if (searchResults.isEmpty && filteredItems.isEmpty && _searchController.text.isNotEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text('No results found for "${_searchController.text}".', style: GoogleFonts.sen()),
            ),
          ),
      ],
    );
  }

  Widget _buildSearchItemCard(MenuItem menuItem, Restaurant restaurant) {
    return SizedBox(
      width: 180, 
      child: Card(
        margin: const EdgeInsets.only(right: 12.0),
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            context.push(AppRoutes.menuItemDetails, extra: {
              'menuItem': menuItem,
              'restaurant': restaurant,
            });
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                (menuItem.imageUrls != null && menuItem.imageUrls!.isNotEmpty) ? menuItem.imageUrls!.first : 'assets/images/placeholder.png',
                width: double.infinity,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                    width: double.infinity, height: 120, color: Colors.grey[200],
                    child: Icon(Icons.image_not_supported, color: Colors.grey[400])),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: Text(
                  menuItem.name,
                  style: GoogleFonts.sen(fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                child: Text(
                  'From ${restaurant.name}',
                  style: GoogleFonts.sen(color: Colors.grey[600], fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildRatingStars(menuItem.calculatedRating ?? 0.0),
                    Text(
                      menuItem.price,
                      style: GoogleFonts.sen(color: Colors1.primaryOrange, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
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
          size: 16,
        );
      }),
    );
  }

  Widget _buildPopularItemsSection(RestaurantProvider provider) {
    final popularItems = provider.popularMenuItems;

    if (popularItems.isEmpty) {
      return const SizedBox.shrink(); 
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Popular Items',
              style:
                  GoogleFonts.sen(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed:
                  () {},
              child: Text('See All',
                  style:
                      GoogleFonts.sen(color: Theme.of(context).primaryColor)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: popularItems.map((entry) {
              final menuItem = entry.key;
              final restaurant = entry.value;
              return _buildPopularItemCard(menuItem, restaurant);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPopularItemCard(MenuItem menuItem, Restaurant restaurant) {
    return GestureDetector(
      onTap: () {
        context.push(AppRoutes.menuItemDetails, extra: {
          'menuItem': menuItem,
          'restaurant': restaurant,
        });
      },
      child: Container(
        width: 150, 
        margin: const EdgeInsets.only(right: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                (menuItem.imageUrls != null && menuItem.imageUrls!.isNotEmpty)
                    ? menuItem.imageUrls!.first
                    : 'assets/images/placeholder.png',
                height: 100,
                width: 150,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                    height: 100,
                    width: 150,
                    color: Colors.grey[200],
                    child: Icon(Icons.image_not_supported, color: Colors.grey[400])),
              ),
            ),
            const SizedBox(height: 8),
            Text(menuItem.name, style: GoogleFonts.sen(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(restaurant.name, style: GoogleFonts.sen(color: Colors.grey[600], fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(menuItem.price, style: GoogleFonts.sen(color: Colors1.primaryOrange, fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildMostBoughtSection(RestaurantProvider provider) {
    final mostBought = provider.mostBoughtItems;

    if (mostBought.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Most Bought Today',
              style: GoogleFonts.sen(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {}, // Placeholder for "See All"
              child: Text('See All',
                  style:
                      GoogleFonts.sen(color: Theme.of(context).primaryColor)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: mostBought.map((entry) {
              final menuItem = entry.key;
              final restaurant = entry.value;
              return _buildMostBoughtItemCard(menuItem, restaurant);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMostBoughtItemCard(MenuItem menuItem, Restaurant restaurant) {
    return GestureDetector(
      onTap: () {
        context.push(AppRoutes.menuItemDetails, extra: {
          'menuItem': menuItem,
          'restaurant': restaurant,
        });
      },
      child: Container(
        width: 240, 
        margin: const EdgeInsets.only(right: 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
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
                  height: 70,
                  width: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                      height: 70, width: 70, color: Colors.grey[200],
                      child: Icon(Icons.image_not_supported, color: Colors.grey[400])),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(menuItem.name, style: GoogleFonts.sen(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(restaurant.name, style: GoogleFonts.sen(color: Colors.grey[600], fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors1.lightPeach, borderRadius: BorderRadius.circular(6)), child: Text('${menuItem.timesPurchasedToday} bought today', style: GoogleFonts.sen(color: Colors1.primaryOrange, fontWeight: FontWeight.bold, fontSize: 10))),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(Category category,
      {required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        padding: const EdgeInsets.fromLTRB(15, 8, 15, 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors1.lightyellow : Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min, // Use min to wrap content
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: AssetImage(category.iconAsset),
            ),
            const SizedBox(width: 8), // Correct way to add spacing in Row
            Text(
              category.name,
              style: GoogleFonts.sen(
                  color: isSelected ? Colors.black87 : Colors.black),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildRestaurantCard(
    Restaurant restaurant,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 2,
        child: InkWell(
          onTap: () {
            context.push('/restaurant-details', extra: restaurant);
          },
        child: AspectRatio(
          aspectRatio: 1.7, 
          child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[300], 
            image: (restaurant.imageUrls != null && restaurant.imageUrls!.isNotEmpty)
                ? DecorationImage(
                    image: AssetImage(restaurant.imageUrls!.first),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85), 
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              restaurant.name,
                              style: GoogleFonts.sen(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              restaurant.items,
                              style: GoogleFonts.sen(
                                fontSize: 14,
                                color: Colors.grey[800],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 16.0, 
                              runSpacing: 4.0, 
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.star, color: Colors.orange[700], size: 16),
                                    Text(
                                      ' ${restaurant.calculatedRating.toStringAsFixed(1)}',
                                      style: GoogleFonts.sen(fontWeight: FontWeight.bold)
                                    ),
                                  ],
                                ),
                                Text(restaurant.deliveryFee,
                                    style: GoogleFonts.sen()),
                                Text(restaurant.deliveryTime,
                                    style: GoogleFonts.sen()),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          ),
        ),
        ),
      ),
    );
  }

  void _showCouponDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          
          content: Container(
            height: 395,
            width: 327,
            decoration: BoxDecoration(
              image: DecorationImage(image: 
              AssetImage('assets/background/card/card1.png'))
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
            'Hurry Offers!',
             style: GoogleFonts.sen(fontSize: 30, fontWeight: FontWeight.bold,color: Colors.white)
          ),
                Text('#1243CD2', style: GoogleFonts.sen(fontSize: 24, fontWeight: FontWeight.bold,color: Colors.white)),
                const SizedBox(height: 10),
                Text('Use the coupon get 25% discount', style: GoogleFonts.sen(color: Colors.white, fontSize: 16)),
                const SizedBox(height: 20),
                Container(
                  margin: EdgeInsets.all(8),
                  width: double.infinity,
                  child: ElevatedButton(
                                 style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      side: const BorderSide(color: Colors.white),
                      
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(); 
                    },
                    child: Text('GOT IT',style: GoogleFonts.sen(color: Colors.white, fontWeight: FontWeight.bold),),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
