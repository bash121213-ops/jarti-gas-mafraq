import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/theme.dart';
import '../../core/config/app_config.dart';
import '../../core/utils/arabic.dart';
import '../../data/models/order.dart';
import '../../shared/widgets/map_preview.dart';
import '../../shared/widgets/status_timeline.dart';

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key, required this.orderId});

  final String orderId;

  Color _statusColor(OrderStatus status) => switch (status) {
        OrderStatus.pending => AppColors.apricotInk,
        OrderStatus.accepted => AppColors.mint,
        OrderStatus.onTheWay => AppColors.apricotInk,
        OrderStatus.delivered => AppColors.mint,
        OrderStatus.cancelled => AppColors.danger,
      };

  Future<void> _cancel(BuildContext context, Order order) async {
    final state = AppScope.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('إلغاء الطلب؟'),
        content: const Text(
          'يمكن الإلغاء قبل قبول الموزّع دون رسوم. بعد القبول قد يُطبَّق رسم إلغاء بسيط.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('رجوع'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.danger,
              minimumSize: const Size(110, 46),
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('تأكيد الإلغاء'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await state.cancelOrder(order.id);
    }
  }

  void _comingSoon(BuildContext context, String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$action سيتوفر بعد ربط الخادم بحساب الموزّع.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final order = state.orderById(orderId);

    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('تتبّع الطلب')),
        body: const Center(child: Text('لم يتم العثور على هذا الطلب.')),
      );
    }

    final statusColor = _statusColor(order.status);
    final canCancel = order.status == OrderStatus.pending ||
        order.status == OrderStatus.accepted;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_forward_rounded),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('تتبّع الطلب'),
            Text(
              'رقم ${order.id}',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.muted,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 30),
        children: [
          MapPreview(
            height: 220,
            showDriver: order.status == OrderStatus.onTheWay,
            borderRadius: 24,
            overlay: Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFFE8ECE6)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.schedule_rounded,
                        size: 13, color: const Color(0xFF39745F)),
                    const SizedBox(width: 5),
                    Text(
                      order.status == OrderStatus.delivered
                          ? 'تم التسليم'
                          : 'يصل بعد ${AppConfig.defaultEtaMinutes} دقيقة',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'حالة الطلب',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        order.status.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  order.status.customerHint,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.muted,
                    height: 1.7,
                  ),
                ),
                const SizedBox(height: 18),
                StatusTimeline(order: order),
                if (order.status.isActive) ...[
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () => state.advanceOrder(order.id),
                    icon: const Icon(Icons.fast_forward_rounded, size: 18),
                    label: const Text('محاكاة تحديث الحالة (تجريبي)'),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.line),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 23,
                      backgroundColor: AppColors.creamDeep,
                      child: const Icon(
                        Icons.storefront_outlined,
                        color: const Color(0xFF39745F),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'مؤسسة الفدين للغاز',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'موزّع معتمد · ديانا المفرق',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 15, color: AppColors.apricot),
                        Text(
                          '4.9',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _comingSoon(context, 'الاتصال'),
                        icon: const Icon(Icons.call_outlined, size: 17),
                        label: const Text('اتصال'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _comingSoon(context, 'واتساب'),
                        icon: const Icon(Icons.chat_bubble_outline_rounded,
                            size: 17),
                        label: const Text('واتساب'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ملخص الطلب',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                _row(
                  '${order.cylinderType.label} × ${order.quantity}',
                  formatMoney(order.total - order.deliveryFee),
                ),
                const SizedBox(height: 8),
                _row('أجرة التوصيل', formatMoney(order.deliveryFee)),
                const SizedBox(height: 8),
                _row('طريقة الدفع', 'نقداً عند التسليم'),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text(
                      'المجموع',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      formatMoney(order.total),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppColors.apricotInk,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.cream,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 17, color: AppColors.muted),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.address.fullText,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                height: 1.6,
                              ),
                            ),
                            if (order.note.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                'ملاحظة: ${order.note}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.muted,
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (canCancel) ...[
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => _cancel(context, order),
              style: TextButton.styleFrom(foregroundColor: AppColors.danger),
              child: const Text('إلغاء الطلب'),
            ),
          ],
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
            style: const TextStyle(fontSize: 12.5, color: AppColors.muted),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
