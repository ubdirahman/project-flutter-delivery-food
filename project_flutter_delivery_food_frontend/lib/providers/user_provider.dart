import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String? _userId;
  String? _username;
  String? _email;
  String? _profileImage;
  String? _role;

  String? get userId => _userId;
  String? get username => _username;
  String? get email => _email;
  String? get profileImage => _profileImage;
  String? get role => _role;

  bool get isAuthenticated => _userId != null;
  bool get isAdmin => _role == 'admin';
  bool get isStaff => _role == 'staff';

  void setUser(Map<String, dynamic> userData) {
    // Backend returns { user: { _id, username, email, profileImage } } or similar
    final user = userData['user'] ?? userData;
    _userId = user['_id'];
    _username = user['username'];
    _email = user['email'];
    _profileImage = user['profileImage'] ?? '';
    _role = user['role'] ?? 'user';
    notifyListeners();
  }

  void setProfileImage(String imageUrl) {
    _profileImage = imageUrl;
    notifyListeners();
  }

  void logout() {
    _userId = null;
    _username = null;
    _email = null;
    _profileImage = null;
    _role = null;
    notifyListeners();
  }
}
