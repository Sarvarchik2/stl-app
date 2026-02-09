import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:stl_app/core/di/service_locator.dart';
import 'package:stl_app/features/applications/data/repositories/application_repository.dart';
import 'package:stl_app/core/app_colors.dart';
import 'package:stl_app/features/catalog/data/models/car_model.dart';
import 'package:stl_app/core/widgets/top_notification.dart';
import 'package:stl_app/core/utils/url_util.dart';

class CarDetailScreen extends StatelessWidget {
  final CarModel car;
  final String heroTag;

  const CarDetailScreen({
    super.key,
    required this.car,
    required this.heroTag,
  });

  Future<void> _submitApplication(BuildContext context) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );

      await sl<ApplicationRepository>().createApplication(carId: car.id);

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
  Widget build(BuildContext context) {
    final String priceText = '${car.finalPriceUsd} \$';
    final String carName = '${car.make} ${car.model}';

    return Scaffold(
      body: Stack(
        children: [
          // Content
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Car Image Header
                Stack(
                  children: [
                    Container(
                      height: 350,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: (car.imageUrl != null && car.imageUrl!.isNotEmpty)
                              ? NetworkImage(UrlUtil.sanitize(car.imageUrl!))
                              : const AssetImage('assets/images/car_placeholder.png') as ImageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Container(
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
                    Positioned(
                      bottom: 24,
                      left: 20,
                      right: 20,
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
                          _buildTag('${car.year}'),
                          if (car.fuelType != null) ...[
                            const SizedBox(width: 8),
                            _buildTag(car.fuelType!),
                          ],
                          if (car.bodyType != null) ...[
                            const SizedBox(width: 8),
                            _buildTag(car.bodyType!),
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
                              Expanded(child: _buildSpecItem('Пробег', '${car.mileage ?? 0} миль')),
                              const SizedBox(width: 12),
                              Expanded(child: _buildSpecItem('Двигатель', car.engine ?? 'N/A')),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: _buildSpecItem('Трансмиссия', car.transmission ?? 'N/A')),
                              const SizedBox(width: 12),
                              Expanded(child: _buildSpecItem('Привод', car.drivetrain ?? 'N/A')),
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
                            if (car.sourcePriceUsd != null)
                              _buildPriceRow('Цена на аукционе', '${car.sourcePriceUsd} \$', isOld: true),
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
                      if (car.features.isNotEmpty) ...[
                        const Text('Особенности', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        ...car.features.map((feature) => _buildServiceItem(feature)).toList(),
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
