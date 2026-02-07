import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../providers/staff_provider.dart';
import '../../../providers/user_provider.dart';
import 'staff_order_details_screen.dart';

class DeliveryActiveOrdersScreen extends StatefulWidget {
  const DeliveryActiveOrdersScreen({super.key});

  @override
  State<DeliveryActiveOrdersScreen> createState() =>
      _DeliveryActiveOrdersScreenState();
}

class _DeliveryActiveOrdersScreenState
    extends State<DeliveryActiveOrdersScreen> {
  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    Future.microtask(() {
      if (!mounted) return;
      final userProvider = context.read<UserProvider>();
      context.read<StaffProvider>().fetchManagedOrders(
        userId: userProvider.userId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'My Deliveries',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshData),
        ],
      ),
      body: Consumer<StaffProvider>(
        builder: (context, staffProv, child) {
          if (staffProv.isLoadingManaged) {
            return const Center(child: CircularProgressIndicator());
          }

          if (staffProv.managedOrders.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.delivery_dining_outlined,
                      size: 80,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No active deliveries',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Claim ready orders from the dashboard to start delivering.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: staffProv.managedOrders.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final order = staffProv.managedOrders[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: _getStatusIcon(order['status']),
                  title: Text(
                    'Order #${order['_id'].toString().substring(order['_id'].toString().length - 6)}',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${order['address'] ?? 'N/A'}',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(
                                order['status'],
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              order['status'],
                              style: GoogleFonts.poppins(
                                color: _getStatusColor(order['status']),
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          Text(
                            '\$${order['totalAmount']}',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Colors.grey,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StaffOrderDetailsScreen(order: order),
                      ),
                    ).then((_) => _refreshData());
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _getStatusIcon(String status) {
    IconData icon;
    Color color;
    switch (status) {
      case 'Handed to Delivery':
        icon = Icons.delivery_dining;
        color = Colors.green;
        break;
      case 'Delivered':
        icon = Icons.check_circle;
        color = Colors.green[800]!;
        break;
      default:
        icon = Icons.local_shipping;
        color = Colors.blue;
    }
    return CircleAvatar(
      backgroundColor: color.withOpacity(0.1),
      child: Icon(icon, color: color),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Handed to Delivery':
        return Colors.green;
      case 'Delivered':
        return Colors.green[800]!;
      default:
        return Colors.blue;
    }
  }
}
