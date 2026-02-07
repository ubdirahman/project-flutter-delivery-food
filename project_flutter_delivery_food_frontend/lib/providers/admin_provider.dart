import 'package:flutter/material.dart';
import '../data/services/admin_api_service.dart';

class AdminProvider with ChangeNotifier {
  final AdminApiService _apiService = AdminApiService();

  Map<String, dynamic> _stats = {};
  List<dynamic> _performanceData = [];
  List<dynamic> _allOrders = [];
  List<dynamic> _topRestaurants = [];
  Map<String, dynamic>? _managedRestaurant;
  bool _isLoading = false;
  String? _selectedFilterRestaurantId;

  Map<String, dynamic> get stats => _stats;
  List<dynamic> get performanceData => _performanceData;
  List<dynamic> get allOrders => _allOrders;
  List<dynamic> get topRestaurants => _topRestaurants;
  Map<String, dynamic>? get managedRestaurant => _managedRestaurant;
  bool get isLoading => _isLoading;
  String? get selectedFilterRestaurantId => _selectedFilterRestaurantId;

  void setSelectedFilterRestaurantId(String? id) {
    _selectedFilterRestaurantId = id;
    notifyListeners();
  }

  Future<void> fetchDashboardData({
    String? restaurantId,
    String? userId,
  }) async {
    _isLoading = true;
    notifyListeners();

    // These calls are generally safe for admin/staff if restaurantId is provided.
    // However, global stats (restaurantId == null) should be superadmin only.

    _stats = await _apiService.getDashboardStats(
      restaurantId: restaurantId,
      userId: userId,
    );
    _performanceData = await _apiService.getPerformanceData(
      restaurantId: restaurantId,
      userId: userId,
    );
    _allOrders = await _apiService.getAllOrders(
      restaurantId: restaurantId,
      userId: userId,
    );

    // Fetch managed restaurant details for non-superadmins
    if (restaurantId != null && restaurantId.isNotEmpty) {
      _managedRestaurant = await _apiService.getMyRestaurant(userId: userId);
      _topRestaurants = [];
    } else {
      // Global view - ONLY call if restaurantId is null,
      // which in our app logic usually means Super Admin.
      // However, we still call it and let the backend decide.
      // To strictly avoid 401 for staff/admins who might have null restaurantId incorrectly:
      // We can skip this if we know the user's role, but since we don't have it here...
      // We'll just let it proceed as usual but with the knowledge that it's protected.

      // OPTIONAL: If we want to be EXTREMELY silent about 401s:
      // if (userRole == 'superadmin') _topRestaurants = ...

      _topRestaurants = await _apiService.getTopRestaurants(userId: userId);
      _managedRestaurant = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchManagedRestaurant({String? userId}) async {
    _isLoading = true;
    notifyListeners();
    _managedRestaurant = await _apiService.getMyRestaurant(userId: userId);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchAllOrders({String? restaurantId, String? userId}) async {
    _isLoading = true;
    notifyListeners();

    _allOrders = await _apiService.getAllOrders(
      restaurantId: restaurantId,
      userId: userId,
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateStatus(
    String orderId,
    String status, {
    String? userId,
  }) async {
    final success = await _apiService.updateOrderStatus(
      orderId,
      status,
      userId: userId,
    );
    if (success) {
      await fetchAllOrders(userId: userId);
    }
    return success;
  }

  Future<bool> addFood(Map<String, dynamic> foodData, {String? userId}) async {
    final success = await _apiService.addFood(foodData, userId: userId);
    if (success) notifyListeners(); // Trigger rebuild or re-fetch in UI
    return success;
  }

  Future<bool> updateFood(
    String id,
    Map<String, dynamic> foodData, {
    String? userId,
  }) async {
    final success = await _apiService.updateFood(id, foodData, userId: userId);
    if (success) notifyListeners();
    return success;
  }

  Future<bool> deleteFood(String id, {String? userId}) async {
    final success = await _apiService.deleteFood(id, userId: userId);
    if (success) notifyListeners();
    return success;
  }

  Future<bool> createOrder(
    Map<String, dynamic> orderData, {
    String? userId,
  }) async {
    final success = await _apiService.createOrder(orderData, userId: userId);
    if (success) await fetchAllOrders(userId: userId);
    return success;
  }

  Future<bool> deleteOrder(String orderId, {String? userId}) async {
    final success = await _apiService.deleteOrder(orderId, userId: userId);
    if (success) await fetchAllOrders(userId: userId);
    return success;
  }

  // Restaurant Management
  List<dynamic> _restaurants = [];
  List<dynamic> get restaurants => _restaurants;

  Future<void> fetchRestaurants({String? userId}) async {
    _isLoading = true;
    notifyListeners();

    _restaurants = await _apiService.getRestaurants(userId: userId);

    _isLoading = false;
    notifyListeners();
  }

  Future<String?> addRestaurant(
    Map<String, dynamic> restaurantData, {
    String? userId,
  }) async {
    final error = await _apiService.addRestaurant(
      restaurantData,
      userId: userId,
    );
    if (error == null) await fetchRestaurants(userId: userId);
    return error;
  }

  Future<String?> updateRestaurant(
    String id,
    Map<String, dynamic> restaurantData, {
    String? userId,
  }) async {
    final error = await _apiService.updateRestaurant(
      id,
      restaurantData,
      userId: userId,
    );
    if (error == null) await fetchRestaurants(userId: userId);
    return error;
  }

  Future<bool> deleteRestaurant(String id, {String? userId}) async {
    final success = await _apiService.deleteRestaurant(id, userId: userId);
    if (success) await fetchRestaurants(userId: userId);
    return success;
  }

  Future<void> fetchRestaurantsWithStats({String? userId}) async {
    _isLoading = true;
    notifyListeners();

    _restaurants = await _apiService.getRestaurantsWithStats(userId: userId);

    _isLoading = false;
    notifyListeners();
  }

  // Staff Management
  List<dynamic> _staffList = [];
  List<dynamic> get staffList => _staffList;

  Future<void> fetchStaff({String? restaurantId, String? userId}) async {
    _isLoading = true;
    notifyListeners();

    _staffList = await _apiService.getStaff(
      restaurantId: restaurantId,
      userId: userId,
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<String?> addStaff(
    Map<String, dynamic> staffData, {
    String? userId,
  }) async {
    final result = await _apiService.addStaff(staffData, userId: userId);
    if (result['success'] == true) {
      await fetchStaff(restaurantId: staffData['restaurantId'], userId: userId);
      return null;
    }
    return result['message'];
  }

  Future<bool> deleteStaff(String id, {String? userId}) async {
    final success = await _apiService.deleteStaff(id, userId: userId);
    if (success) await fetchStaff(userId: userId);
    return success;
  }
}
