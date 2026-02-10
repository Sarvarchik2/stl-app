import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:stl_app/core/di/service_locator.dart';
import 'package:stl_app/features/applications/data/repositories/application_repository.dart';
import 'package:stl_app/core/app_colors.dart';
import 'package:stl_app/features/catalog/data/models/car_model.dart';
import 'package:stl_app/core/widgets/top_notification.dart';
import 'package:stl_app/core/utils/url_util.dart';

class CarDetailScreen extends StatefulWidget {
  final CarModel car;
  final String heroTag;

  const CarDetailScreen({
    super.key,
    required this.car,
    required this.heroTag,
  });

  @override
  State<CarDetailScreen> createState() => _CarDetailScreenState();
}

class _CarDetailScreenState extends State<CarDetailScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  Future<void> _submitApplication(BuildContext context) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );

      await sl<ApplicationRepository>().createApplication(carId: widget.car.id);

      if (context.mounted) {
        Navigator.pop(context); // Close loading
        TopNotification.show(
          context,
          message: 'Заявка успешно создана! Наш менеджер свяжется с вами.',
        );
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context); // Close loading
      
      String message = 'Ошибка при создании заявки';
      if (e is DioException) {
        message = e.response?.data?['detail'] ?? message;
      }
      
      if (context.mounted) {
        TopNotification.show(
          context,
          message: message,
          isError: true,
        );
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String priceText = '${widget.car.finalPriceUsd} \$';
    final String carName = '${widget.car.make} ${widget.car.model}';
    final List<String> images = widget.car.photos.isNotEmpty 
        ? widget.car.photos 
        : (widget.car.imageUrl != null ? [widget.car.imageUrl!] : []);

    return Scaffold(
      body: Stack(
        children: [
          // Content
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Car Image Header (Slider)
                Stack(
                  children: [
                    SizedBox(
                      height: 350,
                      width: double.infinity,
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (int page) {
                          setState(() {
                            _currentPage = page;
                          });
                        },
                        itemCount: images.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () => _openFullScreenGallery(images, index),
                            child: Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(UrlUtil.sanitize(images[index])),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // Allow gestures to pass through decorative elements
                    IgnorePointer(
                      child: Container(
                        height: 350,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.4),
                              Colors.transparent,
                              Colors.black.withOpacity(0.8),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Dot Indicators
                    if (images.length > 1)
                      Positioned(
                        bottom: 80,
                        left: 0,
                        right: 0,
                        child: IgnorePointer(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              images.length,
                              (index) => AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                height: 6,
                                width: _currentPage == index ? 24 : 6,
                                decoration: BoxDecoration(
                                  color: _currentPage == index 
                                      ? AppColors.primary 
                                      : Colors.white.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      bottom: 24,
                      left: 20,
                      right: 20,
                      child: IgnorePointer(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              carName,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 4,
                              width: 100,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                
                Padding(
                  padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tags
          Row(
            children: [
              _buildTag('${widget.car.year}'),
              if (widget.car.fuelType != null) ...[
                const SizedBox(width: 8),
                _buildTag(widget.car.fuelType!),
              ],
              if (widget.car.bodyType != null) ...[
                const SizedBox(width: 8),
                _buildTag(widget.car.bodyType!),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                CircleAvatar(radius: 3, backgroundColor: Colors.orange),
                SizedBox(width: 8),
                Text('Под заказ', style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Specs Grid
          Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildSpecItem('Пробег', '${widget.car.mileage ?? 0} миль')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildSpecItem('Двигатель', widget.car.engine ?? 'N/A')),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildSpecItem('Трансмиссия', widget.car.transmission ?? 'N/A')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildSpecItem('Привод', widget.car.drivetrain ?? 'N/A')),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Price Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                if (widget.car.sourcePriceUsd != null)
                  _buildPriceRow('Цена на аукционе', '${widget.car.sourcePriceUsd} \$', isOld: true),
                const SizedBox(height: 12),
                _buildPriceRow('Услуги и доставка', 'Включено', isDiscount: true),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(color: Colors.white10),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Полная цена:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(
                      priceText,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Features
          if (widget.car.features.isNotEmpty) ...[
            const Text('Особенности', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...widget.car.features.map((feature) => _buildServiceItem(feature)).toList(),
            const SizedBox(height: 32),
          ],
                      
                      // What's included
                      const Text('Что входит в услугу', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      _buildServiceItem('Полное юридическое сопровождение'),
                      _buildServiceItem('Доставка до вашего города'),
                      _buildServiceItem('Страхование груза'),
                      _buildServiceItem('Помощь в оформлении документов'),
                      _buildServiceItem('Гарантия возврата при несоответствии'),
                      
                      const SizedBox(height: 32),
                      
                      // Note
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
                      
                      const SizedBox(height: 100), // Bottom padding for button
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Custom Back Button
          Positioned(
            top: 50,
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 24),
              ),
            ),
          ),
          
          // Bottom Action Button
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () => _submitApplication(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.description_outlined, size: 20),
                  SizedBox(width: 12),
                  Text('Создать заявку', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openFullScreenGallery(List<String> images, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImageViewer(
          images: images,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  Widget _buildTag(String text) {
    return Text(
      '${text}  •  ',
      style: const TextStyle(color: AppColors.grey, fontSize: 14),
    );
  }

  Widget _buildSpecItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label, 
            style: const TextStyle(color: AppColors.grey, fontSize: 11),
            maxLines: 1,
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value, 
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isOld = false, bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 14)),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            decoration: isOld ? TextDecoration.lineThrough : null,
            color: isDiscount ? AppColors.primary : (isOld ? AppColors.grey : Colors.white),
          ),
        ),
      ],
    );
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

class FullScreenImageViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const FullScreenImageViewer({
    super.key,
    required this.images,
    required this.initialIndex,
  });

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemCount: widget.images.length,
            itemBuilder: (context, index) {
              return InteractiveViewer(
                minScale: 1.0,
                maxScale: 4.0,
                child: Center(
                  child: Image.network(
                    UrlUtil.sanitize(widget.images[index]),
                    fit: BoxFit.contain,
                    width: double.infinity,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                    },
                  ),
                ),
              );
            },
          ),
          // Back button
          Positioned(
            top: 50,
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
              ),
            ),
          ),
          // Counter
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_currentIndex + 1} / ${widget.images.length}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
