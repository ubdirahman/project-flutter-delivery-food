class FoodModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String image;
  final String category;
  final double rating;
  final int quantity;
  final bool isPopular;
  final String? restaurantId;

  FoodModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.category,
    this.rating = 0.0,
    this.quantity = 0,
    this.isPopular = false,
    this.restaurantId,
  });

  factory FoodModel.fromJson(Map<String, dynamic> json) {
    return FoodModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      image: json['image'] ?? '',
      category: json['category'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
      isPopular: json['isPopular'] ?? false,
      restaurantId: json['restaurantId'],
    );
  }
}
