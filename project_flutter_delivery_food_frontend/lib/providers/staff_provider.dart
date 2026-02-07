import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StaffProvider with ChangeNotifier {
  List<dynamic> _pendingOrders = [];
  bool _isLoading = false;

  List<dynamic> get pendingOrders => _pendingOrders;
  bool get isLoading => _isLoading;
  String? _lastRestaurantId;

  // Base URL
  static const String baseUrl = 'http://localhost:5000/api/staff';

  Map<String, String> _headers(String? userId) {
    return {
      'Content-Type': 'application/json',
      if (userId != null) 'user-id': userId,
    };
  }

  Future<void> fetchPendingOrders({
    String? restaurantId,
    String? userId,
  }) async {
    _isLoading = true;
    if (restaurantId != null) _lastRestaurantId = restaurantId;
    notifyListeners();
    try {
      String url = '$baseUrl/orders/pending';
      if (_lastRestaurantId != null) url += '?restaurantId=$_lastRestaurantId';

      final response = await http.get(
        Uri.parse(url),
        headers: _headers(userId),
      );
      if (response.statusCode == 200) {
        _pendingOrders = json.decode(response.body);
      } else {
        print('Error fetching pending orders: ${response.body}');
      }
    } catch (e) {
      print('Fetch error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Map<String, dynamic>? _dashboardStats;
  Map<String, dynamic>? get dashboardStats => _dashboardStats;

  Future<void> fetchStats(String restaurantId, {String? userId}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/stats/$restaurantId'),
        headers: _headers(userId),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _dashboardStats = data['stats'];
        notifyListeners();
      }
    } catch (e) {
      print('Fetch stats error: $e');
    }
  }

  Future<bool> acceptOrder(
    String orderId,
    String staffId, {
    String? userId,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/orders/$orderId/accept'),
        headers: _headers(userId),
        body: json.encode({'staffId': staffId}),
      );
      if (response.statusCode == 200) {
        await fetchPendingOrders(userId: userId);
        return true;
      }
    } catch (e) {
      print('Accept error: $e');
    }
    return false;
  }

  Future<bool> rejectOrder(
    String orderId,
    String reason, {
    String? userId,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/orders/$orderId/reject'),
        headers: _headers(userId),
        body: json.encode({'rejectionReason': reason}),
      );
      if (response.statusCode == 200) {
        await fetchPendingOrders(userId: userId);
        return true;
      }
    } catch (e) {
      print('Reject error: $e');
    }
    return false;
  }

  Future<bool> agreeDelivery(String orderId, {String? userId}) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/orders/$orderId/agree-delivery'),
        headers: _headers(userId),
      );
      if (response.statusCode == 200) {
        await fetchPendingOrders(userId: userId);
        return true;
      }
    } catch (e) {
      print('Agree delivery error: $e');
    }
    return false;
  }

  Future<bool> rejectDelivery(
    String orderId,
    String reason, {
    String? userId,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/orders/$orderId/reject-delivery'),
        headers: _headers(userId),
        body: json.encode({'reason': reason}),
      );
      if (response.statusCode == 200) {
        await fetchPendingOrders(userId: userId);
        return true;
      }
    } catch (e) {
      print('Reject delivery error: $e');
    }
    return false;
  }

  Future<bool> updateStatus(
    String orderId,
    String status, {
    String? userId,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/orders/$orderId/status'),
        headers: _headers(userId),
        body: json.encode({'status': status}),
      );
      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      print('Status update error: $e');
    }
    return false;
  }

  // Messaging functionality
  List<dynamic> _messages = [];
  bool _isLoadingMessages = false;

  List<dynamic> get messages => _messages;
  bool get isLoadingMessages => _isLoadingMessages;

  Future<void> fetchMessages(String restaurantId, {String? userId}) async {
    _isLoadingMessages = true;
    notifyListeners();
    try {
      final response = await http.get(
        Uri.parse(
          'http://localhost:5000/api/messages/restaurant/$restaurantId',
        ),
        headers: _headers(userId),
      );
      if (response.statusCode == 200) {
        _messages = json.decode(response.body);
      } else {
        print('Error fetching messages: ${response.body}');
      }
    } catch (e) {
      print('Fetch messages error: $e');
    } finally {
      _isLoadingMessages = false;
      notifyListeners();
    }
  }

  // Managed Orders (Orders this staff member is currently handling)
  List<dynamic> _managedOrders = [];
  bool _isLoadingManaged = false;

  List<dynamic> get managedOrders => _managedOrders;
  bool get isLoadingManaged => _isLoadingManaged;

  Future<void> fetchManagedOrders({String? userId}) async {
    _isLoadingManaged = true;
    notifyListeners();
    try {
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/staff/orders/managed'),
        headers: _headers(userId),
      );
      if (response.statusCode == 200) {
        _managedOrders = json.decode(response.body);
      } else {
        print('Error fetching managed orders: ${response.body}');
      }
    } catch (e) {
      print('Fetch managed orders error: $e');
    } finally {
      _isLoadingManaged = false;
      notifyListeners();
    }
  }

  Future<bool> replyToMessage({
    required String restaurantId,
    required String receiverId,
    required String content,
    String? orderId,
    String? userId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000/api/messages/reply'),
        headers: _headers(userId),
        body: json.encode({
          'restaurantId': restaurantId,
          'receiverId': receiverId,
          'content': content,
          if (orderId != null) 'orderId': orderId,
        }),
      );
      if (response.statusCode == 201) {
        // Refresh messages after reply
        await fetchMessages(restaurantId, userId: userId);
        return true;
      }
    } catch (e) {
      print('Reply error: $e');
    }
    return false;
  }
}
