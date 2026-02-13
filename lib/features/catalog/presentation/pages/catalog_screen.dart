import 'dart:async';
import 'package:flutter/material.dart';
import 'package:stl_app/core/app_colors.dart';
import 'package:stl_app/core/di/service_locator.dart';
import 'package:stl_app/features/catalog/data/models/car_model.dart';
import 'package:stl_app/features/catalog/data/repositories/catalog_repository.dart';
import 'package:stl_app/features/auth/data/models/user_model.dart';
import 'package:stl_app/features/auth/data/repositories/auth_repository.dart';
import 'package:stl_app/core/localization/app_strings.dart';
import 'package:stl_app/core/utils/url_util.dart';
import 'package:stl_app/features/catalog/data/repositories/favorites_repository.dart';
import 'car_detail_screen.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final CatalogRepository _catalogRepository = sl<CatalogRepository>();
  final AuthRepository _authRepository = sl<AuthRepository>();
  final FavoritesRepository _favoritesRepository = sl<FavoritesRepository>();
  
  List<CarModel> _cars = [];
  UserModel? _user;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 1;
  int _totalCars = 0;
  static const int _perPage = 20;
  
  String? _error;
  Timer? _debounce;
  
  // Filters
  String? _selectedBrand;
  String? _selectedBodyType;
  RangeValues _priceRange = const RangeValues(0, 100000);
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<String> _brands = ['Chevrolet', 'Hyundai', 'KIA', 'BMW', 'Mercedes', 'Audi', 'Toyota', 'Honda', 'BYD', 'Lexus', 'Porsche', 'Tesla', 'Ford', 'GMC'];
  final List<String> _bodyTypes = ['Седан', 'Кроссовер', 'Хэтчбек', 'Универсал', 'Купе', 'Минивэн'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
    _loadData();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _hasMore && !_isLoading) {
        _loadMoreCars();
      }
    }
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _loadCars(isRefresh: true);
    });
  }

  Future<void> _loadData() async {
    _loadProfile();
    await _loadCars();
  }

  Future<void> _loadProfile() async {
    try {
      final user = await _authRepository.getMe();
      if (mounted) setState(() => _user = user);
    } catch (_) {}
  }

  Future<void> _loadCars({bool isRefresh = true}) async {
    if (!mounted) return;
    
    if (isRefresh) {
      setState(() {
        _isLoading = true;
        _error = null;
        _currentPage = 1;
        _hasMore = true;
      });
    }

    try {
      final response = await _catalogRepository.getCars(
        search: _searchController.text.isNotEmpty ? _searchController.text : null,
        make: _selectedBrand,
        page: _currentPage,
        perPage: _perPage,
      );

      final cars = response.items;
      if (mounted) {
        setState(() {
          if (isRefresh) {
            _cars = cars;
          } else {
            _cars.addAll(cars);
          }
          _totalCars = response.total;
          _isLoading = false;
          _isLoadingMore = false;
          _hasMore = cars.length >= _perPage;
          _currentPage++;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  Future<void> _loadMoreCars() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);
    await _loadCars(isRefresh: false);
  }

  void _filterCars() {
    _loadCars(isRefresh: true);
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildFilterSheet(),
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedBrand = null;
      _selectedBodyType = null;
      _priceRange = const RangeValues(0, 100000);
      _searchController.clear();
    });
    _loadCars(isRefresh: true);
  }

  bool get _hasActiveFilters {
    return _selectedBrand != null || 
        _selectedBodyType != null || 
        _priceRange.start > 0 || 
        _priceRange.end < 100000;
  }

  bool get _isSearchingOrFiltering => 
      (_searchController.text.isNotEmpty) || 
      (_selectedBrand != null) || 
      (_selectedBodyType != null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header with Search
            _buildHeader(),
            
            // Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadCars,
                color: AppColors.primary,
                child: _isLoading
                    ? const SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        child: Center(
                            child: Padding(
                          padding: EdgeInsets.all(80.0),
                          child: CircularProgressIndicator(color: AppColors.primary),
                        )),
                      )
                    : _error != null
                        ? _buildErrorState()
                        : _cars.isEmpty
                            ? _buildEmptyState()
                            : _buildCarsList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.get('catalog'),
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isSearchingOrFiltering 
                        ? 'Найдено $_totalCars автомобилей'
                        : '$_totalCars автомобилей',
                    style: const TextStyle(color: AppColors.grey, fontSize: 14),
                  ),
                ],
              ),
              Row(
                children: [
                  if (_hasActiveFilters)
                    GestureDetector(
                      onTap: _clearFilters,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.close, size: 16, color: Colors.red),
                            SizedBox(width: 4),
                            Text('Сброс', style: TextStyle(color: Colors.red, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Search Bar
          SizedBox(
            height: 56,
            child: Row(
              children: [
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: _searchFocusNode.hasFocus 
                            ? AppColors.primary.withOpacity(0.5) 
                            : Colors.white.withOpacity(0.05),
                        width: 1.5,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        Icon(
                          Icons.search_rounded, 
                          color: _searchFocusNode.hasFocus ? AppColors.primary : AppColors.grey, 
                          size: 20
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            focusNode: _searchFocusNode,
                            style: const TextStyle(color: Colors.white, fontSize: 15),
                            cursorColor: AppColors.primary,
                            decoration: InputDecoration(
                              hintText: 'Поиск по марке, модели...',
                              hintStyle: TextStyle(
                                color: AppColors.grey.withOpacity(0.4), 
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            textAlignVertical: TextAlignVertical.center,
                            onChanged: (_) => setState(() {}),
                            onTap: () => setState(() {}),
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: IconButton(
                              icon: const Icon(Icons.cancel_rounded, color: AppColors.grey, size: 20),
                              onPressed: () {
                                _searchController.clear();
                                _filterCars();
                                setState(() {});
                              },
                              splashRadius: 20,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _showFilterSheet,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.primary, Color(0xFFFF8C00)],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(Icons.tune_rounded, color: Colors.white, size: 24),
                        if (_hasActiveFilters)
                          Positioned(
                            right: 14,
                            top: 14,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.primary, width: 2),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Quick Filters
          if (!_isLoading && _cars.isNotEmpty) ...[
            const SizedBox(height: 16),
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildQuickFilterChip('Все', _selectedBrand == null && _selectedBodyType == null, () {
                    setState(() {
                      _selectedBrand = null;
                      _selectedBodyType = null;
                    });
                    _filterCars();
                  }),
                  const SizedBox(width: 8),
                  ..._brands.map((brand) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildQuickFilterChip(brand, _selectedBrand == brand, () {
                      setState(() => _selectedBrand = _selectedBrand == brand ? null : brand);
                      _filterCars();
                    }),
                  )),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.grey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.withOpacity(0.5)),
            const SizedBox(height: 16),
            const Text('Ошибка загрузки', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(_error ?? '', style: const TextStyle(color: AppColors.grey), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadCars,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Повторить'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.search_off_rounded, size: 48, color: AppColors.grey.withOpacity(0.5)),
            ),
            const SizedBox(height: 24),
            const Text('Ничего не найдено', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              'Попробуйте изменить параметры поиска\nили сбросить фильтры',
              style: TextStyle(color: AppColors.grey),
              textAlign: TextAlign.center,
            ),
            if (_hasActiveFilters) ...[
              const SizedBox(height: 24),
              TextButton.icon(
                onPressed: _clearFilters,
                icon: const Icon(Icons.refresh, color: AppColors.primary),
                label: const Text('Сбросить фильтры', style: TextStyle(color: AppColors.primary)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCarsList() {
    final itemCount = _cars.length + (_isLoadingMore ? 1 : 0);
    return ListView.builder(
      controller: _scrollController,
      key: const PageStorageKey('catalog_list'),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index == _cars.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }
        
        final car = _cars[index];
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 400),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: child,
              ),
            );
          },
          child: _buildCarCard(car),
        );
      },
    );
  }

  Widget _buildCarCard(CarModel car) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context, 
          MaterialPageRoute(builder: (context) => CarDetailScreen(car: car, heroTag: 'car_${car.id}')),
        );
        setState(() {}); // Refresh favorite icons state when back
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: Image.network(
                    car.photos.isNotEmpty ? UrlUtil.sanitize(car.photos[0]) : (car.imageUrl != null ? UrlUtil.sanitize(car.imageUrl!) : ''),
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 200,
                      width: double.infinity,
                      color: AppColors.darkGrey,
                      child: const Icon(Icons.directions_car, size: 64, color: AppColors.grey),
                    ),
                  ),
                ),
                // Year badge
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      car.year.toString(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ),
                // Favorite button
                Positioned(
                  top: 16,
                  right: 16,
                  child: GestureDetector(
                    onTap: () {
                      _favoritesRepository.toggleFavorite(car);
                      setState(() {});
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _favoritesRepository.isFavorite(car.id) ? Icons.favorite : Icons.favorite_border, 
                        color: _favoritesRepository.isFavorite(car.id) ? AppColors.primary : Colors.white, 
                        size: 20
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            // Info
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${car.brand} ${car.model}',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.location_on_outlined, size: 14, color: AppColors.grey.withOpacity(0.7)),
                                const SizedBox(width: 4),
                                Text(
                                  'США, Аукцион',
                                  style: TextStyle(color: AppColors.grey.withOpacity(0.7), fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '\$${car.finalPriceUsd}',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Tags
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (car.engine != null) _buildTag(Icons.speed, car.engine!),
                      if (car.transmission != null) _buildTag(Icons.settings, car.transmission!),
                      if (car.drivetrain != null) _buildTag(Icons.all_inclusive, car.drivetrain!),
                      if (car.mileage != null) _buildTag(Icons.route, '${car.mileage} mi'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.darkGrey,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.grey),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildFilterSheet() {
    return StatefulBuilder(
      builder: (context, setSheetState) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Фильтры', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    TextButton(
                      onPressed: () {
                        setSheetState(() {
                          _selectedBrand = null;
                          _selectedBodyType = null;
                          _priceRange = const RangeValues(0, 100000);
                        });
                      },
                      child: const Text('Сбросить', style: TextStyle(color: AppColors.primary)),
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    // Brand
                    const Text('Марка', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _brands.map((brand) {
                        final isSelected = _selectedBrand == brand;
                        return GestureDetector(
                          onTap: () => setSheetState(() => _selectedBrand = isSelected ? null : brand),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: isSelected ? AppColors.primary : Colors.white10),
                            ),
                            child: Text(
                              brand,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.white70,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    
                    const SizedBox(height: 28),
                    
                    // Body Type
                    const Text('Тип кузова', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _bodyTypes.map((type) {
                        final isSelected = _selectedBodyType == type;
                        return GestureDetector(
                          onTap: () => setSheetState(() => _selectedBodyType = isSelected ? null : type),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: isSelected ? AppColors.primary : Colors.white10),
                            ),
                            child: Text(
                              type,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.white70,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    
                    const SizedBox(height: 28),
                    
                    // Price Range
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Цена', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(
                          '\$${_priceRange.start.round()} - \$${_priceRange.end.round()}',
                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: AppColors.primary,
                        inactiveTrackColor: AppColors.surface,
                        thumbColor: AppColors.primary,
                        overlayColor: AppColors.primary.withOpacity(0.2),
                        rangeThumbShape: const RoundRangeSliderThumbShape(enabledThumbRadius: 10),
                      ),
                      child: RangeSlider(
                        values: _priceRange,
                        min: 0,
                        max: 100000,
                        divisions: 100,
                        onChanged: (values) => setSheetState(() => _priceRange = values),
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
              
              // Apply Button
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {});
                        _filterCars();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text(
                        'Применить фильтры',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
