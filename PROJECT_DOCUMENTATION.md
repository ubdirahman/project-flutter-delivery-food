# 📄 Project Manual: Somali Flavors Delivery App

**Project Objective**: A high-fidelity food delivery application built with Flutter and Node.js.

---

## 🚀 1. How to Use the App

### Welcome & Authentication
- **Splash Screen**: The app starts with a branded splash screen.
- **Login/Register**: Users can create an account or login using their credentials. The app uses `UserProvider` to manage authentication state.

### Browsing & Ordering
1. **Home Screen**: Browse popular foods and restaurants. Use the **Category Menu** to filter results (e.g., Burgers, Pizzas).
2. **Search**: Click the search bar to find specific dishes or restaurants.
3. **Menu**: Click a restaurant or food item to view the detailed menu.
4. **Cart**: Add items to your cart. Click the floating action button to view your cart items, adjust quantities, and see the total.
5. **Checkout**: Click "Check out" in the cart screen to place your order.

### Order Tracking
- **My Orders**: Switch between **Active** orders (being prepared/delivered) and **History** (past orders) using the TabBar.

---

## 🛠️ 2. Flutter App Architecture

The app follows a **Provider Pattern** for state management, ensuring a separation of concerns between UI and Business Logic.

### Directory Structure
- `lib/core/`: Application themes and global constants.
- `lib/data/`: Data layer.
    - `models/`: Plain Old Dart Objects (PODOs) for data mapping.
    - `services/`: API Service class for HTTP communication.
- `lib/presentation/`: UI layer.
    - `screens/`: Scaffold-based page widgets.
    - `widgets/`: Reusable component widgets.
- `lib/providers/`: State management classes (ChangeNotifier).

---

## 🔌 3. Backend API Integration

The application connects to a **RESTful API** built with Node.js and Express.

### Integration Steps:
1. **Base URL**: The app communicates with `http://localhost:5000/api`.
2. **Data Fetching**: The `ApiService` class uses the `http` package to send GET, POST, PUT, and DELETE requests.
3. **JSON Parsing**: Raw response data is parsed into model objects using `json.decode`.
4. **Error Handling**: All API calls are wrapped in try-catch blocks to handle network issues gracefully.

---

## ✅ 4. Guidelines Compliance Checklist

- [x] **Main Screen**: Implemented in `home_screen.dart`.
- [x] **UI Components**: Used `ListView`, `Container`, `TextField`, `Custom Widgets`, etc.
- [x] **Navigation**: Implemented `Navigator`, `Drawer`, `Bottom Nav Bar`, and `TabBar`.
- [x] **State Management**: Using `Provider` (ChangeNotifier).
- [x] **Backend Integration**: Connected to a Node.js REST API.
- [x] **Responsive Design**: Used `SafeArea`, `Expanded`, and `Flexible` layouts.
- [x] **Styling**: Consistent typography (Poppins) and colors (AppColors).

---

**Submitted by**: [Your Team Name]  
**Date**: January 2025
