import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/theme.dart';
import '../../core/utils/arabic.dart';
import '../../data/models/order.dart';
import '../home/home_screen.dart';
import '../tracking/tracking_screen.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  Color _statusColor(OrderStatus status) => switch (status) {
        OrderStatus.pending => AppColors.apricotInk,
        OrderStatus.accepted => AppColors.mint,
        OrderStatus.onTheWay => AppColors.apricotInk,
        OrderStatus.delivered => AppColors.mint,
        OrderStatus.cancelled => AppColors.danger,
      };

  Future<void> _reorder(BuildContext context, Order order) async {
    final state = AppScope.of(context);
    final created = await state.reorder(order.id);
    if (!context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TrackingScreen(orderId: created.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('طلباتي'), backgroundColor: const Color(0xFFF6F7F3)),
      body: state.orders.isEmpty
          ? const _EmptyOrders()
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
              itemCount: state.orders.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final order = state.orders[index];
                final color = _statusColor(order.status);
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(23),
                    border: Border.all(color: const Color(0xFFE8ECE6)),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .025), blurRadius: 14, offset: const Offset(0, 5))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAF2EC),
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: const Icon(
                              Icons.propane_tank,
                              size: 20,
                              color: const Color(0xFF39745F),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${order.cylinderType.label} × ${order.quantity}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  '${order.id} · ${formatDate(order.createdAt)}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              order.status.label,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: color,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        order.address.fullText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.muted,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            formatMoney(order.total),
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () => _reorder(context, order),
                            child: const Text('إعادة الطلب'),
                          ),
                          const SizedBox(width: 4),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 42),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                            ),
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                    TrackingScreen(orderId: order.id),
                              ),
                            ),
                            child: const Text('تتبّع'),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class _EmptyOrders extends StatelessWidget {
  const _EmptyOrders();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                color: AppColors.creamDeep,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                size: 34,
                color: AppColors.apricotInk,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'لا توجد طلبات بعد',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            const Text(
              'أول أسطوانة لك تبدأ من الرئيسية: اختر النوع والكمية، وسنوصلها إلى بابك.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                color: AppColors.muted,
                height: 1.8,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              style: FilledButton.styleFrom(
                minimumSize: const Size(200, 52),
              ),
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
                );
              },
              child: const Text('اطلب أسطوانة'),
            ),
          ],
        ),
      ),
    );
  }
}
