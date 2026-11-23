import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// The rounded apricot tile with the gas-cylinder glyph used across the app.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 56});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFFFFF3E3), Color(0xFFFFE3C0)],
        ),
        borderRadius: BorderRadius.circular(size * 0.32),
        boxShadow: [
          BoxShadow(
            color: AppColors.apricot.withValues(alpha: 0.2),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.propane_tank,
          size: size * 0.48,
          color: const Color(0xFF5B3512),
        ),
      ),
    );
  }
}
