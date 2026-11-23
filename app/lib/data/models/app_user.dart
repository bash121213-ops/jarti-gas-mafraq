/// Different app experiences share one account system.
enum UserRole {
  customer('عميل'),
  driver('موزّع');

  const UserRole(this.label);

  final String label;

  static UserRole fromName(String? name) => values.firstWhere(
        (role) => role.name == name,
        orElse: () => UserRole.customer,
      );
}

class AppUser {
  const AppUser({
    required this.id,
    required this.phone,
    required this.name,
    required this.role,
  });

  final String id;
  final String phone;
  final String name;
  final UserRole role;

  String get displayName => name.trim().isEmpty ? 'عميل جَرّتي' : name.trim();

  AppUser copyWith({String? name}) => AppUser(
        id: id,
        phone: phone,
        name: name ?? this.name,
        role: role,
      );

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        name: json['name'] as String? ?? '',
        role: UserRole.fromName(json['role'] as String?),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'phone': phone,
        'name': name,
        'role': role.name,
      };
}
