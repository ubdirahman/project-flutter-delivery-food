import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// Removed non-existent import

class StaffProvider with ChangeNotifier {
  List<dynamic> _pendingOrders = [];
  bool _isLoading = false;

  List<dynamic> get pendingOrders => _pendingOrders;
  bool get isLoading => _isLoading;

  // Base URL - I should verify where this is defined in the project
  static const String baseUrl = 'http://localhost:5000/api/staff';

  Future<void> fetchPendingOrders() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await http.get(Uri.parse('$baseUrl/orders/pending'));
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

  Future<bool> acceptOrder(String orderId, String staffId) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/orders/$orderId/accept'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'staffId': staffId}),
      );
      if (response.statusCode == 200) {
        await fetchPendingOrders();
        return true;
      }
    } catch (e) {
      print('Accept error: $e');
    }
    return false;
  }

  Future<bool> rejectOrder(String orderId, String reason) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/orders/$orderId/reject'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'rejectionReason': reason}),
      );
      if (response.statusCode == 200) {
        await fetchPendingOrders();
        return true;
      }
    } catch (e) {
      print('Reject error: $e');
    }
    return false;
  }

  Future<bool> updateStatus(String orderId, String status) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/orders/$orderId/status'),
        headers: {'Content-Type': 'application/json'},
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
}
