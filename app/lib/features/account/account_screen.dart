import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/theme.dart';
import '../../core/utils/arabic.dart';
import '../../data/models/address.dart';
import '../../shared/widgets/address_sheet.dart';
import '../../state/app_state.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  Future<void> _editName(BuildContext context, AppState state) async {
    final controller =
        TextEditingController(text: state.user?.displayName ?? '');
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('الاسم'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(
            hintText: 'الاسم الذي يظهر للموزّع',
          ),
          onSubmitted: (value) => Navigator.of(dialogContext).pop(value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size(100, 44),
            ),
            onPressed: () => Navigator.of(dialogContext).pop(controller.text),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
    if (name != null && name.trim().isNotEmpty) {
      await state.updateName(name);
    }
  }

  Future<void> _addAddress(BuildContext context, AppState state) async {
    final address = await showAddressSheet(context);
    if (address != null) {
      await state.addAddress(address);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final user = state.user;

    return Scaffold(
      appBar: AppBar(title: const Text('حسابي')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.line),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.creamDeep,
                  child: Text(
                    (user?.displayName ?? 'ج').characters.first,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.apricotInk,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.displayName ?? 'عميل جَرّتي',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user == null ? '' : formatPhone(user.phone),
                        textDirection: TextDirection.ltr,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.muted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.creamDeep,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          user?.role.label ?? 'عميل',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.apricotInk,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _editName(context, state),
                  icon: const Icon(Icons.edit_outlined, size: 20),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'العناوين المحفوظة',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
              TextButton.icon(
                onPressed: () => _addAddress(context, state),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('إضافة'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.line),
            ),
            child: Column(
              children: [
                for (var i = 0; i < state.addresses.length; i++) ...[
                  if (i > 0) const Divider(height: 1),
                  _AddressTile(
                    address: state.addresses[i],
                    selected:
                        state.deliveryAddress.id == state.addresses[i].id,
                    onSelect: () =>
                        state.selectAddress(state.addresses[i]),
                    onDelete: () =>
                        state.removeAddress(state.addresses[i].id),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'طريقة الدفع',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.line),
            ),
            child: const Row(
              children: [
                Icon(Icons.payments_outlined, color: AppColors.mint),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'نقداً عند التسليم',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'يمكن الدفع بعملات ورقية أو معدنية صغيرة.',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.check_circle_rounded,
                    color: AppColors.mint, size: 20),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.creamDeep,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              children: [
                Icon(Icons.support_agent_rounded, color: AppColors.apricotInk),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'الدعم: يُضاف رقم واتساب الدعم في المرحلة القادمة.',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.7,
                      color: AppColors.navy,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          OutlinedButton.icon(
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('تسجيل الخروج'),
                  content: const Text('هل تريد الخروج من حسابك؟'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      child: const Text('إلغاء'),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.danger,
                        minimumSize: const Size(100, 44),
                      ),
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                      child: const Text('خروج'),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                await state.signOut();
              }
            },
            icon: const Icon(Icons.logout_rounded, size: 18),
            label: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }
}

class _AddressTile extends StatelessWidget {
  const _AddressTile({
    required this.address,
    required this.selected,
    required this.onSelect,
    required this.onDelete,
  });

  final Address address;
  final bool selected;
  final VoidCallback onSelect;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onSelect,
      leading: Icon(
        selected ? Icons.radio_button_checked : Icons.radio_button_off,
        color: selected ? AppColors.apricot : AppColors.muted,
        size: 20,
      ),
      title: Text(
        address.label,
        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800),
      ),
      subtitle: Text(
        address.fullText,
        style: const TextStyle(fontSize: 11.5),
      ),
      trailing: IconButton(
        onPressed: onDelete,
        icon: const Icon(Icons.delete_outline_rounded, size: 19),
        color: AppColors.muted,
      ),
    );
  }
}
