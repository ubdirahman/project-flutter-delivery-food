import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/colors.dart';
import '../../../../providers/food_provider.dart';
import '../../../../providers/cart_provider.dart';
import '../../screens/restaurant_menu_screen.dart';
import '../food_card.dart';

class HomePopularFoods extends StatelessWidget {
  final String selectedCategory;

  const HomePopularFoods({super.key, required this.selectedCategory});

  @override
  Widget build(BuildContext context) {
    // Consumer2 is used to listen to TWO providers at once (Food and Cart)
    return Consumer2<FoodProvider, CartProvider>(
      builder: (context, foodProvider, cartProvider, _) {
        final foods = foodProvider.getFoodsByCategory(selectedCategory);

        if (foodProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (foods.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'No food found in this category.',
              style: GoogleFonts.poppins(color: AppColors.textSecondary),
            ),
          );
        }

        return SizedBox(
          height: 260,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            scrollDirection: Axis.horizontal,
            itemCount: foods.length,
            itemBuilder: (context, index) {
              final food = foods[index];
              return FoodCard(
                food: food,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RestaurantMenuScreen(
                      restaurantId: food.restaurantId,
                      restaurantName:
                          'Restaurant Menu', // Generic if ID not found
                      // In a real app, we'd look up the restaurant name from ID
                    ),
                  ),
                ),
                onAdd: () {
                  cartProvider.addItem(food);
                  // Show a small message at the bottom when an item is added
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${food.name} added to cart!'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
