import 'package:flutter/material.dart';
import 'package:stl_app/core/app_colors.dart';
import 'package:stl_app/core/di/service_locator.dart';
import 'package:stl_app/features/auth/data/models/user_model.dart';
import 'package:stl_app/features/auth/data/repositories/auth_repository.dart';
import 'package:stl_app/features/applications/data/models/application_model.dart';
import 'package:stl_app/features/applications/data/repositories/application_repository.dart';
import 'package:intl/intl.dart';
import 'package:stl_app/core/localization/app_strings.dart';
import 'package:stl_app/core/utils/url_util.dart';
import 'application_detail_screen.dart';

class ApplicationsScreen extends StatefulWidget {
  const ApplicationsScreen({super.key});

  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen> {
  final ApplicationRepository _applicationRepository = sl<ApplicationRepository>();
  final AuthRepository _authRepository = sl<AuthRepository>();
  
  List<ApplicationModel> _applications = [];
  UserModel? _user;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (mounted) setState(() { _isLoading = true; _error = null; });
    try {
      final results = await Future.wait<dynamic>([
        _applicationRepository.getApplications(),
        _authRepository.getMe(),
      ]);
      if (mounted) setState(() { _applications = results[0] as List<ApplicationModel>; _user = results[1] as UserModel?; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  Future<void> _logout() async {
    await _authRepository.logout();
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          color: AppColors.primary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 32),
                      Text(AppStrings.get('my_applications'), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text('Отслеживайте статус в реальном времени', style: TextStyle(color: AppColors.grey)),
                    ],
                  ),
                ),
              ),
              if (_isLoading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                )
              else if (_error != null)
                SliverFillRemaining(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
                          child: const Icon(Icons.lock_person_outlined, size: 48, color: Colors.red),
                        ),
                        const SizedBox(height: 24),
                        const Text('Доступ ограничен', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Text(
                          _error!.contains('403') 
                            ? 'У вас нет разрешения на просмотр этого раздела или сессия устарела.' 
                            : 'Произошла ошибка при загрузке данных.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.grey),
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton.icon(
                              onPressed: _loadData,
                              icon: const Icon(Icons.refresh, color: AppColors.primary),
                              label: const Text('Повторить', style: TextStyle(color: AppColors.primary)),
                            ),
                            const SizedBox(width: 20),
                            TextButton.icon(
                              onPressed: _logout,
                              icon: const Icon(Icons.logout, color: Colors.white70),
                              label: const Text('Выйти', style: TextStyle(color: Colors.white70)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              else if (_applications.isEmpty)
                SliverFillRemaining(
                  child: _buildEmptyState(),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildApplicationItem(_applications[index]),
                      ),
                      childCount: _applications.length,
                    ),
                  ),
                ),
              const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
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
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, Color(0xFFFF8C00)],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: const Icon(Icons.person_rounded, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _user?.fullName ?? 'Клиент',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                _user?.phone ?? '',
                style: const TextStyle(color: AppColors.grey, fontSize: 13),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: AppColors.surface,
                title: const Text('Выход'),
                content: const Text('Вы уверены, что хотите выйти из аккаунта?'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена', style: TextStyle(color: AppColors.grey))),
                  TextButton(onPressed: _logout, child: const Text('Выйти', style: TextStyle(color: Colors.red))),
                ],
              ),
            );
          },
          icon: const Icon(Icons.logout_rounded, color: AppColors.grey),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      key: const ValueKey('applications_empty'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 80),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
            child: Icon(Icons.assignment_outlined, size: 64, color: AppColors.primary.withOpacity(0.5)),
          ),
          const SizedBox(height: 24),
          const Text('У вас пока нет заявок', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          const Text('Выберите авто в каталоге и\nсоздайте свою первую заявку', textAlign: TextAlign.center, style: TextStyle(color: AppColors.grey)),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Найти автомобиль'),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationItem(ApplicationModel app) {
    final statusData = _getStatusData(app.status);
    final dateStr = DateFormat('dd MMM yyyy', 'ru').format(app.createdAt);
    final imageUrl = app.carImageUrl;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ApplicationDetailScreen(application: app),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withOpacity(0.05))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 60, height: 60, decoration: const BoxDecoration(color: AppColors.darkGrey),
                    child: imageUrl != null && imageUrl.isNotEmpty
                        ? Image.network(
                            UrlUtil.sanitize(imageUrl), 
                            fit: BoxFit.cover, 
                            errorBuilder: (_, __, ___) => const Icon(Icons.drive_eta_rounded, color: AppColors.grey),
                          )
                        : const Icon(Icons.drive_eta_rounded, color: AppColors.grey),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${app.carBrand} ${app.carModel}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis), Text('ID: ${app.id.substring(0, 8)}...', style: const TextStyle(fontSize: 12, color: AppColors.grey))])),
                _buildStatusBadge(statusData),
              ],
            ),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Создано: $dateStr', style: const TextStyle(color: AppColors.grey, fontSize: 12)), Text('${app.finalPrice} \$', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary))]),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(Map<String, dynamic> statusData) {
    final color = statusData['color'] as Color;
    return Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Text(statusData['label'], style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)));
  }

  Map<String, dynamic> _getStatusData(String status) {
    switch (status.toUpperCase()) {
      case 'NEW': return {'label': 'Новая', 'color': Colors.blue};
      case 'CONFIRMED': return {'label': 'Подтверждена', 'color': Colors.orange};
      case 'PAID': return {'label': 'Оплачена', 'color': Colors.green};
      case 'SHIPPING': return {'label': 'В пути', 'color': Colors.purple};
      case 'COMPLETED': return {'label': 'Завершена', 'color': Colors.teal};
      case 'CANCELLED': return {'label': 'Отменена', 'color': Colors.red};
      default: return {'label': status, 'color': AppColors.grey};
    }
  }
}
