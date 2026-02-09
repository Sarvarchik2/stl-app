import 'package:flutter/material.dart';
import 'package:stl_app/core/app_colors.dart';
import 'package:stl_app/core/di/service_locator.dart';
import 'package:stl_app/features/catalog/data/models/car_model.dart';
import 'package:stl_app/features/catalog/data/repositories/catalog_repository.dart';
import 'package:stl_app/features/catalog/presentation/pages/car_detail_screen.dart';
import 'package:stl_app/features/auth/data/models/user_model.dart';
import 'package:stl_app/features/auth/data/repositories/auth_repository.dart';
import 'package:stl_app/core/localization/app_strings.dart';
import 'package:stl_app/features/home/data/models/story_model.dart';
import 'package:stl_app/features/home/data/repositories/story_repository.dart';
import 'package:stl_app/core/utils/url_util.dart';
import 'story_view_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CatalogRepository _catalogRepository = sl<CatalogRepository>();
  final AuthRepository _authRepository = sl<AuthRepository>();
  final StoryRepository _storyRepository = sl<StoryRepository>();
  
  List<CarModel> _popularCars = [];
  List<StoryModel> _stories = [];
  UserModel? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (mounted) {
      setState(() => _isLoading = true);
    }
    await Future.wait([
      _loadPopularCars(),
      _loadProfile(),
      _loadStories(),
    ]);
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadProfile() async {
    try {
      final user = await _authRepository.getMe();
      if (mounted) {
        setState(() => _user = user);
      }
    } catch (_) {}
  }

  Future<void> _loadPopularCars() async {
    try {
      final cars = await _catalogRepository.getCars();
      if (mounted) {
        setState(() {
          _popularCars = cars.take(5).toList();
        });
      }
    } catch (e) {}
  }

  Future<void> _loadStories() async {
    try {
      final stories = await _storyRepository.getStories();
      if (mounted) {
        setState(() {
          _stories = stories;
        });
      }
    } catch (_) {}
  }

  String _getLocalized(LocalizedString text) {
    switch (AppStrings.currentLanguage) {
      case AppLanguage.uz: return text.uz;
      case AppLanguage.en: return text.en;
      case AppLanguage.ru:
      default: return text.ru;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          color: AppColors.primary,
          child: ListView(
            key: const PageStorageKey('home_list'),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildStories(context),
              const SizedBox(height: 32),
              _buildSectionHeader(AppStrings.get('brands')),
              const SizedBox(height: 16),
              _buildBrandsScroll(),
              const SizedBox(height: 32),
              _buildQuickActions(),
              const SizedBox(height: 32),
              _buildPromotionalBanner(),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.get('special_offers'),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(AppStrings.get('all'), style: const TextStyle(color: AppColors.primary)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_popularCars.isEmpty && _isLoading)
                const Center(child: CircularProgressIndicator(color: AppColors.primary))
              else
                ..._popularCars.map((car) => _buildPopularCarItem(car)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
          child: const Icon(Icons.person, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_user?.fullName ?? 'STL LOGISTICS', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text(_user?.phone ?? '', style: const TextStyle(color: AppColors.grey, fontSize: 14)),
          ],
        ),
        const Spacer(),
        _buildNotificationIcon(),
      ],
    );
  }

  Widget _buildNotificationIcon() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
      child: const Icon(Icons.notifications_none, size: 24),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold));
  }

  Widget _buildStories(BuildContext context) {
    if (_stories.isEmpty && !_isLoading) return const SizedBox.shrink();
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _isLoading ? 4 : _stories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          if (_isLoading) {
            return Container(width: 60, height: 60, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.surface));
          }
          final story = _stories[index];
          return GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => StoryViewScreen(story: story))),
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [Colors.orange, AppColors.primary]),
                    border: Border.all(color: Colors.transparent, width: 2),
                  ),
                  padding: const EdgeInsets.all(2),
                  child: ClipOval(
                    child: Image.network(
                      UrlUtil.sanitize(story.previewImage),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.surface,
                        child: const Icon(Icons.star, color: AppColors.primary, size: 24),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getLocalized(story.title),
                  style: const TextStyle(fontSize: 11, color: Colors.white70),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBrandsScroll() {
    final brands = [
      {'name': 'BMW', 'logo': '🚗'},
      {'name': 'Mercedes', 'logo': '🏎'},
      {'name': 'Audi', 'logo': '🚙'},
      {'name': 'Toyota', 'logo': '🚕'},
      {'name': 'Honda', 'logo': '🚐'},
    ];

    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: brands.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (_, index) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20)),
            child: Center(child: Text(brands[index]['logo']!, style: const TextStyle(fontSize: 28))),
          );
        },
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(child: _buildActionCard(AppStrings.get('calculate_cost'), Icons.calculate, Colors.blue)),
        const SizedBox(width: 16),
        Expanded(child: _buildActionCard(AppStrings.get('track_delivery'), Icons.local_shipping, Colors.green)),
      ],
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildPromotionalBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: LinearGradient(colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)])),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('STL Logistics & Auto', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          const Text('Прямые аукционы и быстрая логистика', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: Text(AppStrings.get('details')),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularCarItem(CarModel car) {
    final heroTag = 'home_car_${car.id}';
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CarDetailScreen(car: car, heroTag: heroTag))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                car.photos.isNotEmpty ? UrlUtil.sanitize(car.photos[0]) : '',
                width: 100, height: 100, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(width: 100, height: 100, color: AppColors.darkGrey, child: const Icon(Icons.directions_car, color: AppColors.grey)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${car.brand} ${car.model}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('${car.year} • ${car.engine ?? ""}', style: const TextStyle(color: AppColors.grey, fontSize: 13)),
                  const SizedBox(height: 8),
                  Text('\$${car.finalPriceUsd}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.grey),
          ],
        ),
      ),
    );
  }
}
