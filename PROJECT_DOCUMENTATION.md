# 🍴 Somali Food Delivery App - Complete Project Documentation

## 📝 Overview
This is a comprehensive full-stack food delivery application designed specifically for the Somali market. The system features a robust multi-role architecture supporting Users (Customers), Staff (Kitchen), Delivery Personnel, Restaurant Admins, and Super Admins, enabling seamless order management from placement to delivery.

**Key Highlights:**
- 🌐 Cross-platform mobile application (Flutter)
- 🔐 Role-based access control with 5 user types
- 🏪 Multi-restaurant support with data isolation
- ⭐ Delivery rating and feedback system
- 📊 Real-time analytics and reporting
- 🌍 Somali language support (Af-Soomaali)

---

## 🏗️ System Architecture

### Architecture Pattern
The project follows a modern **client-server architecture** with clear separation of concerns:

```
┌─────────────────┐
│  Flutter App    │ ← Cross-platform mobile client
│  (Frontend)     │
└────────┬────────┘
         │ HTTP/REST API
         ▼
┌─────────────────┐
│  Express.js     │ ← Node.js backend server
│  (Backend API)  │
└────────┬────────┘
         │ Mongoose ODM
         ▼
┌─────────────────┐
│  MongoDB        │ ← NoSQL database
│  (Database)     │
└─────────────────┘
```

### Technology Stack

#### Backend
- **Runtime**: Node.js v18+
- **Framework**: Express.js 4.x
- **Database**: MongoDB (Cloud - MongoDB Atlas)
- **ODM**: Mongoose 7.x
- **Authentication**: JWT (JSON Web Tokens)
- **Security**: Bcrypt.js for password hashing
- **File Upload**: Multer for image handling
- **Environment**: Dotenv for configuration

#### Frontend
- **Framework**: Flutter 3.x
- **Language**: Dart 3.x
- **State Management**: Provider pattern
- **HTTP Client**: http package
- **Local Storage**: Shared Preferences
- **UI Components**: 
  - Google Fonts (Poppins)
  - FL Chart (Analytics)
  - SVG support
- **Platform Support**: Android, iOS, Web

---

## 📂 Project Structure

### Backend Structure (`/backend/`)

```
backend/
├── models/              # Database schemas
│   ├── User.js         # User accounts & roles
│   ├── Order.js        # Order management
│   ├── Food.js         # Menu items
│   ├── Restaurant.js   # Restaurant profiles
│   └── Message.js      # Internal messaging
├── routes/             # API endpoints
│   ├── userRoutes.js   # Authentication & profiles
│   ├── orderRoutes.js  # Order operations
│   ├── foodRoutes.js   # Menu CRUD
│   ├── adminRoutes.js  # Admin operations
│   ├── staffRoutes.js  # Staff/Kitchen ops
│   └── messageRoutes.js # Messaging
├── middleware/         # Custom middleware
│   └── auth.js        # JWT & role authorization
├── uploads/           # User-uploaded images
└── server.js          # Entry point
```

### Frontend Structure (`/project_flutter_delivery_food_frontend/`)

```
lib/
├── core/
│   ├── constants/
│   │   ├── colors.dart        # App color scheme
│   │   └── api_constants.dart # API URLs
│   └── utils/
├── data/
│   └── services/
│       ├── api_service.dart   # HTTP client
│       └── admin_api_service.dart
├── providers/              # State management
│   ├── user_provider.dart     # Auth & user state
│   ├── food_provider.dart     # Menu state
│   ├── cart_provider.dart     # Shopping cart
│   ├── staff_provider.dart    # Kitchen orders
│   ├── admin_provider.dart    # Admin dashboard
│   └── restaurant_provider.dart
└── presentation/
    ├── screens/           # UI screens
    │   ├── login_screen.dart
    │   ├── home_screen.dart
    │   ├── orders_screen.dart
    │   ├── admin/         # Admin screens
    │   └── staff/         # Staff screens
    └── widgets/           # Reusable components
```

---

## 🗃️ Database Models

### User Model
```javascript
{
  name: String,
  email: String (unique),
  password: String (hashed),
  phone: String,
  role: Enum ['user', 'admin', 'staff', 'delivery', 'superadmin'],
  restaurantId: ObjectId (ref: Restaurant),
  address: String,
  createdAt: DateTime,
  updatedAt: DateTime
}
```

**Roles:**
- `user` - Regular customers who place orders
- `staff` - Kitchen staff who prepare orders
- `delivery` - Delivery personnel
- `admin` - Restaurant administrators
- `superadmin` - System-wide administrators

