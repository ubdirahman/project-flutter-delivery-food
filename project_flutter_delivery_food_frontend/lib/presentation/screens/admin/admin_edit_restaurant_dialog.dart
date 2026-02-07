import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../providers/admin_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../data/models/restaurant_model.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/services/admin_api_service.dart';

class AdminEditRestaurantDialog extends StatefulWidget {
  final RestaurantModel? restaurant;

  const AdminEditRestaurantDialog({super.key, this.restaurant});

  @override
  State<AdminEditRestaurantDialog> createState() =>
      _AdminEditRestaurantDialogState();
}

class _AdminEditRestaurantDialogState extends State<AdminEditRestaurantDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _descController;
  late TextEditingController _ratingController;
  late TextEditingController _imageUrlController;
  late TextEditingController _adminEmailController;
  late TextEditingController _adminPasswordController;
  late TextEditingController _adminUsernameController;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.restaurant?.name ?? '',
    );
    _addressController = TextEditingController(
      text: widget.restaurant?.address ?? '',
    );
    _phoneController = TextEditingController(
      text: widget.restaurant?.phone ?? '',
    );
    _descController = TextEditingController(
      text: widget.restaurant?.description ?? '',
    );
    _ratingController = TextEditingController(
      text: widget.restaurant?.rating.toString() ?? '0.0',
    );
    _imageUrlController = TextEditingController(
      text: widget.restaurant?.image ?? '',
    );
    _adminEmailController = TextEditingController();
    _adminPasswordController = TextEditingController();
    _adminUsernameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _descController.dispose();
    _ratingController.dispose();
    _imageUrlController.dispose();
    _adminEmailController.dispose();
    _adminPasswordController.dispose();
    _adminUsernameController.dispose();
    super.dispose();
  }

  Future<void> _saveRestaurant() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final restaurantData = {
      'name': _nameController.text,
      'address': _addressController.text,
      'phone': _phoneController.text,
      'description': _descController.text,
      'rating': double.tryParse(_ratingController.text) ?? 0.0,
      'image': _imageUrlController.text,
      if (widget.restaurant == null) ...{
        'adminEmail': _adminEmailController.text,
        'adminPassword': _adminPasswordController.text,
        'adminUsername': _adminUsernameController.text,
      },
    };

    String? error;
    final userId = context.read<UserProvider>().userId;
    if (widget.restaurant != null) {
      error = await context.read<AdminProvider>().updateRestaurant(
        widget.restaurant!.id,
        restaurantData,
        userId: userId,
      );
    } else {
      error = await context.read<AdminProvider>().addRestaurant(
        restaurantData,
        userId: userId,
      );
    }

    if (mounted) {
      setState(() => _isLoading = false);
      if (error == null) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.restaurant != null
                  ? 'Restaurant updated successfully'
                  : 'Restaurant added successfully',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      }
    }
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
            _imageUrlController.text = imageUrl;
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.restaurant != null
                    ? 'Edit Restaurant'
                    : 'Add New Restaurant',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _nameController,
                      label: 'Restaurant Name',
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-Z\s]'),
                        ),
                      ],
                      validator: (v) =>
                          v?.isEmpty ?? true ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _addressController,
                      label: 'Address',
                      validator: (v) =>
                          v?.isEmpty ?? true ? 'Address is required' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _phoneController,
                      label: 'Phone',
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) =>
                          v?.isEmpty ?? true ? 'Phone is required' : null,
                    ),
                    const SizedBox(height: 16),
                    Column(
                      children: [
                        if (_imageUrlController.text.isNotEmpty)
                          Container(
                            height: 120,
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image: NetworkImage(_imageUrlController.text),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _imageUrlController,
                                label: 'Image URL',
                                validator: (v) => v?.isEmpty ?? true
                                    ? 'Image URL is required'
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: _isLoading ? null : _pickImage,
                              icon: const Icon(Icons.image_outlined),
                              style: IconButton.styleFrom(
                                backgroundColor: AppColors.primary.withAlpha(
                                  26,
                                ),
                                foregroundColor: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _ratingController,
                            label: 'Rating (0-5)',
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d*'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _descController,
                      label: 'Description',
                      maxLines: 3,
                    ),
                    if (widget.restaurant == null) ...[
                      const SizedBox(height: 24),
                      Text(
                        'Admin Credentials',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _adminUsernameController,
                        label: 'Admin Username (Optional)',
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _adminEmailController,
                        label: 'Admin Email',
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => v?.isEmpty ?? true
                            ? 'Admin email is required'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _adminPasswordController,
                        label: 'Admin Password',
                        obscureText: true,
                        validator: (v) => v?.isEmpty ?? true
                            ? 'Admin password is required'
                            : null,
                      ),
                    ],
                  ],
                ),
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
                    onPressed: _isLoading ? null : _saveRestaurant,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size(0, 0),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            'Save',
                            style: GoogleFonts.poppins(
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
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      obscureText: obscureText,
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
      ),
    );
  }
}
