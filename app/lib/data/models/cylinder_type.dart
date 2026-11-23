/// Cylinder kinds offered by Jarti. Both cost the same.
enum CylinderType {
  steel('حديد', 'منزلية ١٢٫٥ كغم'),
  plastic('بلاستيك', 'خفيفة — كومبوزيت');

  const CylinderType(this.label, this.subtitle);

  final String label;
  final String subtitle;

  static CylinderType fromName(String? name) => values.firstWhere(
        (type) => type.name == name,
        orElse: () => CylinderType.steel,
      );
}
