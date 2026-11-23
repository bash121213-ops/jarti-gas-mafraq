import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/theme.dart';
import '../../core/utils/arabic.dart';
import '../../data/models/address.dart';
import '../../data/models/cylinder_type.dart';
import '../../shared/widgets/address_sheet.dart';
import '../../shared/widgets/map_preview.dart';
import '../../shared/widgets/price_summary.dart';
import '../../shared/widgets/section_title.dart';
import '../../state/app_state.dart';
import '../tracking/tracking_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CylinderType _type = CylinderType.steel;
  int _quantity = 1;
  bool _placing = false;
  final TextEditingController _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickAddress(AppState state) async {
    final result = await showModalBottomSheet<Object>(
      context: context,
      backgroundColor: Colors.white,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.line,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 22),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'عنوان التوصيل',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                ),
              ),
            ),
            const SizedBox(height: 8),
            for (final address in state.addresses)
              ListTile(
                onTap: () => Navigator.of(sheetContext).pop(address),
                leading: const Icon(
                  Icons.location_on_outlined,
                  color: AppColors.apricotInk,
                ),
                title: Text(
                  address.label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                subtitle: Text(
                  address.fullText,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ListTile(
              onTap: () => Navigator.of(sheetContext).pop('new'),
              leading: const Icon(Icons.add_location_alt_outlined,
                  color: AppColors.mint),
              title: const Text(
                'إضافة عنوان جديد',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (!mounted || result == null) return;
    if (result is Address) {
      state.selectAddress(result);
      return;
    }
    final created = await showAddressSheet(context);
    if (created != null) {
      await state.addAddress(created);
    }
  }

  Future<void> _placeOrder(AppState state) async {
    setState(() => _placing = true);
    try {
      final order = await state.placeOrder(
        cylinderType: _type,
        quantity: _quantity,
        address: state.deliveryAddress,
        note: _note.text,
      );
      if (!mounted) return;
      _note.clear();
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => TrackingScreen(orderId: order.id),
        ),
      );
    } finally {
      if (mounted) setState(() => _placing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final pricing = state.pricing;
    final active = state.activeOrder;
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'صباح الخير'
        : hour < 17
            ? 'مساء الخير'
            : 'مساء الخير';

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.creamDeep,
                  child: Text(
                    state.user?.displayName.characters.first ?? 'ج',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.apricotInk,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        greeting,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.muted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        state.user?.displayName ?? 'عميل جَرّتي',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.navy,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('لا توجد إشعارات جديدة حالياً.'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.notifications_none_rounded),
                  color: AppColors.navy,
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (!state.isCustomer) ...[
              _DriverNotice(),
              const SizedBox(height: 14),
            ],
            if (active != null) ...[
              _ActiveOrderBanner(
                orderId: active.id,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => TrackingScreen(orderId: active.id),
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ],
            InkWell(
              onTap: () => _pickAddress(state),
              borderRadius: BorderRadius.circular(18),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.line),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.creamDeep,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.location_on_outlined,
                        size: 20,
                        color: AppColors.apricotInk,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'التوصيل إلى',
                            style: TextStyle(
                              fontSize: 10.5,
                              color: AppColors.muted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            state.deliveryAddress.fullText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Text(
                      'تغيير',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.apricotInk,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            const MapPreview(height: 96),
            const SizedBox(height: 22),
            SectionTitle(
              'نوع الأسطوانة',
              subtitle: 'السعر الرسمي ${formatMoney(pricing.cylinderPrice)}',
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _CylinderOption(
                    type: CylinderType.steel,
                    selected: _type == CylinderType.steel,
                    price: pricing.cylinderPrice,
                    onTap: () => setState(() => _type = CylinderType.steel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _CylinderOption(
                    type: CylinderType.plastic,
                    selected: _type == CylinderType.plastic,
                    price: pricing.cylinderPrice,
                    onTap: () => setState(() => _type = CylinderType.plastic),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.line),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'الكمية',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'تبديل أسطوانة فارغة بأخرى ممتلئة',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _Stepper(
                        value: _quantity,
                        onMinus: () {
                          if (_quantity > 1) {
                            setState(() => _quantity -= 1);
                          }
                        },
                        onPlus: () {
                          if (_quantity < 4) {
                            setState(() => _quantity += 1);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _note,
                    maxLines: 2,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: 'ملاحظة للموزّع (اختياري)',
                      hintText: 'الطابق، وقت مناسب، علامة مميزة...',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            PriceSummary(pricing: pricing, quantity: _quantity),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: _placing ? null : () => _placeOrder(state),
              child: _placing
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Colors.white,
                      ),
                    )
                  : Text('اطلب الآن · ${formatMoney(pricing.totalFor(_quantity))}'),
            ),
            const SizedBox(height: 10),
            const Text(
              'سيتصل بك الموزّع قبل الوصول. الدفع نقداً عند التسليم.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class _CylinderOption extends StatelessWidget {
  const _CylinderOption({
    required this.type,
    required this.selected,
    required this.price,
    required this.onTap,
  });

  final CylinderType type;
  final bool selected;
  final double price;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? AppColors.creamDeep : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.apricot : AppColors.line,
            width: selected ? 1.8 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.apricot.withValues(alpha: 0.16)
                        : AppColors.cream,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(
                    Icons.propane_tank,
                    size: 20,
                    color: selected ? AppColors.apricotInk : AppColors.muted,
                  ),
                ),
                const Spacer(),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.apricot : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? AppColors.apricot : AppColors.line,
                      width: 1.5,
                    ),
                  ),
                  child: selected
                      ? const Icon(Icons.check_rounded,
                          size: 13, color: Colors.white)
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'أسطوانة ${type.label}',
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              type.subtitle,
              style: const TextStyle(fontSize: 11, color: AppColors.muted),
            ),
            const SizedBox(height: 10),
            Text(
              formatMoney(price),
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: AppColors.navy,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.value,
    required this.onMinus,
    required this.onPlus,
  });

  final int value;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          _button(Icons.remove_rounded, onMinus),
          SizedBox(
            width: 32,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          _button(Icons.add_rounded, onPlus),
        ],
      ),
    );
  }

  Widget _button(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 38,
        height: 38,
        child: Icon(icon, size: 18, color: AppColors.navy),
      ),
    );
  }
}

class _ActiveOrderBanner extends StatelessWidget {
  const _ActiveOrderBanner({required this.orderId, required this.onTap});

  final String orderId;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.mint.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.mint.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            const Icon(Icons.local_shipping_outlined,
                size: 20, color: AppColors.mint),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'لديك طلب قيد التوصيل · $orderId',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navy,
                ),
              ),
            ),
            const Icon(Icons.arrow_back_rounded,
                size: 18, color: AppColors.mint),
          ],
        ),
      ),
    );
  }
}

class _DriverNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.creamDeep,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 18, color: AppColors.apricotInk),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'واجهة الموزّع الكاملة (قبول الطلبات وتأكيد التسليم) تُضاف في المرحلة الثانية.',
              style: TextStyle(
                fontSize: 11.5,
                height: 1.7,
                fontWeight: FontWeight.w600,
                color: AppColors.navy,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
