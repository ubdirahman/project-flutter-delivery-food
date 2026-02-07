import 'package:flutter/material.dart';
import '../data/models/food_model.dart';
import '../data/services/api_service.dart';

// This class manages the food-related data for the entire app.
// "ChangeNotifier" is a special Flutter tool that tells the UI to rebuild when data changes.
class FoodProvider with ChangeNotifier {
  List<FoodModel> _foods = [];
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  List<FoodModel> get foods => _foods;
  bool get isLoading => _isLoading;

  // This function gets the list of food from our backend server
  Future<void> fetchFoods({String? restaurantId}) async {
    _isLoading = true;
    notifyListeners();

    _foods = await _apiService.getFoods(restaurantId: restaurantId);

    _isLoading = false;
    notifyListeners();
  }

  List<FoodModel> get popularFoods =>
      _foods.where((food) => food.isPopular).toList();

  // Automatically creates a list of categories based on the food we have
  List<String> get categories {
    final cats = _foods.map((food) => food.category).toSet().toList();
    if (!cats.contains('All')) cats.insert(0, 'All');
    return cats;
  }

  List<FoodModel> searchFoods(String query) {
    if (query.isEmpty) return _foods;
    return _foods
        .where(
          (food) =>
              food.name.toLowerCase().contains(query.toLowerCase()) ||
              food.category.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  List<FoodModel> getFoodsByCategory(String category) {
    if (category == 'All') return _foods;
    return _foods.where((food) => food.category == category).toList();
  }
}
