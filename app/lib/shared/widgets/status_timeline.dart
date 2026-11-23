import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../core/utils/arabic.dart';
import '../../data/models/order.dart';

class StatusTimeline extends StatelessWidget {
  const StatusTimeline({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final current = order.status.timelineStep;
    final cancelled = order.status == OrderStatus.cancelled;

    final steps = <_StepData>[
      _StepData(
        title: 'تم إنشاء الطلب',
        time: formatTimeOfDay(order.createdAt),
      ),
      _StepData(
        title: 'تم قبول الطلب',
        time: order.acceptedAt == null
            ? 'بانتظار القبول'
            : formatTimeOfDay(order.acceptedAt!),
      ),
      _StepData(
        title: 'الموزّع في الطريق',
        time: current >= 2 ? 'جارٍ التوصيل' : 'لم يبدأ بعد',
      ),
      _StepData(
        title: 'تم التسليم',
        time: order.deliveredAt == null
            ? 'غير مُسلَّم'
            : formatTimeOfDay(order.deliveredAt!),
      ),
    ];

    return Column(
      children: [
        for (var index = 0; index < steps.length; index++)
          _StepRow(
            data: steps[index],
            done: !cancelled && index <= current,
            isCurrent: !cancelled && index == current,
            isLast: index == steps.length - 1,
          ),
      ],
    );
  }
}

class _StepData {
  const _StepData({required this.title, required this.time});

  final String title;
  final String time;
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.data,
    required this.done,
    required this.isCurrent,
    required this.isLast,
  });

  final _StepData data;
  final bool done;
  final bool isCurrent;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final color = done ? AppColors.apricot : AppColors.line;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: done ? AppColors.apricot : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 1.6),
                ),
                child: Icon(
                  done ? Icons.check_rounded : Icons.circle,
                  size: done ? 15 : 8,
                  color: done ? Colors.white : AppColors.line,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 3),
                    color: done ? AppColors.apricotSoft : AppColors.line,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight:
                          isCurrent ? FontWeight.w800 : FontWeight.w600,
                      color: done ? AppColors.navy : AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    data.time,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
