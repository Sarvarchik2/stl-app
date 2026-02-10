import 'package:flutter/material.dart';
import 'package:stl_app/core/app_colors.dart';
import 'package:stl_app/core/di/service_locator.dart';
import 'package:stl_app/features/applications/data/models/application_model.dart';
import 'package:stl_app/features/catalog/data/models/car_model.dart';
import 'package:stl_app/features/catalog/data/repositories/catalog_repository.dart';
import 'package:stl_app/core/utils/url_util.dart';
import 'package:intl/intl.dart';

import 'package:stl_app/features/applications/presentation/widgets/pdf_viewer_screen.dart';
import 'package:stl_app/features/applications/presentation/widgets/video_player_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stl_app/features/applications/data/repositories/application_repository.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final ApplicationRepository _applicationRepository = sl<ApplicationRepository>();
  
  late ApplicationModel _application;
  CarModel? _car;
  bool _isCarLoading = true;
  bool _isAppLoading = true;
  String? _error;

  Future<void> _makeCall() async {
    try {
      final Uri telUri = Uri.parse('tel:+998900000000');
      debugPrint('Calling: $telUri');
      if (!await launchUrl(telUri)) {
        throw 'Could not launch call';
      }
    } catch (e) {
      debugPrint('Error making call: $e');
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
    _application = widget.application;
    _loadAllDetails();
  }

  Future<void> _loadAllDetails() async {
    setState(() {
      _isCarLoading = true;
      _isAppLoading = true;
      _error = null;
    });

    try {
      // Load both in parallel
      await Future.wait([
        _loadApplicationDetails(),
        _loadCarDetails(),
      ]);
    } catch (e) {
      // Errors are handled inside individual methods
    }
  }

  Future<void> _loadApplicationDetails() async {
    try {
      final app = await _applicationRepository.getApplicationById(_application.id);
      if (mounted) {
        setState(() {
          _application = app;
          _isAppLoading = false;
        });
      }
    } catch (e) {
      // If server fails (e.g. 500 error), we use the data we already have from the list
      // ignoring the error to show at least what we have
      debugPrint('Error loading app details: $e');
      if (mounted) {
        setState(() {
          _isAppLoading = false;
        });
      }
    }
  }

  Future<void> _loadCarDetails() async {
    try {
      final car = await _catalogRepository.getCarById(_application.carId);
      if (mounted) {
        setState(() {
          _car = car;
          _isCarLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCarLoading = false;
          // If we can't load car specs, it's not fatal for the whole screen
        });
      }
      debugPrint('Error loading car details: $e');
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
            child: _buildMainContent(),
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
            if (_application.carImageUrl != null)
              Image.network(
                UrlUtil.sanitize(_application.carImageUrl!),
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
    final statusData = _getStatusData(_application.status);
    final dateStr = DateFormat('dd MMMM yyyy, HH:mm', 'ru').format(_application.createdAt);

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
                      '${_application.carBrand} ${_application.carModel}',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Заявка №${_application.id.substring(0, 8).toUpperCase()}',
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
              _buildInfoRow(Icons.payments_outlined, 'Финальная стоимость', '\$${_application.finalPrice}'),
              _buildInfoRow(Icons.person_outline, 'Менеджер', 'Назначение в процессе'),
            ],
          ),
          
          const SizedBox(height: 24),

          // Show documents ASAP
          if (_isAppLoading)
            const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2)))
          else ...[
            _buildContractSection(),
            const SizedBox(height: 24),
            _buildVideoSection(),
            const SizedBox(height: 24),
          ],
          
          if (_isCarLoading)
            _buildLoadingCard('Характеристики авто')
          else if (_car != null) ...[
            _buildCarDetails(),
            const SizedBox(height: 24),
          ],
          
          _buildStaticServiceInfo(),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildLoadingCard(String title) {
    return _buildInfoCard(
      title,
      [
        const Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
          ),
        ),
      ],
    );
  }

  Widget _buildStaticServiceInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Что входит в услугу', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildServiceItem('Полное юридическое сопровождение'),
        _buildServiceItem('Доставка до вашего города'),
        _buildServiceItem('Страхование груза'),
        _buildServiceItem('Помощь в оформлении документов'),
        _buildServiceItem('Гарантия возврата при несоответствии'),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Все автомобили проходят тщательную проверку перед покупкой на аукционе.',
                  style: TextStyle(color: AppColors.grey, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ],
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

  // Helper: Download file with Dialog
  Future<File?> _downloadFileWithProgress(String url, String filename) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: AppColors.darkGrey,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 16),
              Text(
                'Загрузка ${filename}...',
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      final headers = token != null ? {'Authorization': 'Bearer $token'} : <String, String>{};

      final response = await http.get(Uri.parse(url), headers: headers);
      
      // Close dialog
      if (mounted) Navigator.of(context).pop();

      if (response.statusCode != 200) {
        throw 'Ошибка сервера: ${response.statusCode}';
      }

      final bytes = response.bodyBytes;
      final tempDir = await getTemporaryDirectory();
      final path = '${tempDir.path}/${filename}';
      final file = File(path);
      await file.writeAsBytes(bytes);
      
      return file;
    } catch (e) {
      // Close dialog if error
      if (mounted && Navigator.canPop(context)) Navigator.of(context).pop();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      }
      return null;
    }
  }

  // 1. Download & Share
  Future<void> _downloadDocument(DocumentModel doc) async {
    final file = await _downloadFileWithProgress(doc.downloadUrl, doc.filename);
    if (file != null && mounted) {
      await Share.shareXFiles([XFile(file.path)], text: 'Скачать ${doc.filename}');
    }
  }

  // 2. Preview Video (Download first, then play local file)
  Future<void> _previewVideo(DocumentModel doc) async {
    // We download video first to avoid streaming issues with auth/headers on iOS
    final file = await _downloadFileWithProgress(doc.downloadUrl, doc.filename);
    
    if (file != null && mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => VideoPlayerScreen(
            url: file.path,  // Pass LOCAL path
            filename: doc.filename,
            // Header is not needed for local file
          ),
        ),
      );
    }
  }

  Widget _buildContractSection() {
    final contract = _application.documents
        .where((d) => d.type.toLowerCase() == 'contract')
        .firstOrNull;
    
    if (contract == null) return const SizedBox.shrink();

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
                  children: [
                    Text(contract.filename, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text('PDF • ${contract.fileSize.isNotEmpty ? contract.fileSize : "Документ"}', style: const TextStyle(color: AppColors.grey, fontSize: 12)),
                  ],
                ),
              ),
              // Download Button for Contract
              IconButton(
                onPressed: () => _downloadDocument(contract),
                icon: const Icon(Icons.download_rounded, color: AppColors.primary),
                tooltip: 'Скачать',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVideoSection() {
    final video = _application.documents
        .where((d) {
          final type = d.type.toLowerCase();
          return type == 'video_signature' || type == 'video_report';
        })
        .firstOrNull;
    
    if (video == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Видео осмотра',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        // Preview Area (Click to Play)
        GestureDetector(
          onTap: () => _previewVideo(video),
          child: Container(
            height: 180,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(16),
              image: _application.carImageUrl != null
                ? DecorationImage(
                    image: NetworkImage(UrlUtil.sanitize(_application.carImageUrl!)),
                    fit: BoxFit.cover,
                    opacity: 0.3,
                  )
                : null,
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
        ),
        const SizedBox(height: 12),
        // Info Row with Download Button
        Row(
          children: [
            Expanded(
              child: Text(
                'Видео-отчет: ${video.filename}',
                style: const TextStyle(color: AppColors.grey, fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              onPressed: () => _downloadDocument(video),
              icon: const Icon(Icons.download_rounded, color: AppColors.grey),
              tooltip: 'Скачать видео',
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(8),
            ),
          ],
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

  Widget _buildServiceItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const Icon(Icons.check_rounded, color: Colors.green, size: 18),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 14))),
        ],
      ),
    );
  }
}
