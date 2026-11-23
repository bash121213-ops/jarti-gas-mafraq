import 'dart:convert';

import '../../core/storage/local_store.dart';
import '../models/order.dart';

/// Local order storage for the prototype.
///
/// Phase 2 replaces this with Supabase tables (`orders`, `order_events`) and
/// realtime subscriptions; the screen layer only talks to [AppState].
class OrderRepository {
  OrderRepository(this._store);

  final LocalStore _store;

  static const String storageKey = 'jarti.orders.v1';

  List<Order> load() {
    final raw = _store.read(storageKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .whereType<Map<dynamic, dynamic>>()
          .map((item) => Order.fromJson(item.cast<String, dynamic>()))
          .toList();
    } on FormatException {
      return const [];
    }
  }

  Future<void> save(List<Order> orders) async {
    final encoded = jsonEncode(orders.map((order) => order.toJson()).toList());
    await _store.write(storageKey, encoded);
  }
}
