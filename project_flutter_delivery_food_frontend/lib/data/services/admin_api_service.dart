import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AdminApiService {
  static const String baseUrl = 'http://localhost:5000/api/admin';

  Map<String, String> _headers(String? userId) => {
    'Content-Type': 'application/json',
    if (userId != null) 'user-id': userId,
  };

  Future<Map<String, dynamic>> getDashboardStats({
    String? restaurantId,
    String? userId,
  }) async {
    try {
      String url = '$baseUrl/stats';
      if (restaurantId != null) url += '?restaurantId=$restaurantId';
      final response = await http.get(
        Uri.parse(url),
        headers: _headers(userId),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {};
    } catch (e) {
      print('Stats error: $e');
      return {};
    }
  }

  Future<List<dynamic>> getPerformanceData({
    String? restaurantId,
    String? userId,
  }) async {
    try {
      String url = '$baseUrl/performance';
      if (restaurantId != null) url += '?restaurantId=$restaurantId';
      final response = await http.get(
        Uri.parse(url),
        headers: _headers(userId),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return [];
    } catch (e) {
      print('Performance error: $e');
      return [];
    }
  }

  Future<List<dynamic>> getAllOrders({
    String? restaurantId,
    String? userId,
  }) async {
    try {
      String url = '$baseUrl/orders';
      if (restaurantId != null) url += '?restaurantId=$restaurantId';
      final response = await http.get(
        Uri.parse(url),
        headers: _headers(userId),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return [];
    } catch (e) {
      print('Fetch all orders error: $e');
      return [];
    }
  }

  Future<bool> updateOrderStatus(
    String orderId,
    String status, {
    String? userId,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('http://localhost:5000/api/orders/$orderId'),
        headers: _headers(userId),
        body: json.encode({'status': status}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Update status error: $e');
      return false;
    }
  }

  Future<bool> addFood(Map<String, dynamic> foodData, {String? userId}) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000/api/foods'),
        headers: _headers(userId),
        body: json.encode(foodData),
      );
      return response.statusCode == 201;
    } catch (e) {
      print('Add food error: $e');
      return false;
    }
  }

  Future<bool> updateFood(
    String id,
    Map<String, dynamic> foodData, {
    String? userId,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('http://localhost:5000/api/foods/$id'),
        headers: _headers(userId),
        body: json.encode(foodData),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Update food error: $e');
      return false;
    }
  }

  Future<bool> deleteFood(String id, {String? userId}) async {
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:5000/api/foods/$id'),
        headers: _headers(userId),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Delete food error: $e');
      return false;
    }
  }

  Future<bool> createOrder(
    Map<String, dynamic> orderData, {
    String? userId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000/api/orders'),
        headers: _headers(userId),
        body: json.encode(orderData),
      );
      return response.statusCode == 201;
    } catch (e) {
      print('Create order error: $e');
      return false;
    }
  }

  Future<bool> deleteOrder(String orderId, {String? userId}) async {
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:5000/api/orders/$orderId'),
        headers: _headers(userId),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Delete order error: $e');
      return false;
    }
  }

  Future<String?> uploadFoodImage(dynamic imageFile, {String? userId}) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://localhost:5000/api/users/upload'),
      );

      if (userId != null) {
        request.headers['user-id'] = userId;
      }

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
  Future<List<dynamic>> getRestaurants({String? userId}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/restaurants'),
        headers: _headers(userId),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return [];
    } catch (e) {
      print('Get restaurants error: $e');
      return [];
    }
  }

  Future<List<dynamic>> getTopRestaurants({String? userId}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/top-restaurants'),
        headers: _headers(userId),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return [];
    } catch (e) {
      print('Get top restaurants error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getMyRestaurant({String? userId}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/my-restaurant'),
        headers: _headers(userId),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Get my restaurant error: $e');
      return null;
    }
  }

  Future<List<dynamic>> getRestaurantsWithStats({String? userId}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/restaurants-with-stats'),
        headers: _headers(userId),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return [];
    } catch (e) {
      print('Get restaurants with stats error: $e');
      return [];
    }
  }

  Future<String?> addRestaurant(
    Map<String, dynamic> restaurantData, {
    String? userId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/restaurants'),
        headers: _headers(userId),
        body: json.encode(restaurantData),
      );
      if (response.statusCode == 201) return null;
      final data = json.decode(response.body);
      return data['message'] ?? 'Failed to add restaurant';
    } catch (e) {
      print('Add restaurant error: $e');
      return e.toString();
    }
  }

  Future<String?> updateRestaurant(
    String id,
    Map<String, dynamic> restaurantData, {
    String? userId,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/restaurants/$id'),
        headers: _headers(userId),
        body: json.encode(restaurantData),
      );
      if (response.statusCode == 200) return null;
      final data = json.decode(response.body);
      return data['message'] ?? 'Failed to update restaurant';
    } catch (e) {
      print('Update restaurant error: $e');
      return e.toString();
    }
  }

  Future<bool> deleteRestaurant(String id, {String? userId}) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/restaurants/$id'),
        headers: _headers(userId),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Delete restaurant error: $e');
      return false;
    }
  }

  // Staff Management
  Future<List<dynamic>> getStaff({String? restaurantId, String? userId}) async {
    try {
      String url = '$baseUrl/staff';
      if (restaurantId != null) url += '?restaurantId=$restaurantId';
      final response = await http.get(
        Uri.parse(url),
        headers: _headers(userId),
      );
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

  Future<Map<String, dynamic>> addStaff(
    Map<String, dynamic> staffData, {
    String? userId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/staff'),
        headers: _headers(userId),
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

  Future<bool> deleteStaff(String id, {String? userId}) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/staff/$id'),
        headers: _headers(userId),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Delete staff error: $e');
      return false;
    }
  }
}
