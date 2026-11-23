import 'address.dart';
import 'cylinder_type.dart';

/// Order lifecycle. Every transition is confirmed by a different actor:
/// customer (create/cancel), driver (accept/deliver), system (on the way).
enum OrderStatus {
  pending,
  accepted,
  onTheWay,
  delivered,
  cancelled,
}

extension OrderStatusX on OrderStatus {
  String get label => switch (this) {
        OrderStatus.pending => 'قيد الانتظار',
        OrderStatus.accepted => 'تم القبول',
        OrderStatus.onTheWay => 'الموزّع على الطريق',
        OrderStatus.delivered => 'تم التسليم',
        OrderStatus.cancelled => 'ملغى',
      };

  String get customerHint => switch (this) {
        OrderStatus.pending => 'بانتظار قبول أقرب موزّع معتمد',
        OrderStatus.accepted => 'الموزّع استلم طلبك ويجهّز الأسطوانة',
        OrderStatus.onTheWay => 'الموزّع في الطريق إليك',
        OrderStatus.delivered => 'تم تسليم الأسطوانة وتحصيل المبلغ',
        OrderStatus.cancelled => 'تم إلغاء هذا الطلب',
      };

  /// Index inside the four-step tracking timeline, -1 when cancelled.
  int get timelineStep => switch (this) {
        OrderStatus.pending => 0,
        OrderStatus.accepted => 1,
        OrderStatus.onTheWay => 2,
        OrderStatus.delivered => 3,
        OrderStatus.cancelled => -1,
      };

  bool get isActive =>
      this == OrderStatus.pending ||
      this == OrderStatus.accepted ||
      this == OrderStatus.onTheWay;

  static OrderStatus fromName(String? name) => OrderStatus.values.firstWhere(
        (status) => status.name == name,
        orElse: () => OrderStatus.pending,
      );
}

class Order {
  const Order({
    required this.id,
    required this.createdAt,
    required this.cylinderType,
    required this.quantity,
    required this.address,
    required this.unitPrice,
    required this.deliveryFee,
    required this.total,
    required this.customerName,
    required this.customerPhone,
    this.note = '',
    this.status = OrderStatus.pending,
    this.acceptedAt,
    this.deliveredAt,
  });

  final String id;
  final DateTime createdAt;
  final CylinderType cylinderType;
  final int quantity;

  /// Snapshot of the address at order time.
  final Address address;
  final double unitPrice;
  final double deliveryFee;
  final double total;
  final String customerName;
  final String customerPhone;
  final String note;
  final OrderStatus status;
  final DateTime? acceptedAt;
  final DateTime? deliveredAt;

  Order copyWith({
    OrderStatus? status,
    DateTime? acceptedAt,
    DateTime? deliveredAt,
  }) =>
      Order(
        id: id,
        createdAt: createdAt,
        cylinderType: cylinderType,
        quantity: quantity,
        address: address,
        unitPrice: unitPrice,
        deliveryFee: deliveryFee,
        total: total,
        customerName: customerName,
        customerPhone: customerPhone,
        note: note,
        status: status ?? this.status,
        acceptedAt: acceptedAt ?? this.acceptedAt,
        deliveredAt: deliveredAt ?? this.deliveredAt,
      );

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json['id'] as String? ?? '',
        createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
            DateTime.now(),
        cylinderType: CylinderType.fromName(json['cylinder_type'] as String?),
        quantity: (json['quantity'] as num?)?.toInt() ?? 1,
        address: Address.fromJson(
          (json['address'] as Map?)?.cast<String, dynamic>() ?? const {},
        ),
        unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 7.00,
        deliveryFee: (json['delivery_fee'] as num?)?.toDouble() ?? 0.10,
        total: (json['total'] as num?)?.toDouble() ?? 7.10,
        customerName: json['customer_name'] as String? ?? '',
        customerPhone: json['customer_phone'] as String? ?? '',
        note: json['note'] as String? ?? '',
        status: OrderStatusX.fromName(json['status'] as String?),
        acceptedAt: DateTime.tryParse(json['accepted_at'] as String? ?? ''),
        deliveredAt: DateTime.tryParse(json['delivered_at'] as String? ?? ''),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'created_at': createdAt.toIso8601String(),
        'cylinder_type': cylinderType.name,
        'quantity': quantity,
        'address': address.toJson(),
        'unit_price': unitPrice,
        'delivery_fee': deliveryFee,
        'total': total,
        'customer_name': customerName,
        'customer_phone': customerPhone,
        'note': note,
        'status': status.name,
        'accepted_at': acceptedAt?.toIso8601String(),
        'delivered_at': deliveredAt?.toIso8601String(),
      };
}
