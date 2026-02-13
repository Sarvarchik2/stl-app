import 'package:flutter/material.dart';
import '../../../../core/app_colors.dart';
import '../../../home/presentation/pages/home_screen.dart';
import '../../../catalog/presentation/pages/catalog_screen.dart';
import '../../../applications/presentation/pages/applications_screen.dart';
import '../../../profile/presentation/pages/profile_screen.dart';
import '../../../catalog/presentation/pages/favorites_screen.dart';

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _selectedIndex = 0; // Default to Home

  final List<Widget> _pages = [
    const HomeScreen(),
    const CatalogScreen(),
    const FavoritesScreen(),
    const ApplicationsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          RepaintBoundary(
            child: _pages[_selectedIndex],
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 30,
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A).withOpacity(0.8),
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem(0, Icons.home_rounded),
                    _buildNavItem(1, Icons.search_rounded),
                    _buildNavItem(2, Icons.favorite_rounded),
                    _buildNavItem(3, Icons.description_rounded),
                    _buildNavItem(4, Icons.person_rounded),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : AppColors.grey,
          size: 28,
        ),
      ),
    );
  }
}
