import 'package:flutter/material.dart';
import '../data/services/admin_api_service.dart';

class AdminProvider with ChangeNotifier {
  final AdminApiService _apiService = AdminApiService();

  Map<String, dynamic> _stats = {};
  List<dynamic> _performanceData = [];
  List<dynamic> _allOrders = [];
  bool _isLoading = false;

  Map<String, dynamic> get stats => _stats;
  List<dynamic> get performanceData => _performanceData;
  List<dynamic> get allOrders => _allOrders;
  bool get isLoading => _isLoading;

  Future<void> fetchDashboardData() async {
    _isLoading = true;
    notifyListeners();

    _stats = await _apiService.getDashboardStats();
    _performanceData = await _apiService.getPerformanceData();
    _allOrders = await _apiService.getAllOrders();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchAllOrders() async {
    _isLoading = true;
    notifyListeners();

    _allOrders = await _apiService.getAllOrders();

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateStatus(String orderId, String status) async {
    final success = await _apiService.updateOrderStatus(orderId, status);
    if (success) {
      await fetchAllOrders();
    }
    return success;
  }

  Future<bool> addFood(Map<String, dynamic> foodData) async {
    final success = await _apiService.addFood(foodData);
    if (success) notifyListeners(); // Trigger rebuild or re-fetch in UI
    return success;
  }

  Future<bool> updateFood(String id, Map<String, dynamic> foodData) async {
    final success = await _apiService.updateFood(id, foodData);
    if (success) notifyListeners();
    return success;
  }

  Future<bool> deleteFood(String id) async {
    final success = await _apiService.deleteFood(id);
    if (success) notifyListeners();
    return success;
  }

  Future<bool> createOrder(Map<String, dynamic> orderData) async {
    final success = await _apiService.createOrder(orderData);
    if (success) await fetchAllOrders();
    return success;
  }

  Future<bool> deleteOrder(String orderId) async {
    final success = await _apiService.deleteOrder(orderId);
    if (success) await fetchAllOrders();
    return success;
  }

  // Restaurant Management
  List<dynamic> _restaurants = [];
  List<dynamic> get restaurants => _restaurants;

  Future<void> fetchRestaurants() async {
    _isLoading = true;
    notifyListeners();

    _restaurants = await _apiService.getRestaurants();

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addRestaurant(Map<String, dynamic> restaurantData) async {
    final success = await _apiService.addRestaurant(restaurantData);
    if (success) await fetchRestaurants();
    return success;
  }

  Future<bool> updateRestaurant(
    String id,
    Map<String, dynamic> restaurantData,
  ) async {
    final success = await _apiService.updateRestaurant(id, restaurantData);
    if (success) await fetchRestaurants();
    return success;
  }

  Future<bool> deleteRestaurant(String id) async {
    final success = await _apiService.deleteRestaurant(id);
    if (success) await fetchRestaurants();
    return success;
  }

  // Staff Management
  List<dynamic> _staffList = [];
  List<dynamic> get staffList => _staffList;

  Future<void> fetchStaff() async {
    _isLoading = true;
    notifyListeners();

    _staffList = await _apiService.getStaff();

    _isLoading = false;
    notifyListeners();
  }

  Future<String?> addStaff(Map<String, dynamic> staffData) async {
    final result = await _apiService.addStaff(staffData);
    if (result['success'] == true) {
      await fetchStaff();
      return null;
    }
    return result['message'];
  }

  Future<bool> deleteStaff(String id) async {
    final success = await _apiService.deleteStaff(id);
    if (success) await fetchStaff();
    return success;
  }
}
