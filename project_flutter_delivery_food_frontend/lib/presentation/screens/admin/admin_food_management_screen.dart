import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../providers/food_provider.dart';
import '../../../providers/admin_provider.dart';
import '../../../data/models/food_model.dart';
import 'admin_edit_food_dialog.dart';

class AdminFoodManagementScreen extends StatefulWidget {
  const AdminFoodManagementScreen({super.key});

  @override
  State<AdminFoodManagementScreen> createState() =>
      _AdminFoodManagementScreenState();
}

class _AdminFoodManagementScreenState extends State<AdminFoodManagementScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<FoodProvider>().fetchFoods());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Menu Management',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<FoodProvider>(
        builder: (context, foodProvider, child) {
          if (foodProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final foods = foodProvider.foods;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: foods.length,
            itemBuilder: (context, index) {
              final food = foods[index];
              return _buildFoodItem(context, food);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEditDialog(context, null),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFoodItem(BuildContext context, FoodModel food) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            food.image,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Container(width: 60, height: 60, color: Colors.grey[200]),
          ),
        ),
        title: Text(
          food.name,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '\$${food.price} • ${food.category}',
          style: GoogleFonts.poppins(color: Colors.grey[600]),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _showEditDialog(context, food),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDelete(context, food),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, FoodModel? food) {
    showDialog(
      context: context,
      builder: (context) => AdminEditFoodDialog(food: food),
    ).then((_) {
      if (mounted) context.read<FoodProvider>().fetchFoods();
    });
  }

  void _confirmDelete(BuildContext context, FoodModel food) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete ${food.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await context.read<AdminProvider>().deleteFood(
                food.id,
              );
              if (success && mounted) {
                context.read<FoodProvider>().fetchFoods();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Item deleted successfully')),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
