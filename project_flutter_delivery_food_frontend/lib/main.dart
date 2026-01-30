import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './providers/food_provider.dart';
import './providers/cart_provider.dart';
import './providers/user_provider.dart';
import './providers/admin_provider.dart';
import './providers/restaurant_provider.dart';
import './providers/staff_provider.dart';

import './core/theme/app_theme.dart';
import './presentation/screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiProvider is used to manage the state of the application.
    // It allows different parts of the app to access data from these "Providers".
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => FoodProvider(),
        ), // Manages food data (menu, categories)
        ChangeNotifierProvider(
          create: (_) => CartProvider(),
        ), // Manages the shopping cart
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        ), // Manages user login and profile
        ChangeNotifierProvider(
          create: (_) => AdminProvider(),
        ), // Manages admin-specific features
        ChangeNotifierProvider(
          create: (_) => RestaurantProvider(),
        ), // Manages restaurant information
        ChangeNotifierProvider(
          create: (_) => StaffProvider(),
        ), // Manages staff-specific features
      ],
      child: MaterialApp(
        title: 'Somali Flavors',
        debugShowCheckedModeBanner:
            false, // Hides the "Debug" banner in the corner
        theme: AppTheme.lightTheme, // Sets the overall look (colors, fonts)
        home:
            const SplashScreen(), // The first screen that appears when the app starts
      ),
    );
  }
}
