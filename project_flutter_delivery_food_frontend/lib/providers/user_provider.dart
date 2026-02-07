import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UserProvider with ChangeNotifier {
  String? _userId;
  String? _username;
  String? _email;
  String? _profileImage;
  String? _role;
  String? _restaurantId;

  String? get userId => _userId;
  String? get username => _username;
  String? get email => _email;
  String? get profileImage => _profileImage;
  String? get role => _role;
  String? get restaurantId => _restaurantId;

  bool get isAuthenticated => _userId != null;
  bool get isAdmin => _role == 'admin';
  bool get isStaff => _role == 'staff';
  bool get isDelivery => _role == 'delivery';
  bool get isSuperAdmin => _role == 'superadmin';

  Future<void> setUser(Map<String, dynamic> userData) async {
    final user = userData['user'] ?? userData;
    _userId = user['_id'];
    _username = user['username'];
    _email = user['email'];
    _profileImage = user['profileImage'] ?? '';
    _role = user['role'] ?? 'user';
    _restaurantId = user['restaurantId'];

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userData', json.encode(user));

    notifyListeners();
  }

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('userData');
    if (userDataString != null) {
      final user = json.decode(userDataString);
      _userId = user['_id'];
      _username = user['username'];
      _email = user['email'];
      _profileImage = user['profileImage'] ?? '';
      _role = user['role'] ?? 'user';
      _restaurantId = user['restaurantId'];
      notifyListeners();
    }
  }

  void setProfileImage(String imageUrl) {
    _profileImage = imageUrl;
    notifyListeners();
  }

  Future<void> logout() async {
    _userId = null;
    _username = null;
    _email = null;
    _profileImage = null;
    _role = null;
    _restaurantId = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userData');

    notifyListeners();
  }
}
