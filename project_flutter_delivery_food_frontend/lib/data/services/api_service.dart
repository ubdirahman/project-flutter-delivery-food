import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/food_model.dart';

// This class is responsible for communicating with our backend server (Node.js).
class ApiService {
  // This is the address of our server. "localhost" means the server is running on the same computer.
  static const String baseUrl = 'http://localhost:5000/api';

  Map<String, String> _headers(String? userId) => {
    'Content-Type': 'application/json',
    if (userId != null) 'user-id': userId,
  };

  // This function sends a GET request to the server to get all the foods.
  Future<List<FoodModel>> getFoods({String? restaurantId}) async {
    try {
      String url = '$baseUrl/foods';
      if (restaurantId != null) url += '?restaurantId=$restaurantId';
      final response = await http.get(Uri.parse(url));

      // Status code 200 means "Success"
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        // Converts the raw data (JSON) into a list of FoodModel objects.
        return data.map((item) => FoodModel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load foods from server');
      }
    } catch (e) {
      print('Error fetching foods: $e');
      return [];
    }
  }

  // This function sends a POST request to the server to check if a user can login.
  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/login'),
        headers: {'Content-Type': 'application/json'},
        // json.encode converts our data into a format the server understands.
        body: json.encode({'email': email, 'password': password}),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> register(
    String username,
    String email,
    String password,
  ) async {
    try {
      print('Sending registration request: $username, $email');
      final response = await http.post(
        Uri.parse('$baseUrl/users/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );
      print('Registration response status: ${response.statusCode}');
      print('Registration response body: ${response.body}');

      if (response.statusCode == 201) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Registration error: $e');
      return null;
    }
  }

  // --- Persistence Methods ---

  Future<bool> placeOrder(
    Map<String, dynamic> orderData, {
    String? userId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: _headers(userId),
        body: json.encode(orderData),
      );
      return response.statusCode == 201;
    } catch (e) {
      print('Place order error: $e');
      return false;
    }
  }

  Future<List<dynamic>> getUserOrders(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders/user/$userId'),
        headers: _headers(userId),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return [];
    } catch (e) {
      print('Fetch orders error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/profile/$userId'),
        headers: _headers(userId),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Fetch profile error: $e');
      return null;
    }
  }

  Future<bool> updateUserProfile(
    String userId,
    Map<String, dynamic> profileData,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/users/profile/$userId'),
        headers: _headers(userId),
        body: json.encode(profileData),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Update profile error: $e');
      return false;
    }
  }

  Future<String?> uploadProfileImage(
    dynamic imageFile, {
    String? userId,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/users/upload'),
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
      print('Upload image error: $e');
      return null;
    }
  }

  Future<bool> sendMessage(
    Map<String, dynamic> messageData, {
    String? userId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/messages'),
        headers: _headers(userId),
        body: json.encode(messageData),
      );
      return response.statusCode == 201;
    } catch (e) {
      print('Send message error: $e');
      return false;
    }
  }
}
