import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../data/models/food_model.dart';
import '../../../providers/admin_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../data/services/admin_api_service.dart';
import 'package:image_picker/image_picker.dart';

class AdminEditFoodDialog extends StatefulWidget {
  final FoodModel? food;

  const AdminEditFoodDialog({super.key, this.food});

  @override
  State<AdminEditFoodDialog> createState() => _AdminEditFoodDialogState();
}

class _AdminEditFoodDialogState extends State<AdminEditFoodDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late TextEditingController _quantityController;
  late TextEditingController _imageController;
  String _category = 'Fast Food';
  bool _isPopular = false;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();
  String? _uploadedImageUrl;

  final List<String> _categories = [
    'Fast Food',
    'Drinks',
    'Bariis',
    'Baasto',
    'Appetizer',
    'Dessert',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.food?.name ?? '');
    _descController = TextEditingController(
      text: widget.food?.description ?? '',
    );
    _priceController = TextEditingController(
      text: widget.food?.price.toString() ?? '',
    );
    _quantityController = TextEditingController(
      text: widget.food?.quantity.toString() ?? '0',
    );
    _imageController = TextEditingController(text: widget.food?.image ?? '');
    _category = widget.food?.category ?? 'Fast Food';
    if (!_categories.contains(_category)) _categories.add(_category);
    _isPopular = widget.food?.isPopular ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.all(24),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.food == null ? 'Add New Item' : 'Edit Item',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      children: [
        SizedBox(
          width: 400, // Safe fixed width for the content
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(
                  controller: _nameController,
                  label: 'Name',
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if (v.length < 3)
                      return 'Name must be at least 3 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _descController,
                  label: 'Description',
                  maxLines: 2,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if (v.length < 10)
                      return 'Description must be at least 10 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _priceController,
                        label: 'Price',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*'),
                          ),
                        ],
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          final price = double.tryParse(v);
                          if (price == null) return 'Invalid number';
                          if (price <= 0) return 'Price must be > 0';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        controller: _quantityController,
                        label: 'Quantity',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.image, color: AppColors.primary),
                      onPressed: _pickImage,
                      tooltip: 'Pick Image',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _imageController,
                  label: 'Image URL',
                  validator: (v) => v!.isEmpty && _uploadedImageUrl == null
                      ? 'Required'
                      : null,
                ),
                if (_uploadedImageUrl != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Image uploaded',
                      style: TextStyle(color: Colors.green, fontSize: 12),
                    ),
                  ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _category,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  items: _categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (val) => setState(() => _category = val!),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Popular Item', style: GoogleFonts.poppins()),
                  activeColor: AppColors.primary,
                  value: _isPopular,
                  onChanged: (val) => setState(() => _isPopular = val),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.poppins(color: Colors.grey),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveFood,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        minimumSize: const Size(0, 0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Save',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() => _isLoading = true);

        final apiService = AdminApiService();
        final userId = context.read<UserProvider>().userId;
        final imageUrl = await apiService.uploadFoodImage(
          image,
          userId: userId,
        );

        if (imageUrl != null) {
          setState(() {
            _uploadedImageUrl = imageUrl;
            _imageController.text = imageUrl;
            _isLoading = false;
          });
        } else {
          setState(() => _isLoading = false);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to upload image')),
            );
          }
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _saveFood() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final foodData = {
      'name': _nameController.text,
      'description': _descController.text,
      'price': double.tryParse(_priceController.text) ?? 0.0,
      'quantity': int.tryParse(_quantityController.text) ?? 0,
      'image': _uploadedImageUrl ?? _imageController.text,
      'category': _category,
      'isPopular': _isPopular,
      'restaurantId': context.read<UserProvider>().restaurantId,
    };

    bool success;

    final up = context.read<UserProvider>();
    final userId = up.userId;
    final restaurantId = up.restaurantId;

    foodData['restaurantId'] = restaurantId;

    if (widget.food != null) {
      success = await context.read<AdminProvider>().updateFood(
        widget.food!.id,
        foodData,
        userId: userId,
      );
    } else {
      success = await context.read<AdminProvider>().addFood(
        foodData,
        userId: userId,
      );
    }

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Saved successfully')));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Operation failed')));
      }
    }
  }
}
