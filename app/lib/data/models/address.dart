/// A saved delivery address. Orders store a snapshot of the address text so a
/// later edit never rewrites the history of an old order.
class Address {
  const Address({
    required this.id,
    required this.label,
    required this.area,
    required this.details,
  });

  final String id;
  final String label;
  final String area;
  final String details;

  String get fullText => details.trim().isEmpty ? area : '$area — $details';

  factory Address.defaultHome() => const Address(
        id: 'addr-home',
        label: 'المنزل',
        area: 'حي الفدين',
        details: 'شارع الجيش، بناية ٢٤',
      );

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        id: json['id'] as String? ?? 'addr-${DateTime.now().microsecondsSinceEpoch}',
        label: json['label'] as String? ?? 'المنزل',
        area: json['area'] as String? ?? '',
        details: json['details'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'area': area,
        'details': details,
      };

  Address copyWith({String? label, String? area, String? details}) => Address(
        id: id,
        label: label ?? this.label,
        area: area ?? this.area,
        details: details ?? this.details,
      );
}

/// Areas currently served around Al-Mafraq.
const List<String> mafraqAreas = <String>[
  'المفرق — وسط البلد',
  'حي الفدين',
  'حي الجديدة',
  'بلعما',
  'المنشية',
  'حي الحسين',
  'أم اللولو',
  'الخالدية',
  'حي الجيش',
  'المدينة الصناعية',
];
