import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../core/utils/arabic.dart';
import '../../data/models/pricing.dart';

/// Transparent invoice summary: cylinders + one-time delivery fee + total.
class PriceSummary extends StatelessWidget {
  const PriceSummary({
    super.key,
    required this.pricing,
    required this.quantity,
  });

  final Pricing pricing;
  final int quantity;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.verified_user_outlined,
                  size: 15, color: AppColors.mint),
              const SizedBox(width: 6),
              Text(
                'سعر شفاف — بدون رسوم مخفية',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.mint.withValues(alpha: 0.95),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _row(
            'سعر الأسطوانة × $quantity',
            formatMoney(pricing.cylindersSubtotal(quantity)),
          ),
          const SizedBox(height: 9),
          _row(
            'أجرة التوصيل (لكل طلب)',
            formatMoney(pricing.deliveryFee),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          Row(
            children: [
              const Text(
                'المجموع الكلي',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              Text(
                formatMoney(pricing.totalFor(quantity)),
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                  color: AppColors.apricotInk,
                  height: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.creamDeep,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.payments_outlined,
                    size: 16, color: AppColors.navy),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'الدفع نقداً عند التسليم — يمكن الدفع بعملات معدنية صغيرة',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      height: 1.6,
                      color: AppColors.navy,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppColors.muted),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
            color: AppColors.navy,
          ),
        ),
      ],
    );
  }
}
