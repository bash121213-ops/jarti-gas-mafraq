/// Official Jarti pricing.
///
/// The values are served by the backend (`pricing` table). The constant below is
/// only an offline fallback so the prototype stays usable; it is never the
/// source of truth once the backend is connected.
class Pricing {
  const Pricing({
    required this.cylinderPrice,
    required this.deliveryFee,
  });

  final double cylinderPrice;
  final double deliveryFee;

  static const Pricing fallback = Pricing(cylinderPrice: 7.00, deliveryFee: 0.10);

  /// Delivery is charged once per order, regardless of quantity.
  double totalFor(int quantity) =>
      (cylinderPrice * quantity) + deliveryFee;

  double cylindersSubtotal(int quantity) => cylinderPrice * quantity;

  factory Pricing.fromJson(Map<String, dynamic> json) {
    final cylinder = json['cylinder_price'];
    final delivery = json['delivery_fee'];
    if (cylinder is! num || delivery is! num) return fallback;
    return Pricing(
      cylinderPrice: cylinder.toDouble(),
      deliveryFee: delivery.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'cylinder_price': cylinderPrice,
        'delivery_fee': deliveryFee,
      };
}
