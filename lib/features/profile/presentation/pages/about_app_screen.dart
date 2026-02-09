import 'package:flutter/material.dart';
import '../../../../core/app_colors.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('О приложении'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // App Logo
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.local_shipping,
                size: 64,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'STL LOGISTICS & AUTO',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Версия 1.0.0 (build 142)',
              style: TextStyle(color: AppColors.grey),
            ),
            const SizedBox(height: 48),
            
            _buildInfoCard(
              'Наша миссия',
              'Мы обеспечиваем прозрачный и надежный процесс покупки автомобилей со всего мира. Наша цель - сделать логистику простой и доступной для каждого жителя Узбекистана.',
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              'Безопасность',
              'Каждая сделка сопровождается юридическим договором. Мы гарантируем сохранность автомобиля на всех этапах транспортировки и полную проверку истории авто.',
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              'Технологии',
              'Наше приложение позволяет вам отслеживать каждый шаг вашей покупки в режиме реального времени. Мы используем передовые системы мониторинга грузов.',
            ),
            
            const SizedBox(height: 48),
            const Text(
              '© 2024 STL Logistics Group.\nВсе права защищены.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.grey, fontSize: 12, height: 1.5),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18, 
              fontWeight: FontWeight.bold, 
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
