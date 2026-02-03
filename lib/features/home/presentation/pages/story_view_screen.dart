import 'package:flutter/material.dart';
import 'dart:async';
import '../../../../core/app_colors.dart';

class StoryViewScreen extends StatefulWidget {
  final String title;
  final int initialIndex;

  const StoryViewScreen({
    super.key,
    required this.title,
    this.initialIndex = 0,
  });

  @override
  State<StoryViewScreen> createState() => _StoryViewScreenState();
}

class _StoryViewScreenState extends State<StoryViewScreen> {
  late PageController _pageController;
  int _currentIndex = 0;
  Timer? _timer;
  double _progress = 0.0;

  final List<Map<String, dynamic>> _stories = [
    {
      'title': 'Важно',
      'content': 'Специальное предложение!\n\nПолучите скидку до 15% на доставку авто из США при оформлении заявки до конца месяца.',
      'icon': Icons.star_rounded,
      'color': AppColors.primary,
    },
    {
      'title': 'О нас',
      'content': 'STL Logistics - ваш надежный партнер в импорте автомобилей из США.\n\n✓ Более 500 довольных клиентов\n✓ Работаем с 2018 года\n✓ Полное юридическое сопровождение',
      'icon': Icons.info_outline,
      'color': Colors.blue,
    },
    {
      'title': 'Доставка',
      'content': 'Быстрая доставка из США\n\n🚢 Морская доставка: 30-45 дней\n✈️ Авиа доставка: 7-10 дней\n📦 Полное страхование груза\n🔒 Отслеживание в реальном времени',
      'icon': Icons.local_shipping_outlined,
      'color': Colors.green,
    },
    {
      'title': 'Отзывы',
      'content': '⭐️⭐️⭐️⭐️⭐️\n\n"Отличный сервис! Привезли Tesla Model 3 за 35 дней. Все документы оформили быстро."\n\n- Азиз М., Ташкент',
      'icon': Icons.reviews_outlined,
      'color': Colors.amber,
    },
    {
      'title': 'Гарантия',
      'content': 'Наши гарантии:\n\n✓ Возврат средств при несоответствии\n✓ Проверка авто перед отправкой\n✓ Юридическая чистота\n✓ Помощь в растаможке\n✓ Послепродажная поддержка',
      'icon': Icons.verified_user_outlined,
      'color': Colors.purple,
    },
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _startTimer();
  }

  void _startTimer() {
    _progress = 0.0;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _progress += 0.01;
        if (_progress >= 1.0) {
          _nextStory();
        }
      });
    });
  }

  void _nextStory() {
    if (_currentIndex < _stories.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _previousStory() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (details) {
          final width = MediaQuery.of(context).size.width;
          if (details.globalPosition.dx < width / 2) {
            _previousStory();
          } else {
            _nextStory();
          }
        },
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
                _startTimer();
              },
              itemCount: _stories.length,
              itemBuilder: (context, index) {
                final story = _stories[index];
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        story['color'].withOpacity(0.3),
                        Colors.black,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 60),
                          Icon(
                            story['icon'],
                            size: 80,
                            color: story['color'],
                          ),
                          const SizedBox(height: 32),
                          Text(
                            story['title'],
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            story['content'],
                            style: const TextStyle(
                              fontSize: 18,
                              height: 1.6,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            
            // Progress bars at top
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: List.generate(_stories.length, (index) {
                    return Expanded(
                      child: Container(
                        height: 3,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: index == _currentIndex
                              ? _progress
                              : (index < _currentIndex ? 1.0 : 0.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            
            // Close button
            SafeArea(
              child: Positioned(
                top: 16,
                right: 16,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
