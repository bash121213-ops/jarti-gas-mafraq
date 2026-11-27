import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/theme.dart';
import '../../core/utils/arabic.dart';
import '../../data/models/address.dart';
import '../../data/models/cylinder_type.dart';
import '../../shared/widgets/address_sheet.dart';
import '../../shared/widgets/map_preview.dart';
import '../../shared/widgets/price_summary.dart';
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
    final greeting = hour < 12 ? 'صباح الخير' : 'مساء الخير';

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F3),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.navy,
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: Center(
                    child: Text(
                      state.user?.displayName.characters.first ?? 'ج',
                      style: const TextStyle(
                        color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(greeting, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                      Text(
                        state.user?.displayName ?? 'أهلاً بك في جرّتي',
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.navy),
                      ),
                    ],
                  ),
                ),
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  child: IconButton(
                    tooltip: 'الإشعارات',
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('لا توجد إشعارات جديدة حالياً.')),
                    ),
                    icon: const Icon(Icons.notifications_none_rounded, color: AppColors.navy),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [Color(0xFF294D43), Color(0xFF18372F)],
                ),
                borderRadius: BorderRadius.circular(27),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF18372F).withValues(alpha: .16), blurRadius: 22, offset: const Offset(0, 10)),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: -18, top: -22,
                    child: Container(
                      width: 145, height: 145,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: .045),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: .12), borderRadius: BorderRadius.circular(30)),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.bolt_rounded, color: Color(0xFFFFC47D), size: 15),
                            SizedBox(width: 5),
                            Text('توصيل أسهل، وراحة أكبر', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'الغاز لبيتك،\nبضغطة زر.',
                        style: TextStyle(color: Colors.white, fontSize: 27, height: 1.35, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'اطلب أسطوانتك ونوصلها لعند باب البيت.',
                        style: TextStyle(color: Colors.white.withValues(alpha: .78), fontSize: 12.5, height: 1.7),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.verified_rounded, size: 16, color: Color(0xFFFFC47D)),
                          const SizedBox(width: 6),
                          Text('طلب سهل • دفع عند الاستلام', style: TextStyle(color: Colors.white.withValues(alpha: .9), fontSize: 11, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ],
                  ),
                  Positioned(
                    left: 2, bottom: 0,
                    child: Icon(Icons.propane_tank_rounded, size: 100, color: Colors.white.withValues(alpha: .12)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            if (!state.isCustomer) ...[
              const _DriverNotice(),
              const SizedBox(height: 14),
            ],
            if (active != null) ...[
              _ActiveOrderBanner(
                orderId: active.id,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => TrackingScreen(orderId: active.id)),
                ),
              ),
              const SizedBox(height: 16),
            ],
            InkWell(
              onTap: () => _pickAddress(state),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE8ECE6)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 43, height: 43,
                      decoration: BoxDecoration(color: const Color(0xFFEAF2EC), borderRadius: BorderRadius.circular(14)),
                      child: const Icon(Icons.location_on_rounded, color: Color(0xFF39745F), size: 21),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('عنوان التوصيل', style: TextStyle(fontSize: 11, color: AppColors.muted, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 3),
                          Text(state.deliveryAddress.fullText, maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.navy)),
                        ],
                      ),
                    ),
                    const Text('تغيير', style: TextStyle(color: Color(0xFF39745F), fontSize: 12, fontWeight: FontWeight.w900)),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_left_rounded, color: Color(0xFF39745F), size: 19),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(borderRadius: BorderRadius.circular(19), child: MapPreview(height: 82)),
            const SizedBox(height: 25),
            const Text('اختَر أسطوانتك', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: AppColors.navy)),
            const SizedBox(height: 4),
            Text('اختر النوع المناسب لاحتياج بيتك', style: TextStyle(fontSize: 12, color: AppColors.muted)),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: _CylinderOption(
                  type: CylinderType.steel, selected: _type == CylinderType.steel,
                  price: pricing.cylinderPrice, onTap: () => setState(() => _type = CylinderType.steel),
                )),
                const SizedBox(width: 12),
                Expanded(child: _CylinderOption(
                  type: CylinderType.plastic, selected: _type == CylinderType.plastic,
                  price: pricing.cylinderPrice, onTap: () => setState(() => _type = CylinderType.plastic),
                )),
              ],
            ),
            const SizedBox(height: 17),
            Container(
              padding: const EdgeInsets.all(17),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(21), border: Border.all(color: const Color(0xFFE8ECE6))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('كم أسطوانة تحتاج؟', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.navy)),
                            SizedBox(height: 3),
                            Text('حدد الكمية المطلوبة', style: TextStyle(fontSize: 11, color: AppColors.muted)),
                          ],
                        ),
                      ),
                      _Stepper(
                        value: _quantity,
                        onMinus: () { if (_quantity > 1) setState(() => _quantity -= 1); },
                        onPlus: () { if (_quantity < 4) setState(() => _quantity += 1); },
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _note,
                    maxLines: 2,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: 'ملاحظة للموزّع (اختياري)',
                      hintText: 'رقم الطابق أو علامة مميزة...',
                      prefixIcon: const Icon(Icons.edit_note_rounded, color: Color(0xFF39745F)),
                      filled: true,
                      fillColor: const Color(0xFFF7F8F5),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            PriceSummary(pricing: pricing, quantity: _quantity),
            const SizedBox(height: 14),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline_rounded, size: 14, color: AppColors.muted),
                SizedBox(width: 5),
                Text('الدفع نقداً عند الاستلام', style: TextStyle(fontSize: 11, color: AppColors.muted, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 18),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: const Border(top: BorderSide(color: Color(0xFFE9EDE7))),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .045), blurRadius: 18, offset: const Offset(0, -5))],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('الإجمالي', style: TextStyle(fontSize: 11, color: AppColors.muted, fontWeight: FontWeight.w600)),
                    Text(formatMoney(pricing.totalFor(_quantity)), style: const TextStyle(fontSize: 19, color: AppColors.navy, fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: _placing ? null : () => _placeOrder(state),
                  icon: _placing
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.arrow_back_rounded, size: 19),
                  label: Text(_placing ? 'جارٍ إرسال الطلب...' : 'تأكيد الطلب', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2F6B55),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(54),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
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
    final isSteel = type == CylinderType.steel;
    final accent = isSteel ? const Color(0xFF39745F) : const Color(0xFFC98243);
    final tint = isSteel ? const Color(0xFFEAF2EC) : const Color(0xFFFFF1E2);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.fromLTRB(13, 13, 13, 15),
          decoration: BoxDecoration(
            color: selected ? tint : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected ? accent.withValues(alpha: .65) : const Color(0xFFE8ECE6),
              width: selected ? 1.6 : 1,
            ),
            boxShadow: selected
                ? [BoxShadow(color: accent.withValues(alpha: .09), blurRadius: 15, offset: const Offset(0, 6))]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(isSteel ? 'الأكثر طلباً' : 'خفيفة وعملية',
                    style: TextStyle(fontSize: 9.5, color: accent, fontWeight: FontWeight.w800)),
                  const Spacer(),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 21, height: 21,
                    decoration: BoxDecoration(
                      color: selected ? accent : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: selected ? accent : const Color(0xFFDCE3DC), width: 1.4),
                    ),
                    child: selected ? const Icon(Icons.check_rounded, color: Colors.white, size: 14) : null,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Center(
                child: AnimatedScale(
                  scale: selected ? 1.04 : 1,
                  duration: const Duration(milliseconds: 220),
                  child: Container(
                    width: 74, height: 88,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: .09),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Icon(Icons.propane_tank_rounded, size: 61, color: accent),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text('أسطوانة ${type.label}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.navy)),
              const SizedBox(height: 3),
              Text(type.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10.5, color: AppColors.muted)),
              const SizedBox(height: 9),
              Text(formatMoney(price),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: accent)),
            ],
          ),
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
