import 'package:flutter/material.dart';
import '../utils/constants.dart';

class Watermark extends StatelessWidget {
  const Watermark({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Opacity(
        opacity: 0.3,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Desarrollado por',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Diego González',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              'DG',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary.withOpacity(0.4),
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
