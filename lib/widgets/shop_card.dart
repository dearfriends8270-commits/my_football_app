import 'package:flutter/material.dart';

class ShopCard extends StatelessWidget {
  final String title;
  final String linkText;
  final VoidCallback? onTap;

  const ShopCard({
    super.key,
    required this.title,
    required this.linkText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              linkText,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF5B9BD5),
                decoration: TextDecoration.underline,
                decorationColor: Color(0xFF5B9BD5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