### Order Model
```javascript
{
  userId: ObjectId (ref: User),
  restaurantId: ObjectId (ref: Restaurant),
  items: [{
    foodId: ObjectId,
    name: String,
    price: Number,
    quantity: Number,
    image: String,
    size: String
  }],
  totalAmount: Number,
  deliveryFees: Number (default: 5),
  status: Enum [
    'Pending',           // Order placed
    'Accepted',          // Restaurant accepted
    'Preparing',         // Being cooked
    'Ready',             // Ready for pickup
    'Handed to Delivery',// With delivery person
    'Delivered',         // Completed
    'Cancelled',         // User cancelled
    'Rejected'           // Restaurant rejected
  ],
  staffId: ObjectId (ref: User),
  deliveryId: ObjectId (ref: User),
  paymentMethod: Enum ['Cash on Delivery', 'EVC-PLUS', 'SAHAL', ...],
  paymentStatus: Enum ['Pending', 'Paid', 'Failed'],
  address: String,
  deliveryRating: Number (1-5),
  deliveryReview: String,
  rejectionReason: String,
  createdAt: DateTime,
  updatedAt: DateTime
}
```

### Food Model
```javascript
{
  name: String,
  description: String,
  price: Number,
  category: String,
  image: String (URL),
  restaurantId: ObjectId (ref: Restaurant),
  available: Boolean,
  quantity: Number,
  sizes: [String],
  createdAt: DateTime,
  updatedAt: DateTime
}
```

### Restaurant Model
```javascript
{
  name: String,
  address: String,
  phone: String,
  email: String,
  image: String (URL),
  description: String,
  isActive: Boolean,
  createdAt: DateTime,
  updatedAt: DateTime
}
```

### Message Model
```javascript
{
  userId: ObjectId (ref: User),
  restaurantId: ObjectId (ref: Restaurant),
  orderId: ObjectId (ref: Order),
  messageType: Enum ['delay_report', 'general_inquiry', 'complaint'],
  content: String,
  status: Enum ['pending', 'resolved'],
  createdAt: DateTime
}
```

---

## 🛣️ API Endpoints

### Authentication & Users (`/api/users`)

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST | `/register` | Register new user | ❌ |
| POST | `/login` | User login | ❌ |
| GET | `/profile` | Get user profile | ✅ |
| PUT | `/profile` | Update profile | ✅ |

### Orders (`/api/orders`)

| Method | Endpoint | Description | Auth Required | Role |
|--------|----------|-------------|---------------|------|
| POST | `/` | Create new order | ✅ | user |
| GET | `/user/:userId` | Get user's orders | ✅ | user |
| PATCH | `/:orderId/rate` | Rate delivery | ✅ | user |

### Food Items (`/api/foods`)

| Method | Endpoint | Description | Auth Required | Role |
|--------|----------|-------------|---------------|------|
| GET | `/` | Get all food items | ❌ | - |
| GET | `/:id` | Get single food item | ❌ | - |
| POST | `/` | Create food item | ✅ | admin |
| PUT | `/:id` | Update food item | ✅ | admin |
| DELETE | `/:id` | Delete food item | ✅ | admin |

### Staff Operations (`/api/staff`)

| Method | Endpoint | Description | Auth Required | Role |
|--------|----------|-------------|---------------|------|
| GET | `/orders` | Get restaurant orders | ✅ | staff/admin |
| PATCH | `/orders/:id/status` | Update order status | ✅ | staff/admin |
| PATCH | `/orders/:id/assign-staff` | Assign staff to order | ✅ | admin |
| PATCH | `/orders/:id/assign-delivery` | Assign delivery | ✅ | admin |

### Admin Operations (`/api/admin`)

| Method | Endpoint | Description | Auth Required | Role |
|--------|----------|-------------|---------------|------|
| GET | `/stats` | Dashboard statistics | ✅ | admin/superadmin |
| GET | `/orders` | All orders | ✅ | admin |
| DELETE | `/orders/:id` | Delete order | ✅ | admin |
| GET | `/restaurants` | All restaurants | ✅ | superadmin |
| POST | `/restaurants` | Create restaurant | ✅ | superadmin |
| PUT | `/restaurants/:id` | Update restaurant | ✅ | superadmin |
| DELETE | `/restaurants/:id` | Delete restaurant | ✅ | superadmin |
| GET | `/staff` | Get all staff | ✅ | admin |
| POST | `/staff` | Create staff member | ✅ | admin |
| PUT | `/staff/:id` | Update staff | ✅ | admin |
| DELETE | `/staff/:id` | Delete staff | ✅ | admin |

### Messages (`/api/messages`)

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST | `/` | Send message | ✅ |
| GET | `/restaurant/:restaurantId` | Get restaurant messages | ✅ |
| PATCH | `/:id/resolve` | Mark as resolved | ✅ |

---

## 🚀 Key Features

### 1. Multi-Role System
**Five distinct user roles with specific permissions:**

- **👤 User (Customer)**
  - Browse restaurants and menus
  - Add items to cart
  - Place orders
  - Track order status in real-time
  - Rate delivery experience (1-5 stars)
  - Send messages to restaurants

