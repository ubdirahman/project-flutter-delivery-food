import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../providers/food_provider.dart';
import '../../../providers/admin_provider.dart';
import '../../../data/models/food_model.dart';

class AdminCreateOrderScreen extends StatefulWidget {
  const AdminCreateOrderScreen({super.key});

  @override
  State<AdminCreateOrderScreen> createState() => _AdminCreateOrderScreenState();
}

class _AdminCreateOrderScreenState extends State<AdminCreateOrderScreen> {
  List<FoodModel> selectedItems = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Manual Order',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Customer',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // For simplicity, using a mock selector or assuming we have a user list
            _buildUserSelector(),
            const SizedBox(height: 24),
            Text(
              'Add Food Items',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildFoodSelector(),
            const SizedBox(height: 24),
            Text(
              'Selected Items:',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            ...selectedItems.map(
              (item) => ListTile(
                title: Text(item.name),
                trailing: Text('\$${item.price}'),
              ),
            ),
            const Divider(),
            _buildSummary(),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _submitOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                'Place Admin Order',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserSelector() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Customer: Test Customer (64b...)'),
          Icon(Icons.arrow_drop_down),
        ],
      ),
    );
  }

  Widget _buildFoodSelector() {
    final foods = context.watch<FoodProvider>().foods;
    return SizedBox(
      height: 220,
      child: foods.isEmpty
          ? const Center(child: Text('No food items available'))
          : ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: foods.length,
              itemBuilder: (context, index) {
                final food = foods[index];
                final isSelected = selectedItems.contains(food);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        selectedItems.remove(food);
                      } else {
                        selectedItems.add(food);
                      }
                    });
                  },
                  child: Container(
                    width: 160,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withOpacity(0.1)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.grey.shade200,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            child: Image.network(
                              food.image,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.grey[200],
                                child: const Icon(Icons.fastfood, size: 40),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                food.name,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '\$${food.price}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildSummary() {
    double total = selectedItems.fold(0, (sum, item) => sum + item.price);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Total Amount:',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          '\$${total.toStringAsFixed(2)}',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  void _submitOrder() async {
    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Add items first')));
      return;
    }

    final total = selectedItems.fold(0.0, (sum, item) => sum + item.price);

    // Using a hardcoded user ID for now as requested by user logic "Doorto customer" implies a selector
    // but we don't have a user list API. We'll use a placeholder or the current user's ID if available.
    // Ideally we should have a dropdown of users.
    const userId =
        "64b5f7e340c4973348123456"; // Placeholder ID or need to fetch users

    final orderData = {
      'userId': userId,
      'items': selectedItems
          .map(
            (e) => {
              'foodId': e.id,
              'name': e.name,
              'price': e.price,
              'quantity': 1,
              'image': e.image,
            },
          )
          .toList(),
      'totalAmount': total,
      'status': 'Pending',
      'address': 'Admin Created Order',
    };

    final provider = context.read<AdminProvider>();
    final success = await provider.createOrder(orderData);

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order created successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create order. Ensure user exists.'),
          ),
        );
      }
    }
  }
}
