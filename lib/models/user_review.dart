import 'package:foodapp/models/restaurant_data.dart';

enum ReviewableType { restaurant, menuItem }

class UserReview {
  final Review review;
  final String reviewSubjectName;
  final ReviewableType type;
  // This holds identifying information for the subject of the review.
  // For menuItem: {'restaurantId': '...', 'menuItemId': '...'}
  // For restaurant: {'restaurantId': '...'}
  Map<String, dynamic> subject; // Changed to mutable Map

  UserReview({
    required this.review,
    required this.reviewSubjectName,
    required this.type,
    required this.subject,
  });

  // Convert UserReview object to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'review': review.toMap(),
      'reviewSubjectName': reviewSubjectName,
      'type': type.toString().split('.').last, // Store enum as string
      'subject': subject,
    };
  }

  // Create UserReview object from a Map (from Firestore)
  factory UserReview.fromMap(Map<String, dynamic> map) {
    return UserReview(review: Review.fromMap(map['review'] as Map<String, dynamic>), reviewSubjectName: map['reviewSubjectName'] as String, type: ReviewableType.values.firstWhere((e) => e.toString().split('.').last == map['type']), subject: map['subject'] as Map<String, dynamic>);
  }
}