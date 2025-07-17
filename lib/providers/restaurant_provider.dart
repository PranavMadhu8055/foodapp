import 'package:flutter/foundation.dart' hide Category;
import 'dart:math'; // For generating random order IDs
import 'package:foodapp/models/restaurant_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RestaurantProvider with ChangeNotifier {
  // Original data
  final List<Restaurant> _allRestaurants = sampleRestaurants;
  final List<Category> _allCategories = sampleCategories;

  // State variables
  String _selectedCategory = 'All';
  String _searchQuery = '';
  late List<Restaurant> _filteredRestaurants;
  final Map<MenuItem, int> _cartItems = {};
  final Set<String> _favoriteRestaurantNames = {};
  // New: Map to store favorited MenuItems along with their parent Restaurant
  String? _cartRestaurantName;
  final List<Order> _orders = []; // New list to store orders
  final Map<MenuItem, Restaurant> _favoriteMenuItemsWithRestaurant = {};
  List<String> _recentSearches = [];
  static const _recentSearchesKey = 'recent_searches';

  RestaurantProvider() {
    _filteredRestaurants = _allRestaurants;
    _loadRecentSearches();
  }

  // Getters for the UI to consume
  List<Restaurant> get filteredRestaurants => _filteredRestaurants;
  List<Category> get categories => _allCategories;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  Map<MenuItem, int> get cartItems => _cartItems;
  String? get cartRestaurantName => _cartRestaurantName;
  List<Order> get orders => _orders; // Getter for orders
  // New: Getter for favorited MenuItems (keys of the map)
  Map<MenuItem, Restaurant> get favoriteMenuItemsWithRestaurant => _favoriteMenuItemsWithRestaurant;
  List<String> get recentSearches => _recentSearches;

  /// Returns a list of menu items, paired with their restaurant, that are considered "popular".
  ///
  /// Popularity is determined by items having a calculated rating greater than 4.5.
  /// The list is sorted by rating in descending order.
  List<MapEntry<MenuItem, Restaurant>> get popularMenuItems {
    final allItemsWithRestaurant = <MapEntry<MenuItem, Restaurant>>[];
    for (final restaurant in _allRestaurants) {
      for (final menuItem in restaurant.menu) {
        if (menuItem.calculatedRating != null && menuItem.calculatedRating! > 4.5) {
          allItemsWithRestaurant.add(MapEntry(menuItem, restaurant));
        }
      }
    }

    // Sort by rating in descending order
    allItemsWithRestaurant.sort((a, b) {
      final ratingB = b.key.calculatedRating ?? 0.0;
      final ratingA = a.key.calculatedRating ?? 0.0;
      return ratingB.compareTo(ratingA);
    });

    return allItemsWithRestaurant;
  }

  /// Returns a list of menu items, paired with their restaurant, that are considered "most bought".
  ///
  /// This is determined by the `timesPurchasedToday` property on a `MenuItem`.
  /// The list is sorted by the number of purchases in descending order.
  List<MapEntry<MenuItem, Restaurant>> get mostBoughtItems {
    final allItemsWithRestaurant = <MapEntry<MenuItem, Restaurant>>[];
    for (final restaurant in _allRestaurants) {
      for (final menuItem in restaurant.menu) {
        if (menuItem.timesPurchasedToday != null && menuItem.timesPurchasedToday! > 0) {
          allItemsWithRestaurant.add(MapEntry(menuItem, restaurant));
        }
      }
    }

    // Sort by times purchased in descending order
    allItemsWithRestaurant.sort((a, b) => (b.key.timesPurchasedToday ?? 0).compareTo(a.key.timesPurchasedToday ?? 0));

    return allItemsWithRestaurant;
  }

  /// Returns a list of menu items, paired with their restaurant, that match the current search query.
  List<MapEntry<MenuItem, Restaurant>> get filteredMenuItems {
    if (_searchQuery.isEmpty) {
      return [];
    }
    final searchLower = _searchQuery.toLowerCase();
    final results = <MapEntry<MenuItem, Restaurant>>[];

    for (final restaurant in _allRestaurants) {
      for (final menuItem in restaurant.menu) {
        final nameMatch = menuItem.name.toLowerCase().contains(searchLower);
        final descriptionMatch = menuItem.description?.toLowerCase().contains(searchLower) ?? false;
        final categoryMatch = menuItem.category.toLowerCase().contains(searchLower);

        if (nameMatch || descriptionMatch || categoryMatch) {
          results.add(MapEntry(menuItem, restaurant));
        }
      }
    }
    return results;
  }

  int get cartItemCount {
    int total = 0;
    _cartItems.forEach((key, value) {
      total += value;
    });
    return total;
  }

  bool isFavorite(String restaurantName) {
    return _favoriteRestaurantNames.contains(restaurantName);
  }

  // New: Check if a MenuItem is favorited
  bool isMenuItemFavorite(MenuItem item) {
    return _favoriteMenuItemsWithRestaurant.containsKey(item);
  }

  // New: Toggle favorite status for a MenuItem
  void toggleMenuItemFavorite(MenuItem item, Restaurant restaurant) {
    if (_favoriteMenuItemsWithRestaurant.containsKey(item)) {
      _favoriteMenuItemsWithRestaurant.remove(item);
    } else {
      _favoriteMenuItemsWithRestaurant[item] = restaurant;
    }
    notifyListeners();
  }

  // New: Add a review to a menu item
  void addReviewToMenuItem({
    required MenuItem menuItem,
    required Restaurant restaurant,
    required Review review,
  }) {
    final restaurantIndex = _allRestaurants.indexWhere((r) => r.name == restaurant.name);
    if (restaurantIndex != -1) {
      final menuItemIndex = _allRestaurants[restaurantIndex].menu.indexWhere((item) => item.name == menuItem.name);
      if (menuItemIndex != -1) {
        // Directly add the review to the existing mutable list
        _allRestaurants[restaurantIndex].menu[menuItemIndex].reviews.insert(0, review);
        notifyListeners();
      }
    }
  }

  // New: Add a review to a restaurant
  void addReviewToRestaurant({
    required Restaurant restaurant,
    required Review review,
  }) {
    final restaurantIndex = _allRestaurants.indexWhere((r) => r.name == restaurant.name);
    if (restaurantIndex != -1) {
      // Directly add the review to the existing mutable list
      _allRestaurants[restaurantIndex].reviews.insert(0, review);
      notifyListeners();
    }
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    _recentSearches = prefs.getStringList(_recentSearchesKey) ?? [];
    notifyListeners();
  }

  Future<void> addSearchQuery(String query) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) return;

    // Remove if it already exists to move it to the front
    _recentSearches.removeWhere((s) => s.toLowerCase() == trimmedQuery.toLowerCase());
    // Add to the beginning
    _recentSearches.insert(0, trimmedQuery);
    // Limit the list size to 5
    if (_recentSearches.length > 5) {
      _recentSearches = _recentSearches.sublist(0, 5);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_recentSearchesKey, _recentSearches);
    filterBySearch(trimmedQuery);
  }

  // Methods to update state
  void _runFilters() {
    List<Restaurant> results;

    // Category filter
    if (_selectedCategory == 'All') {
      results = _allRestaurants;
    } else {
      results = _allRestaurants
          .where((r) => r.categories.contains(_selectedCategory))
          .toList();
    }

    // Search filter
    if (_searchQuery.isNotEmpty) {
      final searchLower = _searchQuery.toLowerCase();
      results = results.where((restaurant) {
        final restaurantNameMatch = restaurant.name.toLowerCase().contains(searchLower);
        final restaurantDescriptionMatch = restaurant.description.toLowerCase().contains(searchLower);
        final restaurantItemsMatch = restaurant.items.toLowerCase().contains(searchLower);

        // Also check if any menu item in this restaurant matches the query
        final menuItemMatch = restaurant.menu.any((menuItem) =>
            menuItem.name.toLowerCase().contains(searchLower) ||
            (menuItem.description?.toLowerCase().contains(searchLower) ?? false) ||
            menuItem.category.toLowerCase().contains(searchLower)
        );

        return restaurantNameMatch || restaurantDescriptionMatch || restaurantItemsMatch || menuItemMatch;
      }).toList();
    }

    _filteredRestaurants = results;
    notifyListeners(); // This tells widgets listening to this provider to rebuild
  }

  void filterByCategory(String category) {
    _selectedCategory = category;
    _runFilters();
  }

  void filterBySearch(String query) {
    _searchQuery = query;
    _runFilters();
  }

  void toggleFavorite(String restaurantName) {
    if (_favoriteRestaurantNames.contains(restaurantName)) {
      _favoriteRestaurantNames.remove(restaurantName);
    } else {
      _favoriteRestaurantNames.add(restaurantName);
    }
    notifyListeners();
  }

  void addToCart(MenuItem item) {
    final restaurant = findRestaurantForMenuItem(item);
    if (restaurant == null) return; // Should not happen

    // Prevent adding items from a different restaurant to the cart.
    if (_cartRestaurantName != null && _cartRestaurantName != restaurant.name) {
      // In a real app, you might show a dialog asking to clear the cart.
      // For now, we just prevent the action and print a message.
      print('Error: Cannot add items from different restaurants to the same cart.');
      return;
    }

    // If the cart is empty, set the restaurant for this cart session.
    if (_cartItems.isEmpty) {
      _cartRestaurantName = restaurant.name;
    }
    if (_cartItems.containsKey(item)) {
      _cartItems[item] = _cartItems[item]! + 1;
    } else {
      _cartItems[item] = 1;
    }
    notifyListeners();
  }

  /// Adds a specified quantity of a menu item to the cart efficiently.
  void addMultipleToCart(MenuItem menuItem, int quantity) {
    final restaurant = findRestaurantForMenuItem(menuItem);
    if (restaurant == null) return; // Should not happen

    if (_cartRestaurantName != null && _cartRestaurantName != restaurant.name) {
      print('Error: Cannot add items from different restaurants to the same cart.');
      return;
    }

    if (_cartItems.isEmpty) {
      _cartRestaurantName = restaurant.name;
    }

    if (_cartItems.containsKey(menuItem)) {
      // If item is already in the cart, increase its quantity
      _cartItems[menuItem] = _cartItems[menuItem]! + quantity;
    } else {
      // Otherwise, add the new item with the specified quantity
      _cartItems[menuItem] = quantity;
    }
    notifyListeners();
  }

  void placeOrder() {
    if (_cartItems.isEmpty) {
      return; // Cannot place an empty order
    }

    final String newOrderId = '#${Random().nextInt(999999).toString().padLeft(6, '0')}';
    final double orderTotal = getCartTotal();
    final int totalItems = cartItemCount;
    final String vendorName = _cartRestaurantName ?? 'Unknown';

    final List<MapEntry<MenuItem, int>> orderItems = _cartItems.entries.map((entry) => MapEntry(entry.key, entry.value)).toList();

    final newOrder = Order(orderId: newOrderId, vendor: vendorName, totalPrice: orderTotal, totalItems: totalItems, items: orderItems, orderDate: DateTime.now(), status: OrderStatus.ongoing);

    _orders.insert(0, newOrder); // Add new order to the beginning of the list
    _cartItems.clear(); // Clear the cart after placing the order
    _cartRestaurantName = null; // Reset the cart's restaurant
    notifyListeners();
  }

  /// Adds all items from a previous order back into the cart.
  void reorder(Order order) {
    // Clear the current cart to avoid mixing restaurants.
    _cartItems.clear();
    _cartRestaurantName = null;

    for (final entry in order.items) {
      final menuItem = entry.key;
      final quantity = entry.value;
      addMultipleToCart(menuItem, quantity);
    }
  }

  /// Finds the Restaurant object that a given MenuItem belongs to.
  Restaurant? findRestaurantForMenuItem(MenuItem menuItem) {
    for (final restaurant in _allRestaurants) {
      if (restaurant.menu.contains(menuItem)) {
        return restaurant;
      }
    }
    return null; // Should not happen if data is consistent
  }

  void cancelOrder(Order orderToCancel) {
    final index = _orders.indexWhere((order) => order.orderId == orderToCancel.orderId);
    if (index != -1) {
      _orders[index].status = OrderStatus.cancelled;
      notifyListeners();
    }
  }

  void removeFromCart(MenuItem item) {
    if (_cartItems.containsKey(item) && _cartItems[item]! > 1) {
      _cartItems[item] = _cartItems[item]! - 1;
    } else {
      _cartItems.remove(item);
    }
    // If cart becomes empty, reset the restaurant lock.
    if (_cartItems.isEmpty) {
      _cartRestaurantName = null;
    }
    notifyListeners();
  }

  void clearItemFromCart(MenuItem item) {
    _cartItems.remove(item);
    if (_cartItems.isEmpty) {
      _cartRestaurantName = null;
    }
    notifyListeners();
  }

  double getCartTotal() {
    double total = 0.0;
    _cartItems.forEach((menuItem, quantity) {
      double price = double.tryParse(menuItem.price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
      total += price * quantity;
    });
    return total;
  }

  // New: Find Restaurant by ID
  Restaurant? findRestaurantById(String restaurantId) {
    try {
      return _allRestaurants.firstWhere((r) => r.id == restaurantId);
    } catch (e) {
      return null;
    }
  }

  // New: Find MenuItem by Restaurant ID and MenuItem ID
  MenuItem? findMenuItemById(String restaurantId, String menuItemId) {
    final restaurant = findRestaurantById(restaurantId);
    if (restaurant != null) {
      try {
        return restaurant.menu.firstWhere((item) => item.id == menuItemId);
      } catch (e) {}
    }
    return null;
  }
}