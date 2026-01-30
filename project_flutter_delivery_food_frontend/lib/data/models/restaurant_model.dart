class RestaurantModel {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String image;
  final double rating;
  final String description;

  RestaurantModel({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.image,
    required this.rating,
    required this.description,
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    return RestaurantModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      image: json['image'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'image': image,
      'rating': rating,
      'description': description,
    };
  }
}