- **👨‍🍳 Staff (Kitchen)**
  - View assigned restaurant orders
  - Update order status (Accepted → Preparing → Ready)
  - Reject orders with reason
  - Real-time order notifications

- **🚗 Delivery Personnel**
  - View assigned deliveries
  - Update delivery status
  - Mark orders as delivered

- **👔 Restaurant Admin**
  - Manage restaurant profile
  - CRUD operations on menu items
  - View restaurant-specific orders
  - Manage staff members
  - View analytics and statistics
  - Create manual orders (walk-in customers)
  - View delivery ratings and reviews
  - Filter orders by rating

- **⚡ Super Admin**
  - Manage all restaurants
  - Create/edit/delete restaurants
  - View system-wide statistics
  - Access all data across restaurants

### 2. Order Lifecycle Management

**Complete order flow with 8 statuses:**

```
Pending → Accepted → Preparing → Ready → Handed to Delivery → Delivered
   ↓                                                              ↓
Rejected                                                     [Rating]
   ↓
Cancelled
```

**Status Descriptions:**
- **Pending**: Order just placed, awaiting restaurant confirmation
- **Accepted**: Restaurant confirmed the order
- **Preparing**: Kitchen is preparing the food
- **Ready**: Food is ready for pickup/delivery
- **Handed to Delivery**: Order given to delivery person
- **Delivered**: Order successfully delivered
- **Rejected**: Restaurant declined (with reason)
- **Cancelled**: User cancelled the order

### 3. Delivery Rating System ⭐

**Recently Enhanced Feature:**

- **User Experience:**
  - Rate delivery from 1-5 stars
  - Add optional written review
  - Rating available when order status is:
    - ✅ Ready
    - ✅ Handed to Delivery
    - ✅ Delivered
  - One rating per order

- **Admin Visibility:**
  - **Dashboard Stat Card**: Average rating + total count
  - **Orders Screen**: 
    - Rating badge in collapsed view
    - Detailed rating with stars in expanded view
    - Review text display
  - **Filtering**: Filter orders by rating (5★, 4★, 3★, 2★, 1★, Not Rated)

- **Backend:**
  - Aggregated average rating calculation
  - Restaurant-specific isolation
  - Validation for rating range (1-5)

### 4. Restaurant Data Isolation

**Strict data separation between restaurants:**

- Each admin only sees their restaurant's data
- Orders filtered by `restaurantId`
- Staff assigned to specific restaurants
- Menu items linked to restaurants
- Statistics calculated per restaurant
- Super Admin can view all restaurants

### 5. Manual Order Creation

**Admin capability for walk-in customers:**

- Create orders without user account
- Select items from restaurant menu
- Set payment method
- Assign to kitchen staff
- Track like regular orders

### 6. Real-time Dashboard Analytics

**Admin Dashboard Statistics:**
- Total Orders
- Total Revenue
- Total Customers
- Average Delivery Rating ⭐
- Total Delivery Ratings Count
- Weekly Performance Chart
- Top Selling Items
- Recent Orders List

**Super Admin Dashboard:**
- Total Restaurants
- System-wide statistics
- Top Performing Restaurants
- Revenue by restaurant

### 7. Internal Messaging System

**Communication between users and restaurants:**
- Delay reports
- General inquiries
- Complaints
- Status tracking (pending/resolved)
- Restaurant-specific inbox

### 8. Inventory Management

**Stock tracking for menu items:**
- Quantity management
- Automatic decrement on order
- Availability toggle
- Out-of-stock prevention

---

## 🔐 Security Features

### Authentication & Authorization

1. **JWT Token-Based Authentication**
   - Secure token generation on login
   - Token validation on protected routes
   - Automatic token refresh

2. **Password Security**
   - Bcrypt hashing (10 salt rounds)
   - No plain-text storage
   - Secure password comparison

3. **Role-Based Access Control (RBAC)**
   - Middleware: `protect` (authentication)
   - Middleware: `authorize(...roles)` (authorization)
   - Route-level protection

4. **Data Validation**
   - MongoDB ObjectId validation
   - Input sanitization
   - Required field enforcement

### Example Protected Route:
```javascript
router.get('/admin/stats', 
  protect,                           // Must be logged in
  authorize('admin', 'superadmin'),  // Must be admin or superadmin
  async (req, res) => { ... }
);
```

---

## 🎨 UI/UX Features

### Design System
- **Color Scheme**: 
  - Primary: Red (`#FF0000`)
  - Accent: Orange, Green, Blue
  - Neutral: Grays
- **Typography**: Google Fonts (Poppins)
- **Icons**: Material Design Icons
- **Charts**: FL Chart library

