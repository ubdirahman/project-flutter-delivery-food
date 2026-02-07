import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../providers/staff_provider.dart';
import '../../../providers/user_provider.dart';

class StaffOrderDetailsScreen extends StatelessWidget {
  final dynamic order;
  const StaffOrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final staffProv = context.read<StaffProvider>();
    final userProv = context.read<UserProvider>();
    final isDelivery = userProv.isDelivery;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          isDelivery ? 'Delivery Progress' : 'Kitchen Management',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: isDelivery ? Colors.blue[800] : Colors.blue[900],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusBanner(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Customer Infomation'),
                  _buildInfoCard(
                    icon: Icons.person_outline,
                    title: order['userId'] != null
                        ? order['userId']['username']
                        : 'Unknown User',
                    subtitle: order['userId'] != null
                        ? '${order['userId']['email']}\nPhone: ${order['userId']['phoneNumber'] ?? 'N/A'}'
                        : 'No contact info',
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Order Items'),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      children: (order['items'] as List).map((item) {
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.fastfood_outlined,
                              color: Colors.blue,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            item['name'],
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text(
                            'Quantity: ${item['quantity']}',
                            style: GoogleFonts.poppins(fontSize: 12),
                          ),
                          trailing: Text(
                            '\$${item['price']}',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[900],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Payment & Delivery'),
                  _buildInfoCard(
                    icon: Icons.location_on_outlined,
                    title: 'Delivery Address',
                    subtitle: order['address'] ?? 'Mogadishu, Somalia',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    icon: Icons.payments_outlined,
                    title: 'Payment Details',
                    subtitle:
                        'Method: ${order['paymentMethod']}\nStatus: ${order['paymentStatus']}\nTotal: \$${order['totalAmount']}',
                  ),
                  const SizedBox(height: 32),
                  _buildActionButtons(context, userProv, staffProv),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.blue[900],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Status',
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${order['status']}',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '#${order['_id'].toString().substring(order['_id'].toString().length - 6)}',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue[900], size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    UserProvider userProv,
    StaffProvider staffProv,
  ) {
    final status = order['status'];
    final isDelivery = userProv.isDelivery;

    // 1. DELIVERY ROLE ACTIONS
    if (isDelivery) {
      if (order['deliveryId'] == null &&
          ['Accepted', 'Preparing', 'Ready'].contains(status)) {
        return Row(
          children: [
            Expanded(
              child: _buildButton(
                label: 'Agree (Take Delivery)',
                color: Colors.blue[800]!,
                onPressed: () async {
                  final success = await staffProv.agreeDelivery(
                    order['_id'],
                    userId: userProv.userId,
                  );
                  if (success) _onActionSuccess(context, 'Delivery Accepted');
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildButton(
                label: 'Reject',
                color: Colors.red[400]!,
                onPressed: () =>
                    _showRejectDeliveryDialog(context, order['_id']),
              ),
            ),
          ],
        );
      } else if (order['deliveryId'] != null &&
          (order['deliveryId'] is Map
              ? order['deliveryId']['_id'] == userProv.userId
              : order['deliveryId'] == userProv.userId)) {
        // Driver assigned to this order
        if (status == 'Ready') {
          return _buildButton(
            label: 'Pick Up Order',
            color: Colors.blue[800]!,
            onPressed: () => _updateStatus(context, 'Handed to Delivery'),
          );
        } else if (status == 'Handed to Delivery') {
          return _buildButton(
            label: 'Mark as Delivered',
            color: Colors.green[700]!,
            onPressed: () => _updateStatus(context, 'Delivered'),
          );
        }
      }

      return Center(
        child: Text(
          'Waiting for Kitchen/Pickup...',
          style: GoogleFonts.poppins(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    // 2. STAFF / ADMIN ROLE ACTIONS
    if (userProv.isStaff || userProv.isAdmin || userProv.isSuperAdmin) {
      if (status == 'Pending') {
        return Row(
          children: [
            Expanded(
              child: _buildButton(
                label: 'Accept Order',
                color: Colors.green[600]!,
                onPressed: () async {
                  final success = await staffProv.acceptOrder(
                    order['_id'],
                    userProv.userId!,
                    userId: userProv.userId,
                  );
                  if (success) _onActionSuccess(context, 'Order Accepted');
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildButton(
                label: 'Reject Order',
                color: Colors.red[600]!,
                onPressed: () => _showRejectDialog(context, order['_id']),
              ),
            ),
          ],
        );
      } else if (status == 'Accepted' &&
          (order['staffId'] == null ||
              (order['staffId'] is Map &&
                  order['staffId']['_id'] == userProv.userId) ||
              order['staffId'] == userProv.userId)) {
        return _buildButton(
          label: 'Start Preparing',
          color: Colors.purple[600]!,
          onPressed: () => _updateStatus(context, 'Preparing'),
        );
      } else if (status == 'Preparing') {
        return _buildButton(
          label: 'Mark as Ready',
          color: Colors.orange[800]!,
          onPressed: () => _updateStatus(context, 'Ready'),
        );
      }
    }

    return Center(
      child: Text(
        'Order is in $status state',
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
      ),
    );
  }

  Future<void> _updateStatus(BuildContext context, String status) async {
    final success = await context.read<StaffProvider>().updateStatus(
      order['_id'],
      status,
      userId: context.read<UserProvider>().userId,
    );
    if (success) _onActionSuccess(context, 'Status updated to $status');
  }

  void _onActionSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green[800],
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pop(context);
  }

  void _showRejectDialog(BuildContext context, String orderId) {
    final TextEditingController reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text('Reject Order', style: GoogleFonts.poppins()),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(hintText: 'Reason for rejection'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              if (reasonController.text.isEmpty) return;
              final success = await context.read<StaffProvider>().rejectOrder(
                orderId,
                reasonController.text,
                userId: context.read<UserProvider>().userId,
              );
              if (success) {
                Navigator.pop(dialogCtx);
                _onActionSuccess(context, 'Order Rejected');
              }
            },
            child: const Text('Reject', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showRejectDeliveryDialog(BuildContext context, String orderId) {
    final TextEditingController reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text('Reject Delivery', style: GoogleFonts.poppins()),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(hintText: 'Why reject this?'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              if (reasonController.text.isEmpty) return;
              final success = await context
                  .read<StaffProvider>()
                  .rejectDelivery(
                    orderId,
                    reasonController.text,
                    userId: context.read<UserProvider>().userId,
                  );
              if (success) {
                Navigator.pop(dialogCtx);
                _onActionSuccess(context, 'Delivery Rejected');
              }
            },
            child: const Text('Reject', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
