import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodapp/models/user_review.dart'; // Import UserReview model
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:foodapp/screens/address_management_screens.dart'; // Import Address model
import 'package:foodapp/models/restaurant_data.dart'; // Import Restaurant and Review models


class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  // A reference to the 'users' collection in Firestore
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');
  // New: Reference to the 'userReviews' collection
  final CollectionReference userReviewsCollection = FirebaseFirestore.instance.collection('userReviews');
  // New: Reference to the 'addresses' collection
  final CollectionReference addressesCollection = FirebaseFirestore.instance.collection('addresses');
  // New: Reference to the 'restaurantReviews' collection
  final CollectionReference restaurantReviewsCollection = FirebaseFirestore.instance.collection('restaurantReviews');

  /// Creates a new document for a user in the 'users' collection.
  ///
  /// This is typically called right after a user registers.
  Future<void> createUserData(String name, String email) async {
    return userCollection.doc(uid).set({
      'name': name,
      'email': email,
      'bio': 'I love fast food!', // A default bio
      'phoneNumber': '', // A default phone number
      'profileImageUrl': '', // A default profile image URL
      'createdAt': FieldValue.serverTimestamp(), // The time the account was created
    });
  }

  /// Gets a user's profile data from the 'users' collection.
  Future<DocumentSnapshot> getUserProfile(String userId) {
    return userCollection.doc(userId).get();
  }

  /// Updates a user's profile data in the 'users' collection.
  Future<void> updateUserProfile(String userId, Map<String, dynamic> profileData) async {
    // No need to add userId to the data, as we're updating the user's own doc.
    return await userCollection.doc(userId).update(profileData);
  }

  /// Adds a user review to the 'userReviews' collection.
  Future<void> addUserReview(String userId, Map<String, dynamic> reviewData) async {
    // Add userId to the review data for security rules
    reviewData['userId'] = userId;
    await userReviewsCollection.add(reviewData);
  }

  /// Adds a new address to the 'addresses' collection for a specific user.
  Future<void> addAddress(String userId, Map<String, dynamic> addressData) async {
    // Add userId to the address data for security rules
    addressData['userId'] = userId;
    return await addressesCollection.doc(addressData['id']).set(addressData);
  }

  /// Updates an existing address in the 'addresses' collection.
  Future<void> updateAddress(String userId, String addressId, Map<String, dynamic> updateData) async {
    // Ensure the update is for the correct user's address
    return await addressesCollection.doc(addressId).update(updateData);
  }

  /// Deletes an address from the 'addresses' collection.
  Future<void> deleteAddress(String userId, String addressId) async {
    // Ensure the deletion is for the correct user's address
    return await addressesCollection.doc(addressId).delete();
  }

  /// Gets a stream of addresses for a specific user.
  Stream<List<Address>> getUserAddressesStream(String userId) {
    return addressesCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Address.fromMap(doc.data() as Map<String, dynamic>)).toList());
  }

  /// Gets a stream of user reviews for a specific user.
  Stream<List<UserReview>> getUserReviewsStream(String userId) {
    return userReviewsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('review.date', descending: true) // Order by review date
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => UserReview.fromMap(doc.data() as Map<String, dynamic>)).toList());
  }

  /// Adds a restaurant review to the 'restaurantReviews' collection.
  Future<void> addRestaurantReview(String restaurantId, String userId, Review review) async {
    try {
      // Create a new document in the restaurantReviews collection
      // The document will contain the review data, a reference to the restaurant, and the userId.
      await restaurantReviewsCollection.add({
        'restaurantId': restaurantId,
        'userId': userId, // Add userId to the review document
        ...review.toMap(), // Spread the review's map data
      });
      debugPrint('Successfully added restaurant review for restaurantId: $restaurantId by userId: $userId');
    } on FirebaseException catch (e) {
      debugPrint('FirebaseException adding restaurant review: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Error adding restaurant review: $e');
      rethrow;
    }
  }

  /// Gets a stream of reviews for a specific restaurant from the 'restaurantReviews' collection.
  Stream<List<Review>> getRestaurantReviewsStream(String restaurantId) {
    return restaurantReviewsCollection
        .where('restaurantId', isEqualTo: restaurantId)
        .orderBy('date', descending: true) // Order by date, newest first
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return Review.fromMap(doc.data() as Map<String, dynamic>);
            }).toList());
  }
}