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
import 'package:stl_app/core/utils/formatter_util.dart';
import 'story_view_screen.dart';
import 'package:stl_app/features/profile/presentation/pages/contact_us_screen.dart';

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
            Text(FormatterUtil.formatPhone(_user?.phone ?? ''), style: const TextStyle(color: AppColors.grey, fontSize: 14)),
          ],
        ),
        const Spacer(),
        _buildLanguageSwitcher(),
      ],
    );
  }

  Widget _buildLanguageSwitcher() {
    final lang = AppStrings.currentLanguage;
    final label = lang == AppLanguage.ru ? 'RU' : (lang == AppLanguage.uz ? 'UZ' : 'EN');
    
    return GestureDetector(
      onTap: () {
        if (AppStrings.currentLanguage == AppLanguage.ru) {
          AppStrings.currentLanguage = AppLanguage.uz;
        } else if (AppStrings.currentLanguage == AppLanguage.uz) {
          AppStrings.currentLanguage = AppLanguage.en;
        } else {
          AppStrings.currentLanguage = AppLanguage.ru;
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            const Icon(Icons.language_rounded, size: 18, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
            ),
          ],
        ),
      ),
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
          if (index >= _stories.length) return const SizedBox.shrink();
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
                    child: story.previewImage.isNotEmpty
                        ? Image.network(
                            UrlUtil.sanitize(story.previewImage),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: AppColors.surface,
                              child: const Icon(Icons.star, color: AppColors.primary, size: 24),
                            ),
                          )
                        : Container(
                            color: AppColors.surface,
                            child: const Icon(Icons.star, color: AppColors.primary, size: 24),
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
    final String baseUrl = 'https://raw.githubusercontent.com/filippofilip95/car-logos-dataset/master/logos/optimized';
    final brands = [
      {'name': 'BMW', 'slug': 'bmw'},
      {'name': 'Mercedes', 'slug': 'mercedes-benz'},
      {'name': 'Audi', 'slug': 'audi'},
      {'name': 'Toyota', 'slug': 'toyota'},
      {'name': 'Lexus', 'slug': 'lexus'},
      {'name': 'BYD', 'slug': 'byd'},
      {'name': 'Honda', 'slug': 'honda'},
      {'name': 'Porsche', 'slug': 'porsche'},
      {'name': 'Tesla', 'slug': 'tesla'},
      {'name': 'Hyundai', 'slug': 'hyundai'},
    ];

    return SizedBox(
      height: 135,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: brands.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (_, index) {
          final brand = brands[index];
          final logoUrl = '$baseUrl/${brand['slug']}.png';
          
          return GestureDetector(
            onTap: () {
              // TODO: Navigate to catalog with brand filter
            },
            child: Container(
              width: 110,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 65,
                    height: 65,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(6),
                    child: Image.network(
                      logoUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(Icons.directions_car, color: AppColors.primary, size: 32),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    brand['name'] as String,
                    style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }



  Widget _buildPromotionalBanner() {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ContactUsScreen())),
      child: Container(
        width: double.infinity,
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/images/office_banner.png',
                fit: BoxFit.cover,
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.black.withOpacity(0.85),
                      Colors.black.withOpacity(0.2),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Поможем найти\nавто мечты',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Приезжайте к нам в офис для\nличной консультации',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Ждем вас в офисе',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
              child: car.photos.isNotEmpty || car.imageUrl != null
                  ? Image.network(
                      UrlUtil.sanitize(car.photos.isNotEmpty ? car.photos[0] : car.imageUrl!),
                      width: 100, height: 100, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(width: 100, height: 100, color: AppColors.darkGrey, child: const Icon(Icons.directions_car, color: AppColors.grey)),
                    )
                  : Container(width: 100, height: 100, color: AppColors.darkGrey, child: const Icon(Icons.directions_car, color: AppColors.grey)),
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
