import 'package:flutter/foundation.dart';
import 'dart:async'; // Import for StreamSubscription
import 'package:foodapp/models/user_review.dart';
import 'package:foodapp/models/restaurant_data.dart'; // Import Review model
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase User
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:foodapp/screens/address_management_screens.dart'; // Import Address model
import 'package:foodapp/services/database_service.dart'; // Import DatabaseService
import 'package:foodapp/services/auth_service.dart'; // Import AuthService

class UserProfileProvider with ChangeNotifier {
  String _fullName = "Guest User"; // Default for unauthenticated
  String _email = "guest@example.com"; // Default for unauthenticated
  String _phoneNumber = ""; // Default
  String _bio = "I love fast food";
  List<UserReview> _userReviews = []; // Now mutable
  List<Address> _addresses = []; // New list for addresses

  final AuthService _authService = AuthService(); // Inject AuthService
  final DatabaseService _databaseService = DatabaseService(); // Inject DatabaseService

  UserProfileProvider() {
    // Listen to auth state changes to update profile
    _authService.user.listen((user) {
      if (user != null) {
        _loadUserProfile(user);
        _loadUserReviews(user.uid); // Load reviews for the authenticated user
        _loadUserAddresses(user.uid); // Load addresses for the authenticated user
      } else {
        _resetProfileToDefaults();
      }
    });
  }

  // Stream subscriptions
  StreamSubscription? _userReviewsSubscription;
  StreamSubscription? _userAddressesSubscription;

  // Getters for UI to consume
  String get fullName => _fullName;
  String get email => _email;
  String get phoneNumber => _phoneNumber;
  String get bio => _bio;
  List<UserReview> get userReviews => _userReviews;
  List<Address> get addresses => _addresses;


  Future<void> _loadUserProfile(User user) async {
    try {
      final doc = await _databaseService.getUserProfile(user.uid);
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        _fullName = data['name'] ?? user.displayName ?? "New User";
        _email = data['email'] ?? user.email ?? "N/A";
        _phoneNumber = data['phoneNumber'] ?? "";
        _bio = data['bio'] ?? "I love fast food";
      } else {
        // Document doesn't exist, maybe it's an old user. Use auth data.
        _fullName = user.displayName ?? user.email?.split('@')[0] ?? "New User";
        _email = user.email ?? "N/A";
      }
    } catch (e) {
      print("Error loading user profile: $e");
      _resetProfileToDefaults();
    } finally {
      notifyListeners();
    }
  }

  void _loadUserReviews(String uid) {
    _userReviewsSubscription?.cancel(); // Cancel previous subscription
    _userReviewsSubscription = _databaseService.getUserReviewsStream(uid).listen((reviews) {
      _userReviews = reviews;
      notifyListeners();
    }, onError: (error) {
      print("Error loading user reviews: $error");
    });
  }

  void _loadUserAddresses(String uid) {
    _userAddressesSubscription?.cancel(); // Cancel previous subscription
    _userAddressesSubscription = _databaseService.getUserAddressesStream(uid).listen((addresses) {
      _addresses = addresses;
      notifyListeners();
    }, onError: (error) {
      print("Error loading user addresses: $error");
    });
  }

  void _resetProfileToDefaults() {
    _fullName = "Guest User";
    _email = "guest@example.com";
    _phoneNumber = "";
    _bio = "I love fast food"; // Keep bio as it's not from auth
    _userReviews = []; // Clear reviews
    _addresses = []; // Clear addresses

    // Cancel subscriptions when user logs out
    _userReviewsSubscription?.cancel();
    _userReviewsSubscription = null;
    _userAddressesSubscription?.cancel();
    _userAddressesSubscription = null;

    notifyListeners();
  }

  Future<void> updateProfile(Map<String, String> updatedProfile) async {
    _fullName = updatedProfile['fullName'] ?? _fullName;
    _phoneNumber = updatedProfile['phoneNumber'] ?? _phoneNumber;
    _bio = updatedProfile['bio'] ?? _bio;
    notifyListeners();

    // Also update in Firestore
    final user = _authService.currentUser;
    if (user != null) {
      await _databaseService.updateUserProfile(user.uid, {
        'name': _fullName,
        'phoneNumber': _phoneNumber,
        'bio': _bio,
      });
    }
  }

  Future<void> addUserReview(UserReview review) async {
    final user = _authService.currentUser;
    if (user != null) {
      await _databaseService.addUserReview(user.uid, review.toMap());

      // If the review is for a restaurant, also add it to the general restaurant reviews collection
      if (review.type == ReviewableType.restaurant && review.subject.containsKey('restaurantId')) {
        final restaurantId = review.subject['restaurantId'] as String;
        await _databaseService.addRestaurantReview(restaurantId, user.uid, review.review); // Pass user.uid
      }
    }
    // Reviews are now streamed, so no need to insert locally.
    // The stream listener will update _userReviews and call notifyListeners().
  }

  Future<void> addAddress(Address address) async {
    final user = _authService.currentUser;
    if (user != null) {
      await _databaseService.addAddress(user.uid, address.toMap());
    }
    // Addresses are now streamed, so no need to insert locally.
  }

  Future<void> updateAddress(Address address) async {
    final user = _authService.currentUser;
    if (user != null) {
      await _databaseService.updateAddress(user.uid, address.id, address.toMap());
    }
    // Addresses are now streamed.
  }

  Future<void> deleteAddress(String addressId) async {
    final user = _authService.currentUser;
    if (user != null) {
      await _databaseService.deleteAddress(user.uid, addressId);
    }
    // No need to call notifyListeners() here.
    // The stream will update the list and the listener will call it.
  }
}