### Somali Language Support
- UI text in Af-Soomaali
- Examples:
  - "Qiimee Delivery-ga" (Rate Delivery)
  - "Dalbashada Cusub" (New Order)
  - "Cuntooyinka" (Foods)

### Responsive Design
- Mobile-first approach
- Adaptive layouts
- Cross-platform compatibility

---

## 🔧 Recent Technical Improvements

### February 2026 Updates

1. **Delivery Rating System** ⭐
   - Added rating capability for users
   - Admin dashboard integration
   - Rating filter dropdown
   - Extended to Ready/Handed to Delivery statuses
   - Backend aggregation for statistics

2. **Security Enhancements**
   - Implemented `protect` middleware
   - Added `authorize` middleware for role-based access
   - Fixed authentication bugs

3. **Data Integrity**
   - Restaurant isolation enforcement
   - ObjectId validation
   - Proper error handling

4. **API Reliability**
   - Fixed import errors
   - Added validation layers
   - Improved error messages

5. **Admin Features**
   - Enhanced dashboard with rating stats
   - Order filtering capabilities
   - Improved staff management
   - Manual order creation

---

## 💻 Installation & Setup

### Prerequisites
- Node.js v18+ and npm
- Flutter SDK 3.x
- MongoDB Atlas account (or local MongoDB)
- Git

### Backend Setup

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd backend
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Configure environment variables:**
   Create `.env` file:
   ```env
   MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/dbname
   JWT_SECRET=your_secret_key_here
   PORT=5000
   ```

4. **Start the server:**
   ```bash
   npm run dev
   ```
   Server runs on `http://localhost:5000`

### Frontend Setup

1. **Navigate to frontend:**
   ```bash
   cd project_flutter_delivery_food_frontend
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure API endpoint:**
   Edit `lib/core/constants/api_constants.dart`:
   ```dart
   static const String baseUrl = 'http://localhost:5000/api';
   ```

4. **Run the app:**
   ```bash
   flutter run
   ```

### Default Admin Credentials
After initial setup, create a super admin account through MongoDB or registration endpoint with role set to `superadmin`.

---

## 📊 Database Schema Relationships

```
User ──┬─── Orders (userId)
       └─── Messages (userId)

Restaurant ──┬─── Orders (restaurantId)
             ├─── Food (restaurantId)
             ├─── Users (restaurantId) [staff/admin]
             └─── Messages (restaurantId)

Order ──┬─── User (userId)
        ├─── Restaurant (restaurantId)
        ├─── Staff (staffId)
        └─── Delivery (deliveryId)

Food ───── Restaurant (restaurantId)
```

---

## 🧪 Testing Recommendations

### User Flow Testing
1. Register new user
2. Browse restaurants
3. Add items to cart
4. Place order
5. Track order status
6. Rate delivery when ready/delivered

### Admin Flow Testing
1. Login as admin
2. View dashboard statistics
3. Manage menu items (CRUD)
4. View and filter orders
5. Update order statuses
6. View delivery ratings

### Staff Flow Testing
1. Login as staff
2. View pending orders
3. Accept/reject orders
4. Update order status through lifecycle
5. Mark orders as ready

### Edge Cases
- Out of stock items
- Invalid order data
- Unauthorized access attempts
- Rating validation (1-5 range)
- Restaurant isolation verification

---

## 🐛 Known Issues & Limitations

1. **Real-time Updates**: Currently uses polling, consider WebSockets for true real-time
2. **Image Storage**: Images stored locally, consider cloud storage (AWS S3, Cloudinary)
3. **Payment Integration**: Payment methods are placeholder, needs actual payment gateway
4. **Notifications**: Push notifications not implemented
5. **Geolocation**: No GPS tracking for delivery

---

## 🚀 Future Enhancements

### Planned Features
- [ ] Real-time order updates (WebSockets)
- [ ] Push notifications
- [ ] GPS delivery tracking
- [ ] Payment gateway integration (Stripe, PayPal)
- [ ] Multi-language support (English, Arabic)
- [ ] Customer loyalty program
- [ ] Promo codes and discounts
- [ ] Restaurant reviews and ratings
- [ ] Advanced analytics and reporting
- [ ] Mobile app optimization
- [ ] Dark mode support

---

## 📞 Support & Contact

For issues, questions, or contributions:
- **GitHub**: [Repository URL]
- **Email**: [Contact Email]
- **Documentation**: This file

---

## 📄 License

[Specify your license here - MIT, Apache, etc.]

---

## 👥 Contributors

- **Developer**: [Your Name]
- **Last Updated**: February 9, 2026
- **Version**: 2.0.0

---

## 📚 Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Express.js Guide](https://expressjs.com/)
- [MongoDB Manual](https://docs.mongodb.com/)
- [Provider Package](https://pub.dev/packages/provider)

---

**🎉 Thank you for using the Somali Food Delivery App!**

*Mahadsanid! (Thank you in Somali)*
