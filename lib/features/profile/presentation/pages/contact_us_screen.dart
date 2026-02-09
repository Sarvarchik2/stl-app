import 'package:flutter/material.dart';
import '../../../../core/app_colors.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Связаться с нами'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Мы всегда на связи',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Выберите удобный способ связи или посетите наш офис',
              style: TextStyle(color: AppColors.grey),
            ),
            const SizedBox(height: 32),
            
            // Social Networks
            const Text('Социальные сети', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSocialIcon(Icons.telegram, 'Telegram', Colors.blue),
                _buildSocialIcon(Icons.camera_alt, 'Instagram', Colors.purple),
                _buildSocialIcon(Icons.facebook, 'Facebook', Colors.blueAccent),
                _buildSocialIcon(Icons.video_collection, 'YouTube', Colors.red),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Contacts
            const Text('Контакты', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildContactItem(Icons.phone_outlined, 'Телефон', '+998 90 123 45 67'),
            const SizedBox(height: 12),
            _buildContactItem(Icons.email_outlined, 'Email', 'info@stl-logistics.uz'),
            const SizedBox(height: 12),
            _buildContactItem(Icons.access_time_outlined, 'Режим работы', 'Пн-Сб: 09:00 - 18:00'),
            
            const SizedBox(height: 32),
            
            // Location
            const Text('Наш адрес', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, color: AppColors.primary),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Узбекистан, г. Ташкент, Мирзо-Улугбекский р-н, ул. Кашгар, 15',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Mock Map Frame
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.darkGrey,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Stack(
                      children: [
                        // Stylized Grid/Background for map
                        Opacity(
                          opacity: 0.1,
                          child: GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 6),
                            itemBuilder: (context, index) => Container(decoration: BoxDecoration(border: Border.all(color: Colors.white))),
                          ),
                        ),
                        const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.location_on, color: Colors.orange, size: 48),
                              SizedBox(height: 8),
                              Text('Нажмите, чтобы открыть на карте', style: TextStyle(color: Colors.white54, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 30),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.grey)),
      ],
    );
  }

  Widget _buildContactItem(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: AppColors.grey, fontSize: 12)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }
}
