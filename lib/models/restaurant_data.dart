class Review {
  final String userName;
  final String userImageUrl;
  final double rating;
  final String comment;
  final DateTime date;

  Review({
    required this.userName,
    required this.userImageUrl,
    required this.rating,
    required this.comment,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'userName': userName,
      'userImageUrl': userImageUrl,
      'rating': rating,
      'comment': comment,
      'date': date.toIso8601String(), // Store date as ISO string
    };
  }

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      userName: map['userName'] as String,
      userImageUrl: map['userImageUrl'] as String,
      rating:
          (map['rating'] as num).toDouble(), // Handle int/double from Firestore
      comment: map['comment'] as String,
      date: DateTime.parse(
          map['date'] as String), // Parse ISO string back to DateTime
    );
  }
}

enum OrderStatus {
  ongoing,
  completed,
  cancelled,
}

class Order {
  final String orderId;
  final String vendor;
  final double totalPrice;
  final int totalItems;
  final List<MapEntry<MenuItem, int>> items; // List of menu item and quantity
  final DateTime orderDate;
  OrderStatus status;

  Order(
      {required this.orderId,
      required this.vendor,
      required this.totalPrice,
      required this.totalItems,
      required this.items,
      required this.orderDate,
      this.status = OrderStatus.ongoing});
}

class Category {
  final String name;
  final String iconAsset;

  Category({required this.name, required this.iconAsset});
}

class MenuItem {
  final String id; // New unique ID for MenuItem
  final String name;
  final String price;
  final String category; // e.g., 'Burger', 'Dessert', 'Drinks'
  final List<String>? imageUrls; // Changed to list for multiple images
  final String? description;
  final double? rating;
  final String? deliveryFee;
  final String? deliveryTime;
  final List<Review> reviews;
  final int? timesPurchasedToday;

  MenuItem({
    required this.id, // ID is now required
    required this.name,
    required this.price,
    required this.category,
    this.imageUrls,
    this.description,
    this.rating,
    this.deliveryFee,
    this.deliveryTime,
    List<Review>? reviews,
    this.timesPurchasedToday,
  }) : this.reviews = reviews ?? [];

  // Calculated property for average rating from reviews
  double? get calculatedRating {
    if (reviews.isEmpty) {
      return rating; // Fallback to the initial rating if no reviews
    }
    return reviews.map((r) => r.rating).reduce((a, b) => a + b) /
        reviews.length;
  }

  // By overriding equality, we can reliably use MenuItem in collections like Maps and Sets.
  // This ensures that two MenuItem objects are considered the same if their names are the same,
  // which is crucial for cart operations and lookups.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MenuItem &&
          runtimeType == other.runtimeType &&
          id == other.id; // Compare by ID

