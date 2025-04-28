// widgets/page_indicator.dart
import 'package:flutter/material.dart';

class PageIndicator extends StatelessWidget {
  final int currentIndex;
  final int pageCount;
  final Color activeColor;

  const PageIndicator({
    super.key,
    required this.currentIndex,
    required this.pageCount,
    this.activeColor = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pageCount, (index) {
        return Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: currentIndex == index
                ? activeColor
                : Colors.grey[300],
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}