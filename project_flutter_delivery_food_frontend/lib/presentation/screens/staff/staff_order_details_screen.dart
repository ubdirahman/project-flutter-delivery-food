import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/staff_provider.dart';
import '../../../providers/user_provider.dart';

class StaffOrderDetailsScreen extends StatelessWidget {
  final dynamic order;
  const StaffOrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final staffProv = context.read<StaffProvider>();
    final userProv = context.read<UserProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        backgroundColor: Colors.orange[800],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Customer Information'),
            ListTile(
              leading: const Icon(Icons.person),
              title: Text(
                order['userId'] != null
                    ? order['userId']['username']
                    : 'Unknown User',
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order['userId'] != null
                        ? order['userId']['email']
                        : 'No Email',
                  ),
                  Text(
                    'Phone: ${order['userId'] != null ? (order['userId']['phoneNumber'] ?? 'N/A') : 'N/A'}',
                  ),
                ],
              ),
            ),
            const Divider(),
            _buildSectionTitle('Order Items'),
            ...(order['items'] as List).map(
              (item) => ListTile(
                leading: const Icon(Icons.fastfood),
                title: Text(item['name']),
                subtitle: Text('Quantity: ${item['quantity']}'),
                trailing: Text('\$${item['price']}'),
              ),
            ),
            const Divider(),
            _buildSectionTitle('Payment & Address'),
            Text(
              'Amount: \$${order['totalAmount']}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Payment Method: ${order['paymentMethod']}'),
            Text('Payment Status: ${order['paymentStatus']}'),
            Text('Address: ${order['address']}'),
            const SizedBox(height: 24),
            _buildSectionTitle('Actions'),
            const SizedBox(height: 8),
            if (order['status'] == 'Pending') ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      onPressed: () async {
                        final success = await staffProv.acceptOrder(
                          order['_id'],
                          userProv.userId!,
                        );
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Order Accepted')),
                          );
                          Navigator.pop(context);
                        }
                      },
                      child: const Text(
                        'Accept Order',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () => _showRejectDialog(context, order['_id']),
                      child: const Text(
                        'Reject Order',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ] else if (order['status'] == 'Accepted') ...[
              _buildStatusButton(
                context,
                order['_id'],
                'Preparing',
                'Start Preparing',
              ),
            ] else if (order['status'] == 'Preparing') ...[
              _buildStatusButton(
                context,
                order['_id'],
                'Ready',
                'Mark as Ready',
              ),
            ] else if (order['status'] == 'Ready') ...[
              _buildStatusButton(
                context,
                order['_id'],
                'Handed to Delivery',
                'Handed to Delivery',
              ),
            ] else ...[
              Text(
                'Current Status: ${order['status']}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.blue,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.orange,
        ),
      ),
    );
  }

  Widget _buildStatusButton(
    BuildContext context,
    String orderId,
    String nextStatus,
    String label,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[800]),
        onPressed: () async {
          final success = await context.read<StaffProvider>().updateStatus(
            orderId,
            nextStatus,
          );
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Order status updated to $nextStatus')),
            );
            Navigator.pop(context);
          }
        },
        child: Text(label, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  void _showRejectDialog(BuildContext context, String orderId) {
    final TextEditingController reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Order'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            hintText: 'Enter reason for rejection',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (reasonController.text.isEmpty) return;
              final success = await Provider.of<StaffProvider>(
                context,
                listen: false,
              ).rejectOrder(orderId, reasonController.text);
              if (success) {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close details
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Order Rejected')));
              }
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }
}
