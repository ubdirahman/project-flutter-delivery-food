import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../providers/food_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/restaurant_provider.dart';
import '../widgets/home/category_menu_widget.dart';
import '../widgets/home/popular_foods_widget.dart';
import '../widgets/home/popular_restaurants_widget.dart';
import 'restaurant_search_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';
import 'login_screen.dart';
import 'orders_screen.dart';

// This is the Main Screen (Home) of the app.
// It is a "StatefulWidget" because it changes (e.g., when you click a category).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // This variable remembers which category is currently selected (e.g., 'All', 'Burger').
  String selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    // This runs once when the screen first opens.
    // It tells the app to go get the food and restaurant data from the server.
    Future.microtask(() {
      context.read<FoodProvider>().fetchFoods();
      context.read<RestaurantProvider>().fetchRestaurants();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: _buildDrawer(), // The side menu
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(), // Shows address and profile picture
              const SizedBox(height: 20),
              _buildWelcomeText(), // "Hey User , Have a good Day!"
              const SizedBox(height: 20),
              _buildSearchBar(), // Search bar that navigates to Search Screen
              const SizedBox(height: 24),

              // Category Menu (All, Burger, Pizza, etc.)
              HomeCategoryMenu(
                selectedCategory: selectedCategory,
                onCategorySelected: (cat) =>
                    setState(() => selectedCategory = cat),
              ),

              const SizedBox(height: 24),
              _buildSectionHeader('Popular Foods', () {}),

              // List of Foods based on selected category
              HomePopularFoods(selectedCategory: selectedCategory),

              const SizedBox(height: 24),
              _buildSectionHeader('Popular Restaurants', () {}),

              // List of Restaurants
              const HomePopularRestaurants(),

              const SizedBox(height: 24),
              _buildSectionHeader('Promo Banners', () {}),
              _buildPromoBanners(), // A simple burger banner
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      // Floating button to open the basket (Cart)
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CartScreen()),
        ),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.shopping_cart, color: AppColors.black),
      ),
      bottomNavigationBar: _buildBottomNav(), // The footer navigation icons
    );
  }

  // ---------------------------------------------------------------------------
  // HELPER WIDGETS (Small pieces of the UI)
  // ---------------------------------------------------------------------------

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: AppColors.textSecondary),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'DELIVER TO',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryRed,
                    letterSpacing: 1.0,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        'Mogadishu, Somalia',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Consumer<UserProvider>(
            builder: (context, userProvider, _) {
              final profileImage = userProvider.profileImage ?? '';
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                ),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary,
                  backgroundImage: profileImage.isNotEmpty
                      ? NetworkImage(profileImage)
                      : null,
                  child: profileImage.isEmpty
                      ? const Icon(
                          Icons.person,
                          color: AppColors.black,
                          size: 20,
                        )
                      : null,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.poppins(
            fontSize: 18,
            color: AppColors.textSecondary,
          ),
          children: [
            const TextSpan(text: 'Hey User , '),
            TextSpan(
              text: 'Have a good Day!',
              style: GoogleFonts.poppins(
                color: AppColors.primaryRed,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const RestaurantSearchScreen()),
        ),
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F1F1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: AppColors.textSecondary),
              const SizedBox(width: 12),
              Text(
                'Search dishes, restaurants',
                style: GoogleFonts.poppins(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              const Icon(Icons.mic_none, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onSeeAll) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          TextButton(
            onPressed: onSeeAll,
            child: const Text(
              'See all',
              style: TextStyle(color: AppColors.primaryRed),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoBanners() {
    return Column(
      children: [
        _buildPromoCard(
          'Delicious BURGER',
          'https://images.unsplash.com/photo-1571091718767-18b5b1457add?auto=format&fit=crop&w=800&q=80',
          true,
        ),
      ],
    );
  }

  Widget _buildPromoCard(String title, String imageUrl, bool showDetails) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.3),
            BlendMode.darken,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Delicious',
              style: GoogleFonts.playball(fontSize: 24, color: AppColors.white),
            ),
            Text(
              'SOMALI FOOD',
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: AppColors.primary,
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, 'Home', true, () {}),
          _buildNavItem(Icons.search, 'Search', false, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RestaurantSearchScreen()),
            );
          }),
          _buildNavItem(Icons.receipt_long, 'Orders', false, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const OrdersScreen()),
            );
          }),
          _buildNavItem(Icons.person, 'Profiles', false, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.primaryRed : AppColors.textSecondary,
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: isSelected
                  ? AppColors.primaryRed
                  : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          Consumer<UserProvider>(
            builder: (context, userProvider, _) {
              final profileImage = userProvider.profileImage ?? '';
              final username = userProvider.username ?? 'Guest User';
              final email = userProvider.email ?? 'Log in to sync data';

              return UserAccountsDrawerHeader(
                margin: EdgeInsets.zero,
                decoration: const BoxDecoration(color: AppColors.white),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: AppColors.primary,
                  backgroundImage: profileImage.isNotEmpty
                      ? NetworkImage(profileImage)
                      : null,
                  child: profileImage.isEmpty
                      ? const Icon(Icons.person, color: AppColors.black)
                      : null,
                ),
                accountName: Text(
                  username,
                  style: GoogleFonts.poppins(
                    color: AppColors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                accountEmail: Text(
                  email,
                  style: GoogleFonts.poppins(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              );
            },
          ),
          const Divider(height: 1),
          _buildDrawerItem(
            Icons.home,
            'Home',
            true,
            () => Navigator.pop(context),
          ),
          _buildDrawerItem(Icons.search, 'Search', false, () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RestaurantSearchScreen()),
            );
          }),
          _buildDrawerItem(Icons.receipt_long, 'Orders', false, () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const OrdersScreen()),
            );
          }),
          _buildDrawerItem(Icons.person_outline, 'Personal Info', false, () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          }),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: InkWell(
              onTap: () {
                final navigator = Navigator.of(context, rootNavigator: true);
                context.read<UserProvider>().logout();
                navigator.pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
              child: Row(
                children: [
                  const Icon(Icons.logout, color: AppColors.primaryRed),
                  const SizedBox(width: 10),
                  Text(
                    'Log Out',
                    style: GoogleFonts.poppins(
                      color: AppColors.primaryRed,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    IconData icon,
    String title,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryRed : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? AppColors.white : AppColors.textSecondary,
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            color: isSelected ? AppColors.white : AppColors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
