import 'package:flutter/material.dart';
import '../../../../core/app_colors.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Часто задаваемые вопросы'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildFaqItem(
              'Как заказать автомобиль?',
              'Выберите интересующий вас автомобиль в каталоге, нажмите кнопку "Оставить заявку". Наш менеджер свяжется с вами для обсуждения деталей.',
            ),
            const SizedBox(height: 12),
            _buildFaqItem(
              'Какие сроки доставки?',
              'В среднем доставка занимает от 30 до 45 дней. Сроки зависят от удаленности порта отправки и погодных условий.',
            ),
            const SizedBox(height: 12),
            _buildFaqItem(
              'Как отследить статус заявки?',
              'Все ваши заявки отображаются на вкладке "Заявки". Там вы можете видеть текущий этап: от покупки на аукционе до прибытия в Ташкент.',
            ),
            const SizedBox(height: 12),
            _buildFaqItem(
              'Какие документы нужны?',
              'Для оформления договора потребуется паспорт и ИНН. Остальные документы (инвойс, техпаспорт) мы подготовим сами.',
            ),
            const SizedBox(height: 12),
            _buildFaqItem(
              'Входит ли растаможка в цену?',
              'В каталоге указана цена за автомобиль с учетом логистики до Ташкента. Таможенные платежи рассчитываются индивидуально.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        shape: const Border(),
        iconColor: AppColors.primary,
        collapsedIconColor: AppColors.grey,
        children: [
          const Divider(color: Colors.white10),
          const SizedBox(height: 8),
          Text(
            answer,
            style: const TextStyle(color: AppColors.grey, height: 1.5),
          ),
        ],
      ),
    );
  }
}
