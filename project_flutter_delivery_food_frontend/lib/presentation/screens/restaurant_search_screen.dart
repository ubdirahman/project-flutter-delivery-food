import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../providers/food_provider.dart';
import '../../providers/cart_provider.dart';
import '../widgets/food_card.dart';
import 'restaurant_menu_screen.dart';

class RestaurantSearchScreen extends StatefulWidget {
  const RestaurantSearchScreen({super.key});

  @override
  State<RestaurantSearchScreen> createState() => _RestaurantSearchScreenState();
}

class _RestaurantSearchScreenState extends State<RestaurantSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            const SizedBox(height: 10),
            _buildSearchField(),
            const SizedBox(height: 20),
            _buildResultsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              size: 20,
              color: AppColors.textSecondary,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            'Search Dishes',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F1F1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (val) {
            setState(() {
              _query = val;
            });
          },
          decoration: InputDecoration(
            hintText: 'What are you looking for?',
            hintStyle: GoogleFonts.poppins(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
            prefixIcon: const Icon(
              Icons.search,
              color: AppColors.textSecondary,
            ),
            suffixIcon: _query.isNotEmpty
                ? IconButton(
                    icon: const Icon(
                      Icons.clear,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _query = '');
                    },
                  )
                : const Icon(Icons.mic_none, color: AppColors.textSecondary),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildResultsSection() {
    return Expanded(
      child: Consumer2<FoodProvider, CartProvider>(
        builder: (context, foodProvider, cartProvider, _) {
          final results = foodProvider.searchFoods(_query);

          if (_query.isEmpty && results.isEmpty) {
            return Center(
              child: Text(
                'Type to search for delicious Somali food',
                style: GoogleFonts.poppins(color: AppColors.textSecondary),
              ),
            );
          }

          if (results.isEmpty) {
            return Center(
              child: Text(
                'No results found for "$_query"',
                style: GoogleFonts.poppins(color: AppColors.textSecondary),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final food = results[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: FoodCard(
                  food: food,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          RestaurantMenuScreen(restaurantId: food.restaurantId),
                    ),
                  ),
                  onAdd: () {
                    cartProvider.addItem(food);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${food.name} added to cart!')),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
