# 🍴 Somali Food Delivery App - Project Documentation

## 📝 Overview
This is a full-stack food delivery application designed for the Somali market. It features a robust multi-role system (User, Staff, Admin, Super Admin) allowing for seamless order placement, kitchen management, and restaurant administration.

---

## 🏗️ Architecture
The project follows a modern client-server architecture:
- **Frontend**: Flutter (Mobile/Web)
- **Backend**: Node.js & Express.js (REST API)
- **Database**: MongoDB (NoSQL)

---

## 🛠️ Tech Stack

### Backend
- **Express.js**: Web framework for Node.js.
- **Mongoose**: ODM for MongoDB.
- **Bcrypt.js**: Security for password hashing.
- **Multer**: Handling image uploads.
- **Dotenv**: Environment variable management.

### Frontend
- **Flutter & Dart**: Cross-platform development.
- **Provider**: State management.
- **Http**: API communication.
- **Shared Preferences**: Local data persistence.
- **Google Fonts & SVGs**: UI enhancement.

---

## 📂 Backend Structure

### 🗃️ Models (`/backend/models/`)
- **`User.js`**: Managed roles (admin, staff, delivery, user, superadmin), authentication, and restaurant association.
- **`Order.js`**: Order lifecycle (Pending, Accepted, Preparing, Ready, Delivered). Includes items, total, and payment details.
- **`Food.js`**: Dish details (name, price, category, stock availability).
- **`Restaurant.js`**: Restaurant profiles, address, and status.
- **`Message.js`**: Communication between users and restaurants.

### 🛣️ Key API Routes (`/backend/routes/`)
- **`/api/users`**: Authentication, registration, and profile management.
- **`/api/foods`**: CRUD operations for food items (Admin protected).
- **`/api/orders`**: Order placement and user order history.
- **`/api/staff`**: Staff-specific features like kitchen status updates.
- **`/api/admin`**: Management of restaurants, staff, and system-wide stats.
- **`/api/messages`**: Internal messaging system.

---

## 📱 Frontend Structure

### 🧠 State Management (`lib/providers/`)
- **`UserProvider`**: Handles login state and role-based navigation.
- **`FoodProvider`**: Manages the searchable menu items.
- **`CartProvider`**: Logic for managing items being ordered.
- **`StaffProvider`**: Real-time kitchen order management.
- **`AdminProvider`**: statistics, staff management, and restaurant CRUD.

### �️ Key UI Components (`lib/presentation/screens/`)
- **Customer**: `home_screen`, `restaurant_menu_screen`, `cart_screen`, `orders_screen`.
- **Staff**: `staff_dashboard`, `staff_kitchen_orders`, `delivery_dashboard`.
- **Admin**: `admin_dashboard`, `admin_restaurants_screen`, `admin_staff_management`.

---

## 🚀 Key Features
1. **Multi-Role System**: Restricted access based on user role (Admin vs Staff).
2. **Order Lifecycle**: Real-time progress tracking from kitchen to delivery.
3. **Restaurant Isolation**: Admins can only see and manage data for their specific restaurant.
4. **Manual Order Creation**: Admin ability to create orders manually for walk-in customers.

---

## 🔧 Recent Technical Improvements
- **Security**: Implemented `protect` and `authorize` middleware to ensure only authenticated users with correct roles can perform sensitive actions.
- **Data Integrity**: Ensured all orders are linked via `restaurantId` to maintain strict data isolation between restaurants.
- **API Reliability**: Fixed critical import errors and added validation for ObjectId handling to prevent server crashes.

---

## 💻 Running the Project

### Backend
1. Navigate to `/backend`.
2. Run `npm install`.
3. Configure `.env` with `MONGODB_URI`.
4. Run `npm run dev`.

### Frontend
1. Navigate to `/project_flutter_delivery_food_frontend`.
2. Run `flutter pub get`.
3. Run `flutter run`.

---
*Last Updated: February 7, 2026*
