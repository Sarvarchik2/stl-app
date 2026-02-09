import 'package:flutter/material.dart';

class StoryProgressBarPainter extends CustomPainter {
  final int slideCount;
  final int currentIndex;
  final double progress;
  final double spacing;

  StoryProgressBarPainter({
    required this.slideCount,
    required this.currentIndex,
    required this.progress,
    this.spacing = 4.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double totalSpacing = spacing * (slideCount - 1);
    final double itemWidth = (size.width - totalSpacing) / slideCount;
    final double height = size.height;

    final Paint bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final Paint progressPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, itemWidth, height),
      const Radius.circular(2),
    );

    for (int i = 0; i < slideCount; i++) {
      final double left = i * (itemWidth + spacing);
      final Rect rect = Rect.fromLTWH(left, 0, itemWidth, height);
      final RRect barRRect = RRect.fromRectAndRadius(rect, const Radius.circular(2));
      
      // Draw background
      canvas.drawRRect(barRRect, bgPaint);

      // Draw progress
      if (i < currentIndex) {
        // Full bar
        canvas.drawRRect(barRRect, progressPaint);
      } else if (i == currentIndex) {
        // Partial bar
        final Rect progressRect = Rect.fromLTWH(left, 0, itemWidth * progress, height);
        // Important: Clip to the rounded rect of the bar
        canvas.save();
        canvas.clipRRect(barRRect);
        canvas.drawRect(progressRect, progressPaint);
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant StoryProgressBarPainter oldDelegate) {
    return oldDelegate.currentIndex != currentIndex || 
           oldDelegate.progress != progress || 
           oldDelegate.slideCount != slideCount;
  }
}
