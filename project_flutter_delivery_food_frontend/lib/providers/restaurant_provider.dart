import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../data/models/restaurant_model.dart';

class RestaurantProvider with ChangeNotifier {
  List<RestaurantModel> _restaurants = [];
  bool _isLoading = false;
  String? _error;

  List<RestaurantModel> get restaurants => [..._restaurants];
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchRestaurants() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/admin/restaurants'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _restaurants = data
            .map((json) => RestaurantModel.fromJson(json))
            .toList();
        _error = null;
      } else {
        _error = 'Failed to load restaurants';
      }
    } catch (e) {
      _error = 'Error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
