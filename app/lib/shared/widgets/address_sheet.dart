import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../data/models/address.dart';

/// Opens the address form and returns the saved address, or null when closed.
Future<Address?> showAddressSheet(
  BuildContext context, {
  Address? initial,
}) {
  return showModalBottomSheet<Address>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    builder: (_) => AddressFormSheet(initial: initial),
  );
}

class AddressFormSheet extends StatefulWidget {
  const AddressFormSheet({super.key, this.initial});

  final Address? initial;

  @override
  State<AddressFormSheet> createState() => _AddressFormSheetState();
}

class _AddressFormSheetState extends State<AddressFormSheet> {
  late final TextEditingController _details;
  late String _area;
  late String _label;

  static const List<String> _labels = ['المنزل', 'العمل', 'أخرى'];

  @override
  void initState() {
    super.initState();
    _details = TextEditingController(text: widget.initial?.details ?? '');
    _area = widget.initial?.area ?? mafraqAreas.first;
    _label = widget.initial?.label ?? _labels.first;
  }

  @override
  void dispose() {
    _details.dispose();
    super.dispose();
  }

  void _save() {
    final cleanDetails = _details.text.trim();
    if (cleanDetails.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اكتب تفاصيل العنوان: الشارع والبناية.')),
      );
      return;
    }
    Navigator.of(context).pop(
      Address(
        id: widget.initial?.id ??
            'addr-${DateTime.now().millisecondsSinceEpoch}',
        label: _label,
        area: _area,
        details: cleanDetails,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.line,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              widget.initial == null ? 'إضافة عنوان' : 'تعديل العنوان',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            const Text(
              'نحتاج الشارع والبناية ليصل الموزّع دون تأخير.',
              style: TextStyle(fontSize: 12.5, color: AppColors.muted),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 8,
              children: [
                for (final label in _labels)
                  ChoiceChip(
                    label: Text(label),
                    selected: _label == label,
                    onSelected: (_) => setState(() => _label = label),
                    selectedColor: AppColors.creamDeep,
                    labelStyle: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: _label == label
                          ? AppColors.apricotInk
                          : AppColors.muted,
                    ),
                    side: BorderSide(
                      color:
                          _label == label ? AppColors.apricot : AppColors.line,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _area,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'المنطقة'),
              items: [
                for (final area in mafraqAreas)
                  DropdownMenuItem(value: area, child: Text(area)),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _area = value);
              },
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _details,
              maxLines: 2,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'تفاصيل العنوان',
                hintText: 'الشارع، رقم البناية، الطابق، علامة مميزة',
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _save,
              child: const Text('حفظ العنوان'),
            ),
          ],
        ),
      ),
    );
  }
}
