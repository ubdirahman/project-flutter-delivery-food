import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/staff_provider.dart';
import '../../../providers/user_provider.dart';
import '../login_screen.dart';
import 'staff_order_details_screen.dart';

class StaffDashboardScreen extends StatefulWidget {
  const StaffDashboardScreen({super.key});

  @override
  State<StaffDashboardScreen> createState() => _StaffDashboardScreenState();
}

class _StaffDashboardScreenState extends State<StaffDashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<StaffProvider>().fetchPendingOrders());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Panel - New Orders'),
        backgroundColor: Colors.orange[800],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<StaffProvider>().fetchPendingOrders(),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              final navigator = Navigator.of(context, rootNavigator: true);
              context.read<UserProvider>().logout();
              navigator.pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Consumer<StaffProvider>(
        builder: (context, staffProv, child) {
          if (staffProv.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (staffProv.pendingOrders.isEmpty) {
            return const Center(
              child: Text('No pending orders at the moment.'),
            );
          }

          return ListView.builder(
            itemCount: staffProv.pendingOrders.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final order = staffProv.pendingOrders[index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: Colors.orange[100],
                    child: Icon(Icons.shopping_bag, color: Colors.orange[800]),
                  ),
                  title: Text(
                    'Order #${order['_id'] != null ? order['_id'].toString().substring(order['_id'].toString().length >= 6 ? order['_id'].toString().length - 6 : 0) : 'N/A'}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        'User: ${order['userId'] != null ? order['userId']['username'] : 'Unknown'}',
                      ),
                      Text('Amount: \$${order['totalAmount']}'),
                      Text('Status: ${order['status']}'),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StaffOrderDetailsScreen(order: order),
                      ),
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
