import 'package:flutter/material.dart';
import 'package:stl_app/core/app_colors.dart';
import 'package:stl_app/core/di/service_locator.dart';
import 'package:stl_app/features/applications/data/models/application_model.dart';
import 'package:stl_app/features/catalog/data/models/car_model.dart';
import 'package:stl_app/features/catalog/data/repositories/catalog_repository.dart';
import 'package:stl_app/core/utils/url_util.dart';
import 'package:intl/intl.dart';

import 'package:url_launcher/url_launcher.dart';

class ApplicationDetailScreen extends StatefulWidget {
  final ApplicationModel application;

  const ApplicationDetailScreen({
    super.key,
    required this.application,
  });

  @override
  State<ApplicationDetailScreen> createState() => _ApplicationDetailScreenState();
}

class _ApplicationDetailScreenState extends State<ApplicationDetailScreen> {
  final CatalogRepository _catalogRepository = sl<CatalogRepository>();
  CarModel? _car;
  bool _isLoading = true;
  String? _error;

  Future<void> _makeCall() async {
    final Uri telUri = Uri.parse('tel:+998900000000');
    if (await canLaunchUrl(telUri)) {
      await launchUrl(telUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось совершить звонок')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCarDetails();
  }

  Future<void> _loadCarDetails() async {
    try {
      final car = await _catalogRepository.getCarById(widget.application.carId);
      if (mounted) {
        setState(() {
          _car = car;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: _isLoading
                ? const Center(child: Padding(padding: EdgeInsets.all(40.0), child: CircularProgressIndicator(color: AppColors.primary)))
                : _error != null
                    ? _buildErrorContent()
                    : _buildMainContent(),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
      bottomSheet: _buildBottomActions(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (widget.application.carImageUrl != null)
              Image.network(
                UrlUtil.sanitize(widget.application.carImageUrl!),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.directions_car, size: 60, color: AppColors.grey),
              )
            else
              const Icon(Icons.directions_car, size: 60, color: AppColors.grey),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    final statusData = _getStatusData(widget.application.status);
    final dateStr = DateFormat('dd MMMM yyyy, HH:mm', 'ru').format(widget.application.createdAt);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.application.carBrand} ${widget.application.carModel}',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Заявка №${widget.application.id.substring(0, 8).toUpperCase()}',
                      style: const TextStyle(color: AppColors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(statusData),
            ],
          ),
          const SizedBox(height: 32),
          
          _buildInfoCard(
            'Информация о заявке',
            [
              _buildInfoRow(Icons.calendar_today_outlined, 'Дата создания', dateStr),
              _buildInfoRow(Icons.payments_outlined, 'Финальная стоимость', '\$${widget.application.finalPrice}'),
              _buildInfoRow(Icons.person_outline, 'Менеджер', 'Назначение в процессе'),
            ],
          ),
          
          const SizedBox(height: 24),
          
          if (_car != null) ...[
            _buildCarDetails(),
            const SizedBox(height: 24),
          ],
          
          _buildContractSection(),
          
          const SizedBox(height: 24),
          
          _buildVideoSection(),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(Map<String, dynamic> statusData) {
    final color = statusData['color'] as Color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        statusData['label'],
        style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.darkGrey, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 12)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarDetails() {
    return _buildInfoCard(
      'Характеристики авто',
      [
        Row(
          children: [
            Expanded(child: _buildSpecItem('Год', '${_car!.year}')),
            const SizedBox(width: 12),
            Expanded(child: _buildSpecItem('Двигатель', _car!.engine ?? 'N/A')),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildSpecItem('Трансмиссия', _car!.transmission ?? 'N/A')),
            const SizedBox(width: 12),
            Expanded(child: _buildSpecItem('Пробег', '${_car!.mileage ?? 0} миль')),
          ],
        ),
        if (_car!.photos.isNotEmpty) ...[
          const SizedBox(height: 20),
          const Text('Фотографии авто', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _car!.photos.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    UrlUtil.sanitize(_car!.photos[index]),
                    width: 150,
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSpecItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.darkGrey,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 11)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildContractSection() {
    return _buildInfoCard(
      'Документы',
      [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.darkGrey,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(Icons.description_outlined, color: AppColors.primary, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Договор купли-продажи', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('PDF • 2.4 MB', style: TextStyle(color: AppColors.grey, fontSize: 12)),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Загрузка договора начнется через мгновение')),
                  );
                },
                icon: const Icon(Icons.download_rounded, color: AppColors.primary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVideoSection() {
    return _buildInfoCard(
      'Видео осмотра',
      [
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: AppColors.darkGrey,
            borderRadius: BorderRadius.circular(20),
            image: const DecorationImage(
              image: NetworkImage('https://img.youtube.com/vi/placeholder/0.jpg'),
              fit: BoxFit.cover,
              opacity: 0.5,
            ),
          ),
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.8),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 32),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Видео-отчет процесса осмотра и погрузки автомобиля',
          style: TextStyle(color: AppColors.grey, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _makeCall,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkGrey,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Позвонить менеджеру'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorContent() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(_error ?? 'Ошибка при загрузке данных'),
          TextButton(onPressed: _loadCarDetails, child: const Text('Повторить')),
        ],
      ),
    );
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
