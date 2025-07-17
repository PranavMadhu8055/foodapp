import 'package:flutter/material.dart';
import 'package:foodapp/app_routes.dart';
import 'package:foodapp/core/colors/colors.dart';
import 'package:foodapp/models/restaurant_data.dart';
import 'package:foodapp/providers/restaurant_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Clear search query when entering the page, to ensure recent searches are shown initially.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<RestaurantProvider>();
      if (provider.searchQuery.isNotEmpty) {
        provider.filterBySearch('');
      }
    });
    _searchController.addListener(() {
      // Live search as user types
      context.read<RestaurantProvider>().filterBySearch(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchSubmitted(String query) {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isNotEmpty) {
      context.read<RestaurantProvider>().addSearchQuery(trimmedQuery);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search food or restaurants...',
            border: InputBorder.none,
            hintStyle: GoogleFonts.sen(color: Colors.grey),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      _searchController.clear();
                    },
                  )
                : null,
          ),
          onSubmitted: _onSearchSubmitted,
          style: GoogleFonts.sen(color: Colors.black),
        ),
      ),
      body: Consumer<RestaurantProvider>(
        builder: (context, provider, child) {
          if (provider.searchQuery.isEmpty) {
            return _buildInitialState(context, provider);
          } else {
            return _buildSearchResults(context, provider);
          }
        },
      ),
    );
  }

  Widget _buildInitialState(BuildContext context, RestaurantProvider provider) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        if (provider.recentSearches.isNotEmpty) ...[
          _buildSectionHeader('Recent Searches'),
          const SizedBox(height: 12),
          _buildRecentSearches(context, provider),
          const SizedBox(height: 24),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.sen(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildRecentSearches(BuildContext context, RestaurantProvider provider) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: provider.recentSearches.map((searchTerm) {
        return ActionChip(
          avatar: const Icon(Icons.history, size: 18, color: Colors.black54),
          label: Text(searchTerm),
          onPressed: () {
            _searchController.text = searchTerm;
            _searchController.selection =
                TextSelection.fromPosition(TextPosition(offset: searchTerm.length));
          },
          backgroundColor: Colors.grey[100],
          labelStyle: GoogleFonts.sen(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.grey[300]!),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSearchResults(BuildContext context, RestaurantProvider provider) {
    final restaurants = provider.filteredRestaurants;
    final menuItems = provider.filteredMenuItems;

    if (restaurants.isEmpty && menuItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 60, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: GoogleFonts.sen(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different keyword or check your spelling.',
              style: GoogleFonts.sen(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView(
      children: [
        if (restaurants.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: _buildSectionHeader('Restaurants'),
          ),
          ...restaurants.map((restaurant) => _buildRestaurantResult(context, restaurant)),
        ],
        if (menuItems.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: _buildSectionHeader('Menu Items'),
          ),
          ...menuItems.map((entry) => _buildMenuItemResult(context, entry.key, entry.value)),
        ],
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildRestaurantResult(BuildContext context, Restaurant restaurant) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            (restaurant.imageUrls?.isNotEmpty ?? false)
                ? restaurant.imageUrls!.first
                : 'assets/images/placeholder.png',
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(restaurant.name, style: GoogleFonts.sen(fontWeight: FontWeight.bold)),
        subtitle: Text(restaurant.items, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => context.push(AppRoutes.restaurantDetails, extra: restaurant),
      ),
    );
  }

  Widget _buildMenuItemResult(BuildContext context, MenuItem menuItem, Restaurant restaurant) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            (menuItem.imageUrls?.isNotEmpty ?? false)
                ? menuItem.imageUrls!.first
                : 'assets/images/placeholder.png',
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(menuItem.name, style: GoogleFonts.sen(fontWeight: FontWeight.bold)),
        subtitle: Text('From ${restaurant.name}', style: GoogleFonts.sen()),
        trailing: Text(menuItem.price, style: GoogleFonts.sen(fontWeight: FontWeight.bold, color: Colors1.primaryOrange)),
        onTap: () => context.push(
          AppRoutes.menuItemDetails,
          extra: {'menuItem': menuItem, 'restaurant': restaurant},
        ),
      ),
    );
  }
}