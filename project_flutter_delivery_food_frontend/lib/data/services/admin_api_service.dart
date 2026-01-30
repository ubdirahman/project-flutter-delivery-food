import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AdminApiService {
  static const String baseUrl = 'http://localhost:5000/api/admin';

  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/stats'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {};
    } catch (e) {
      print('Stats error: $e');
      return {};
    }
  }

  Future<List<dynamic>> getPerformanceData() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/performance'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return [];
    } catch (e) {
      print('Performance error: $e');
      return [];
    }
  }

  Future<List<dynamic>> getAllOrders() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/orders'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return [];
    } catch (e) {
      print('Fetch all orders error: $e');
      return [];
    }
  }

  Future<bool> updateOrderStatus(String orderId, String status) async {
    try {
      // Assuming we use orderRoutes for this as it's a general order update
      final response = await http.put(
        Uri.parse('http://localhost:5000/api/orders/$orderId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'status': status}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Update status error: $e');
      return false;
    }
  }

  Future<bool> addFood(Map<String, dynamic> foodData) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000/api/foods'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(foodData),
      );
      return response.statusCode == 201;
    } catch (e) {
      print('Add food error: $e');
      return false;
    }
  }

  Future<bool> updateFood(String id, Map<String, dynamic> foodData) async {
    try {
      final response = await http.put(
        Uri.parse('http://localhost:5000/api/foods/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(foodData),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Update food error: $e');
      return false;
    }
  }

  Future<bool> deleteFood(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:5000/api/foods/$id'),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Delete food error: $e');
      return false;
    }
  }

  Future<bool> createOrder(Map<String, dynamic> orderData) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000/api/orders'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(orderData),
      );
      return response.statusCode == 201;
    } catch (e) {
      print('Create order error: $e');
      return false;
    }
  }

  Future<bool> deleteOrder(String orderId) async {
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:5000/api/orders/$orderId'),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Delete order error: $e');
      return false;
    }
  }

  Future<String?> uploadFoodImage(dynamic imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://localhost:5000/api/users/upload'),
      );

      if (kIsWeb) {
        final bytes = await imageFile.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            bytes,
            filename: imageFile.name,
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      } else {
        request.files.add(
          await http.MultipartFile.fromPath('image', imageFile.path),
        );
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['imageUrl'];
      }
      return null;
    } catch (e) {
      print('Upload food image error: $e');
      return null;
    }
  }

  // Restaurant Methods
  Future<List<dynamic>> getRestaurants() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/restaurants'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return [];
    } catch (e) {
      print('Get restaurants error: $e');
      return [];
    }
  }

  Future<bool> addRestaurant(Map<String, dynamic> restaurantData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/restaurants'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(restaurantData),
      );
      return response.statusCode == 201;
    } catch (e) {
      print('Add restaurant error: $e');
      return false;
    }
  }

  Future<bool> updateRestaurant(
    String id,
    Map<String, dynamic> restaurantData,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/restaurants/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(restaurantData),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Update restaurant error: $e');
      return false;
    }
  }

  Future<bool> deleteRestaurant(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/restaurants/$id'));
      return response.statusCode == 200;
    } catch (e) {
      print('Delete restaurant error: $e');
      return false;
    }
  }

  // Staff Management
  Future<List<dynamic>> getStaff() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/staff'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) return data;
        return [];
      }
      return [];
    } catch (e) {
      print('Get staff error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> addStaff(Map<String, dynamic> staffData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/staff'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(staffData),
      );
      if (response.statusCode == 201) {
        return {'success': true};
      } else {
        final data = json.decode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to create staff',
        };
      }
    } catch (e) {
      print('Add staff error: $e');
      return {'success': false, 'message': 'Connection error'};
    }
  }

  Future<bool> deleteStaff(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/staff/$id'));
      return response.statusCode == 200;
    } catch (e) {
      print('Delete staff error: $e');
      return false;
    }
  }
}