  @override
  int get hashCode => id.hashCode; // Hash by ID

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'category': category,
      'imageUrls': imageUrls,
      'description': description,
      'rating': rating,
      'deliveryFee': deliveryFee,
      'deliveryTime': deliveryTime,
      'reviews': reviews.map((r) => r.toMap()).toList(),
      'timesPurchasedToday': timesPurchasedToday,
    };
  }

  factory MenuItem.fromMap(Map<String, dynamic> map) {
    return MenuItem(
      id: map['id'] as String,
      name: map['name'] as String,
      price: map['price'] as String,
      category: map['category'] as String,
      imageUrls: (map['imageUrls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      description: map['description'] as String?,
      rating: map['rating'] as double?,
      deliveryFee: map['deliveryFee'] as String?,
      deliveryTime: map['deliveryTime'] as String?,
      reviews: (map['reviews'] as List<dynamic>?)
          ?.map((e) => Review.fromMap(e as Map<String, dynamic>))
          .toList(),
      timesPurchasedToday: map['timesPurchasedToday'] as int?,
    );
  }
}

class Restaurant {
  final String id; // New unique ID for Restaurant
  final String name;
  final String description;
  final String items;
  final double rating;
  final String deliveryFee;
  final String deliveryTime;
  final List<String>? imageUrls;
  final List<String> categories;
  final List<MenuItem> menu;
  final List<Review> reviews;

  Restaurant({
    required this.id, // ID is now required
    required this.name,
    required this.items,
    required this.description,
    required this.rating,
    required this.deliveryFee,
    required this.deliveryTime,
    this.imageUrls,
    required this.categories,
    required this.menu,
    List<Review>? reviews,
  }) : this.reviews = reviews ?? [];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'items': items,
      'description': description,
      'rating': rating,
      'deliveryFee': deliveryFee,
      'deliveryTime': deliveryTime,
      'imageUrls': imageUrls,
      'categories': categories,
      'menu': menu.map((m) => m.toMap()).toList(),
      // 'reviews': reviews.map((r) => r.toMap()).toList(), // Reviews are now in a separate collection
    };
  }

  factory Restaurant.fromMap(Map<String, dynamic> map) {
    return Restaurant(
      id: map['id'] as String,
      name: map['name'] as String,
      items: map['items'] as String,
      description: map['description'] as String,
      rating: map['rating'] as double,
      deliveryFee: map['deliveryFee'] as String,
      deliveryTime: map['deliveryTime'] as String,
      imageUrls: (map['imageUrls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      categories:
          (map['categories'] as List<dynamic>).map((e) => e as String).toList(),
      menu: (map['menu'] as List<dynamic>)
          .map((e) => MenuItem.fromMap(e as Map<String, dynamic>))
          .toList(),
      // reviews: (map['reviews'] as List<dynamic>?)?.map((e) => Review.fromMap(e as Map<String, dynamic>)).toList(), // Reviews are now fetched separately
    );
  }

  double get calculatedRating {
    // When reviews are fetched separately, the Restaurant object itself
    // will only have its initial 'rating' field.
    // The average rating will be calculated in the UI from the streamed reviews.
    return rating;
  }
}

final List<Category> sampleCategories = [
  Category(name: 'All', iconAsset: 'assets/icons/Cart.png'),
  Category(name: 'Hot Dog', iconAsset: 'assets/icons/Cart.png'),
  Category(name: 'Burger', iconAsset: 'assets/icons/Cart.png'),
  Category(name: 'Pizza', iconAsset: 'assets/icons/Cart.png'),
  Category(name: 'Sushi', iconAsset: 'assets/icons/Cart.png'),
  Category(name: 'Dessert', iconAsset: 'assets/icons/Cart.png'),
];

final List<Restaurant> sampleRestaurants = [
  // Rose Garden Restaurant
  Restaurant(
      id: 'rg-restaurant-001',
      name: 'Rose Garden Restaurant',
      items: 'Burger - Chicken - Rice - Wings',
      description:
          'Lorem Ipsum is simply dummy text of the printing and typesetting industry.',
      rating: 4.7,
      deliveryFee: 'Free',
      deliveryTime: '20 min',
      imageUrls: [
        'assets/images/restaurant1.jpg',
        'assets/images/restaurant2.jpg',
        'assets/images/restaurant3.jpg',
      ],
      categories: const [
        'Burger',
        'Dessert'
      ],
      reviews: [
        Review(
            userName: 'Alice Johnson',
            userImageUrl: 'https://randomuser.me/api/portraits/women/3.jpg',
            rating: 4.5,
            comment:
                'Great atmosphere and the food was amazing. Will definitely come back!',
            date: DateTime.now().subtract(const Duration(days: 10))),
        Review(
            userName: 'Bob Williams',
            userImageUrl: 'https://randomuser.me/api/portraits/men/4.jpg',
            rating: 5,
            comment:
                'Best restaurant experience I have had in a while. Highly recommended.',
            date: DateTime.now().subtract(const Duration(days: 15))),
      ],
      menu: [
        // Rose Garden - Classic Burger
        MenuItem(
            name: 'Classic Burger',
            price: '\$9.99',
            category: 'Burger',
            imageUrls: [
              'assets/images/burger.jpg',
              'assets/images/burger2.jpg'
            ],
            rating: 4.8,
            deliveryTime: '15 min',
            description:
                'A juicy beef patty with fresh lettuce, tomatoes, and our secret sauce, served on a toasted bun.',
            timesPurchasedToday: 112,
            reviews: [
              Review(
                  userName: 'Jane Doe',
                  userImageUrl:
                      'https://randomuser.me/api/portraits/women/1.jpg',
                  rating: 5,
                  comment: 'Absolutely delicious! Best burger in town.',
                  date: DateTime.now().subtract(const Duration(days: 2))),
              Review(
                  userName: 'John Smith',
                  userImageUrl: 'https://randomuser.me/api/portraits/men/2.jpg',
                  rating: 4,
                  comment: 'Really good, but the bun was a little soggy.',
                  date: DateTime.now().subtract(const Duration(days: 5))),
            ],
            id: 'rg-burger-001'),
        // Rose Garden - Cheesecake
        MenuItem(
            name: 'Cheesecake',
            price: '\$6.50', // Example image
            category: 'Dessert',
            imageUrls: ['assets/images/cheesecake.jpg'],
            timesPurchasedToday: 64,
            description:
                'Creamy New York style cheesecake with a graham cracker crust.',
            id: 'rg-dessert-001'),
        // Rose Garden - Coke
        MenuItem(
            name: 'Coke',
            price: '\$2.00',
            category: 'Drinks',
            imageUrls: ['assets/images/coke.jpg'],
            id: 'rg-drink-001'),
      ]),
  // Burger Palace
  Restaurant(
      id: 'bp-restaurant-001',
      name: 'Burger Palace',
      items: 'Burgers - Fries - Shakes',
      description:
          'Lorem Ipsum is simply dummy text of the printing and typesetting industry.',
      rating: 4.5,
      deliveryFee: '\$0.99',
      deliveryTime: '15 min',
      imageUrls: [
        'assets/images/restaurant2.jpg',
        'assets/images/restaurant4.jpg',
      ],
      categories: const [
        'Burger',
        'Hot Dog'
      ],
      menu: [
        // Burger Palace - Bacon Burger
        MenuItem(
            name: 'Bacon Burger',
            price: '\$11.99',
            category: 'Burger', // Example image
            imageUrls: ['assets/images/burger.jpg'],
            timesPurchasedToday: 89,
            description: 'A hearty burger with crispy bacon and melted cheese.',
            id: 'bp-burger-001'),
        // Burger Palace - Chili Dog
        MenuItem(
            name: 'Chili Dog',
            price: '\$7.99',
            category: 'Hot Dog',
            imageUrls: ['assets/images/hotdog.jpg'],
            timesPurchasedToday: 45,
            rating: 4.6,
            id: 'bp-hotdog-001'),
        // Burger Palace - Fries
        MenuItem(
            name: 'Fries',
            price: '\$3.99',
            category: 'Sides',
            imageUrls: ['assets/images/fries.jpg'],
            id: 'bp-side-001'),
      ]),
  // Pizza Hub
  Restaurant(
      id: 'ph-restaurant-001',
      name: 'Pizza Hub',
      items: 'Italian - Pizza - Pasta',
      description:
          'Lorem Ipsum is simply dummy text of the printing and typesetting industry.',
      rating: 4.2,
      deliveryFee: '\$1.50',
      deliveryTime: '30 min',
      imageUrls: [
        'assets/images/restaurant3.jpg',
        'assets/images/restaurant1.jpg',
      ],
      categories: const [
        'Pizza'
      ],
      menu: [
        // Pizza Hub - Pepperoni Pizza
        MenuItem(
            name: 'Pepperoni Pizza',
            price: '\$14.99',
            category: 'Pizza', // Example image
            imageUrls: ['assets/images/pizza.jpg'],
            timesPurchasedToday: 78,
            description:
                'Classic pepperoni pizza with a rich tomato sauce and mozzarella cheese.',
            id: 'ph-pizza-001'),
        // Pizza Hub - Spaghetti
        MenuItem(
            name: 'Spaghetti',
            price: '\$12.00',
            category: 'Pasta',
            imageUrls: ['assets/images/pasta.jpg'],
            id: 'ph-pasta-001'),
      ]),
  // Sushi Master
  Restaurant(
      id: 'sm-restaurant-001',
      name: 'Sushi Master',
      items: 'Japanese - Sushi - Sashimi',
      description:
          'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum is simply dummy text of the printing and typesetting industry.Lorem Ipsum is simply dummy text of the printing and typesetting industry.Lorem Ipsum is simply dummy text of the printing and typesetting industry.',
      rating: 4.9,
      deliveryFee: 'Free',
      deliveryTime: '25 min',
      imageUrls: [
        'assets/images/restaurant4.jpg'
      ],
      categories: const [
        'Sushi'
      ],
      menu: [
        // Sushi Master - California Roll
        MenuItem(
            name: 'California Roll',
            price: '\$8.00',
            category: 'Sushi',
            imageUrls: ['assets/images/sushi.jpg'],
            timesPurchasedToday: 95,
            id: 'sm-sushi-001'),
        // Sushi Master - Tuna Nigiri
        MenuItem(
            name: 'Tuna Nigiri',
            price: '\$10.00',
            category: 'Sushi',
            imageUrls: ['assets/images/sushi2.jpg'],
            id: 'sm-sushi-002'),
      ]),
];
