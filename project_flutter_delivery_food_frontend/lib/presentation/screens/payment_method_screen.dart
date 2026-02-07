import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../providers/cart_provider.dart';
import '../../providers/user_provider.dart';
import '../../data/services/api_service.dart';
import 'payment_success_screen.dart';

class PaymentMethodScreen extends StatefulWidget {
  final double totalAmount;

  const PaymentMethodScreen({super.key, required this.totalAmount});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  String selectedMethod = 'EVC-PLUS';
  final TextEditingController _phoneController = TextEditingController(
    text: '61',
  );
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    _buildAppBar(context),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Payment Method',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Choose your preferred mobile money',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 30),

                          // EVC Plus Selection
                          GestureDetector(
                            onTap: () =>
                                setState(() => selectedMethod = 'EVC-PLUS'),
                            child: _buildPaymentOption(
                              'EVC-PLUS',
                              AppColors.evcGreen,
                              Colors.white,
                              selectedMethod == 'EVC-PLUS',
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'OR',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Sahal Selection
                          GestureDetector(
                            onTap: () =>
                                setState(() => selectedMethod = 'SAHAL'),
                            child: _buildPaymentOption(
                              'SAHAL',
                              AppColors.sahalBlue,
                              Colors.white,
                              selectedMethod == 'SAHAL',
                            ),
                          ),

                          const SizedBox(height: 40),
                          _buildInputField(
                            'Enter Phone number',
                            _phoneController,
                            TextInputType.phone,
                          ),
                          const SizedBox(height: 16),
                          _buildDisabledInputField(
                            'Amount \$',
                            widget.totalAmount.toStringAsFixed(2),
                          ),
                          const SizedBox(height: 60),
                          _buildSendButton(context),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.black),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 10),
          Text(
            'Checkout',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(
    String title,
    Color bgColor,
    Color textColor,
    bool isSelected,
  ) {
    return Container(
      width: double.infinity,
      height: 70,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(15),
        border: isSelected
            ? Border.all(color: AppColors.black, width: 3)
            : null,
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: bgColor.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ]
            : null,
      ),
      alignment: Alignment.center,
      child: Stack(
        children: [
          Center(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: textColor,
                letterSpacing: 2,
              ),
            ),
          ),
          if (isSelected)
            const Positioned(
              right: 15,
              top: 0,
              bottom: 0,
              child: Icon(Icons.check_circle, color: Colors.white, size: 24),
            ),
        ],
      ),
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    TextInputType type,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 55,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextField(
            controller: controller,
            keyboardType: type,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'e.g. 61xxxxxxx',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDisabledInputField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 55,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSendButton(BuildContext context) {
    return ElevatedButton(
      onPressed: _isLoading ? null : () => _handlePayment(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryRed,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
      child: Text(
        'CONFIRM PAYMENT',
        style: GoogleFonts.poppins(
          color: AppColors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Future<void> _handlePayment(BuildContext context) async {
    if (_phoneController.text.length < 9) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Fadlan geli lambar sax ah (Please enter a valid phone number)',
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final userProvider = context.read<UserProvider>();
    final cartProvider = context.read<CartProvider>();

    String? restaurantId;
    if (cartProvider.items.isNotEmpty) {
      restaurantId = cartProvider.items.values.first.restaurantId;
    }

    final orderData = {
      'userId': userProvider.userId,
      'restaurantId': restaurantId,
      'items': cartProvider.items.values
          .map(
            (item) => {
              'foodId': item.id,
              'name': item.name,
              'price': item.price,
              'quantity': item.quantity,
              'image': item.image,
            },
          )
          .toList(),
      'totalAmount': widget.totalAmount,
      'paymentMethod': selectedMethod,
      'address': 'Mogadishu, Somalia',
    };

    final success = await ApiService().placeOrder(
      orderData,
      userId: userProvider.userId,
    );

    if (success) {
      cartProvider.clear();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const PaymentSuccessScreen()),
          (route) => false,
        );
      }
    } else {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Waalaga xumaaday, dalabka ma guulaysan (Order failed)',
            ),
          ),
        );
      }
    }
  }
}
