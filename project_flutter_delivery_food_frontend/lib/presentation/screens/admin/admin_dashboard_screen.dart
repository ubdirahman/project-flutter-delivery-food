import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/colors.dart';
import '../../../providers/admin_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/restaurant_provider.dart';
import 'admin_orders_screen.dart';
import 'admin_food_management_screen.dart';
import 'admin_reports_screen.dart';
import 'admin_restaurants_screen.dart';
import 'admin_staff_management_screen.dart';
import 'admin_restaurant_profile_screen.dart';
import '../login_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final userProvider = context.read<UserProvider>();
      context.read<AdminProvider>().fetchDashboardData(
        restaurantId: userProvider.restaurantId,
        userId: userProvider.userId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      drawer: _buildDrawer(context),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Consumer<AdminProvider>(
          builder: (context, ap, _) {
            final name = ap.managedRestaurant?['name'];
            return Text(
              name != null ? '$name Admin' : 'Admin Dashboard',
              style: GoogleFonts.poppins(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final up = context.read<UserProvider>();
              context.read<AdminProvider>().fetchDashboardData(
                restaurantId: up.restaurantId,
                userId: up.userId,
              );
            },
            tooltip: 'Refresh Data',
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
          const CircleAvatar(
            backgroundColor: AppColors.primary,
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, child) {
          if (adminProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final stats = adminProvider.stats;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Consumer<UserProvider>(
                    builder: (context, userProv, _) {
                      if (userProv.isSuperAdmin) {
                        return _buildRestaurantSelector(context);
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Overview',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildStatCards(stats, context),
                  const SizedBox(height: 24),
                  if (adminProvider.topRestaurants.isNotEmpty &&
                      !(Provider.of<UserProvider>(
                            context,
                            listen: false,
                          ).isSuperAdmin &&
                          adminProvider.selectedFilterRestaurantId ==
                              null)) ...[
                    _buildTopRestaurants(adminProvider.topRestaurants),
                    const SizedBox(height: 24),
                  ],
                  Consumer2<UserProvider, AdminProvider>(
                    builder: (context, userProv, adminProv, _) {
                      // Hide chart for Super Admin in Global View
                      if (userProv.isSuperAdmin &&
                          adminProv.selectedFilterRestaurantId == null) {
                        return const SizedBox.shrink();
                      }
                      return _buildPerformanceChart(adminProv.performanceData);
                    },
                  ),
                  const SizedBox(height: 24),
                  if (!adminProvider.isLoading &&
                      Provider.of<AdminProvider>(
                            context,
                            listen: false,
                          ).stats['topSellingItems'] !=
                          null &&
                      !(Provider.of<UserProvider>(
                            context,
                            listen: false,
                          ).isSuperAdmin &&
                          adminProvider.selectedFilterRestaurantId ==
                              null)) ...[
                    _buildTopSellingItems(
                      List<dynamic>.from(
                        adminProvider.stats['topSellingItems'] ?? [],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  if (!adminProvider.isLoading &&
                      !Provider.of<UserProvider>(
                        context,
                        listen: false,
                      ).isSuperAdmin) ...[
                    const SizedBox(height: 24),
                    _buildRecentOrders(
                      adminProvider.allOrders,
                    ), // Only show for Restaurant Admin
                    const SizedBox(height: 24),
                    _buildQuickActions(
                      context,
                    ), // Only show for Restaurant Admin
                  ],
                  const SizedBox(height: 20), // Bottom padding
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRestaurantSelector(BuildContext context) {
    return Consumer2<RestaurantProvider, UserProvider>(
      builder: (context, restProv, userProv, _) {
        final restaurants = restProv.restaurants;
        final selectedId = context
            .watch<AdminProvider>()
            .selectedFilterRestaurantId;

        // Ensure selectedId is valid
        final isValidSelection =
            selectedId == null || restaurants.any((r) => r.id == selectedId);
        final effectiveSelectedId = isValidSelection ? selectedId : null;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.restaurant, color: AppColors.primary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String?>(
                    value: effectiveSelectedId,
                    hint: Text(
                      'All Restaurants',
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                    items: [
                      DropdownMenuItem<String?>(
                        value: null,
                        child: Text(
                          'All Restaurants',
                          style: GoogleFonts.poppins(fontSize: 14),
                        ),
                      ),
                      ...restaurants.map((r) {
                        return DropdownMenuItem<String?>(
                          value: r.id,
                          child: Text(
                            r.name,
                            style: GoogleFonts.poppins(fontSize: 14),
                          ),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      context
                          .read<AdminProvider>()
                          .setSelectedFilterRestaurantId(value);
                      context.read<AdminProvider>().fetchDashboardData(
                        restaurantId: value,
                        userId: userProv.userId,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCards(Map<String, dynamic> stats, BuildContext context) {
    final userProv = Provider.of<UserProvider>(context, listen: false);
    final adminProv = Provider.of<AdminProvider>(context, listen: false);

    final isSuperAdminGlobal =
        userProv.isSuperAdmin && adminProv.selectedFilterRestaurantId == null;

    if (isSuperAdminGlobal) {
      return Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.5,
          child: _buildStatCard(
            'Total Restaurants',
            '${stats['totalRestaurants'] ?? 0}',
            Icons.restaurant,
            Colors.indigo,
          ),
        ),
      );
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'Total Orders',
          '${stats['totalOrders'] ?? 0}',
          Icons.shopping_bag_outlined,
          Colors.blue,
        ),
        _buildStatCard(
          'Total Revenue',
          '\$${stats['totalRevenue']?.toStringAsFixed(2) ?? '0.00'}',
          Icons.attach_money,
          Colors.green,
        ),
        _buildStatCard(
          'My Restaurant',
          '${userProv.isSuperAdmin ? stats['totalRestaurants'] : 1}',
          Icons.restaurant,
          Colors.indigo,
        ),
        _buildStatCard(
          'My Customers',
          '${stats['totalCustomers'] ?? 0}',
          Icons.people_outline,
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey),
          ),
          if (subtitle != null)
            Text(
              subtitle,
              style: GoogleFonts.poppins(fontSize: 9, color: Colors.grey[600]),
            ),
        ],
      ),
    );
  }

  Widget _buildPerformanceChart(List<dynamic> performance) {
    if (performance.isEmpty) {
      return Container(
        height: 200,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bar_chart, size: 48, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                'No performance data available',
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    // Calculate max value with minimum of 10 to ensure chart is visible
    double maxValue = performance.fold<double>(0, (prev, e) {
      final orders = e['orders'];
      final value = orders is int
          ? orders.toDouble()
          : (orders as double? ?? 0.0);
      return value > prev ? value : prev;
    });

    // Ensure minimum maxY of 10 for better visualization
    maxValue = maxValue < 5 ? 10 : maxValue + 5;

    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Performance',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxValue,
                minY: 0,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${rod.toY.toInt()} orders',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index >= 0 && index < performance.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              performance[index]['date'] ?? '',
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxValue / 5,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(color: Colors.grey[200], strokeWidth: 1);
                  },
                ),
                borderData: FlBorderData(show: false),
                barGroups: performance.asMap().entries.map((e) {
                  final orders = e.value['orders'];
                  final orderValue = orders is int
                      ? orders.toDouble()
                      : (orders as double? ?? 0.0);

                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: orderValue,
                        color: AppColors.primary,
                        width: 16,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopRestaurants(List<dynamic> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Performing Restaurants',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) =>
                Divider(height: 1, color: Colors.grey[100]),
            itemBuilder: (context, index) {
              final res = items[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: res['image'] != null && res['image'].isNotEmpty
                      ? Image.network(
                          res['image'],
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 48,
                            height: 48,
                            color: Colors.grey[200],
                            child: const Icon(Icons.restaurant, size: 20),
                          ),
                        )
                      : Container(
                          width: 48,
                          height: 48,
                          color: Colors.grey[200],
                          child: const Icon(Icons.restaurant, size: 20),
                        ),
                ),
                title: Text(
                  res['name'] ?? 'Restaurant',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${res['totalOrders']} orders',
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                ),
                trailing: Text(
                  '\$${res['totalRevenue']?.toStringAsFixed(2) ?? '0.00'}',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTopSellingItems(List<dynamic> items) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Selling Products',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) =>
                Divider(height: 1, color: Colors.grey[100]),
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: item['image'] != null && item['image'].isNotEmpty
                      ? Image.network(
                          item['image'],
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 48,
                            height: 48,
                            color: Colors.grey[200],
                            child: const Icon(Icons.fastfood, size: 20),
                          ),
                        )
                      : Container(
                          width: 48,
                          height: 48,
                          color: Colors.grey[200],
                          child: const Icon(Icons.fastfood, size: 20),
                        ),
                ),
                title: Text(
                  item['name'] ?? 'Product',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${item['totalQuantity']} sold • ${item['totalOrders']} orders',
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                ),
                trailing: Text(
                  '\$${item['totalRevenue']?.toStringAsFixed(2) ?? '0.00'}',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentOrders(List<dynamic> orders) {
    final recentOrders = orders.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Orders',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminOrdersScreen()),
              ),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: recentOrders.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      'No orders yet',
                      style: GoogleFonts.poppins(color: Colors.grey),
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recentOrders.length,
                  separatorBuilder: (context, index) =>
                      Divider(height: 1, color: Colors.grey[100]),
                  itemBuilder: (context, index) {
                    final order = recentOrders[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      title: Text(
                        'Order #${order['_id'].toString().substring(order['_id'].toString().length - 6)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${order['items']?.length ?? 0} items • ${order['status']}',
                        style: TextStyle(
                          color: _getStatusColor(order['status']),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: Text(
                        '\$${order['totalAmount']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Accepted':
      case 'Preparing':
        return Colors.blue;
      case 'Ready':
      case 'Handed to Delivery':
        return Colors.purple;
      case 'Delivered':
        return Colors.green;
      case 'Cancelled':
      case 'Rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildActionCard(
              context,
              'Manage Orders',
              Icons.list_alt,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminOrdersScreen()),
              ),
            ),
            const SizedBox(width: 16),
            _buildActionCard(
              context,
              'Menu & Food',
              Icons.restaurant_menu,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdminFoodManagementScreen(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.primary, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final isSuperAdmin = userProvider.isSuperAdmin;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.admin_panel_settings,
                    color: AppColors.primary,
                    size: 35,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  isSuperAdmin ? 'Global Admin' : 'Restaurant Admin',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () => Navigator.pop(context),
          ),
          if (!isSuperAdmin)
            ListTile(
              leading: const Icon(Icons.shopping_bag),
              title: const Text('Orders'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminOrdersScreen()),
                );
              },
            ),
          if (!isSuperAdmin) ...[
            ListTile(
              leading: const Icon(Icons.fastfood),
              title: const Text('Menu Management'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminFoodManagementScreen(),
                  ),
                );
              },
            ),
          ],
          if (isSuperAdmin) ...[
            ListTile(
              leading: const Icon(Icons.restaurant),
              title: const Text('Restaurants'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminRestaurantsScreen(),
                  ),
                );
              },
            ),
          ],
          if (!isSuperAdmin)
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text('Reports'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminReportsScreen()),
                );
              },
            ),
          if (!isSuperAdmin) ...[
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Staff Management'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminStaffManagementScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.restaurant_outlined),
              title: const Text('Restaurant Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminRestaurantProfileScreen(),
                  ),
                );
              },
            ),
          ],
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
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
    );
  }
}
