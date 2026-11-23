import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../core/storage/local_store.dart';
import '../data/models/address.dart';
import '../data/models/app_user.dart';
import '../data/models/cylinder_type.dart';
import '../data/models/order.dart';
import '../data/models/pricing.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/order_repository.dart';
import '../data/repositories/pricing_repository.dart';

/// Single source of truth for the prototype UI.
///
/// Repository calls are async already, so moving them from local storage to
/// Supabase later does not require screen changes.
class AppState extends ChangeNotifier {
  AppState({LocalStore? store}) : _store = store;

  static const String _userKey = 'jarti.user.v1';
  static const String _addressesKey = 'jarti.addresses.v1';

  final LocalStore? _store;
  final AuthRepository _auth = AuthRepository();
  final PricingRepository _pricingRepository = PricingRepository();
  final Random _random = Random();

  late final OrderRepository _orderRepository =
      OrderRepository(_store ?? LocalStore.memory());

  AppUser? user;
  Pricing pricing = Pricing.fallback;
  List<Order> orders = const [];
  List<Address> addresses = const [];
  Address? selectedAddress;
  bool isBusy = false;

  String? pendingPhone;
  UserRole pendingRole = UserRole.customer;

  bool get isSignedIn => user != null;

  bool get isCustomer => user?.role == UserRole.customer;

  Order? get activeOrder {
    for (final order in orders) {
      if (order.status.isActive) return order;
    }
    return null;
  }

  Order? orderById(String id) {
    for (final order in orders) {
      if (order.id == id) return order;
    }
    return null;
  }

  Address get deliveryAddress =>
      selectedAddress ?? (addresses.isEmpty ? Address.defaultHome() : addresses.first);

  Future<void> bootstrap() async {
    pricing = await _pricingRepository.fetch();
    orders = _orderRepository.load();

    final rawUser = _store?.read(_userKey);
    if (rawUser != null && rawUser.isNotEmpty) {
      try {
        user = AppUser.fromJson(jsonDecode(rawUser) as Map<String, dynamic>);
      } on FormatException {
        user = null;
      }
    }

    final rawAddresses = _store?.read(_addressesKey);
    if (rawAddresses != null && rawAddresses.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawAddresses) as List<dynamic>;
        addresses = decoded
            .whereType<Map<dynamic, dynamic>>()
            .map((item) => Address.fromJson(item.cast<String, dynamic>()))
            .toList();
      } on FormatException {
        addresses = const [];
      }
    }
    if (addresses.isEmpty) {
      addresses = [Address.defaultHome()];
    }
    selectedAddress = addresses.first;
    notifyListeners();
  }

  Future<void> sendOtp({required String phone, required UserRole role}) async {
    isBusy = true;
    notifyListeners();
    try {
      await _auth.requestOtp(phone);
      pendingPhone = phone;
      pendingRole = role;
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  Future<void> verifyOtp(String code) async {
    final phone = pendingPhone;
    if (phone == null) {
      throw AuthException('أعد إرسال رمز التحقق أولاً.');
    }
    isBusy = true;
    notifyListeners();
    try {
      user = await _auth.verifyOtp(phone: phone, code: code, role: pendingRole);
      await _persistUser();
      pendingPhone = null;
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    user = null;
    await _store?.remove(_userKey);
    notifyListeners();
  }

  Future<void> updateName(String name) async {
    final current = user;
    if (current == null) return;
    user = current.copyWith(name: name.trim());
    await _persistUser();
    notifyListeners();
  }

  void selectAddress(Address address) {
    selectedAddress = address;
    notifyListeners();
  }

  Future<void> addAddress(Address address) async {
    addresses = [...addresses, address];
    selectedAddress = address;
    await _persistAddresses();
    notifyListeners();
  }

  Future<void> removeAddress(String id) async {
    addresses = addresses.where((address) => address.id != id).toList();
    if (addresses.isEmpty) {
      addresses = [Address.defaultHome()];
    }
    if (selectedAddress?.id == id) {
      selectedAddress = addresses.first;
    }
    await _persistAddresses();
    notifyListeners();
  }

  Future<Order> placeOrder({
    required CylinderType cylinderType,
    required int quantity,
    required Address address,
    String note = '',
  }) async {
    final now = DateTime.now();
    final order = Order(
      id: _newOrderId(),
      createdAt: now,
      cylinderType: cylinderType,
      quantity: quantity,
      address: address,
      unitPrice: pricing.cylinderPrice,
      deliveryFee: pricing.deliveryFee,
      total: pricing.totalFor(quantity),
      customerName: user?.displayName ?? '',
      customerPhone: user?.phone ?? '',
      note: note.trim(),
    );
    orders = [order, ...orders];
    await _orderRepository.save(orders);
    notifyListeners();
    return order;
  }

  /// Demo-only lifecycle step used by the tracking screen before realtime is
  /// connected. Real transitions come from driver actions on the server.
  Future<void> advanceOrder(String id) async {
    final order = orderById(id);
    if (order == null) return;
    final now = DateTime.now();
    final next = switch (order.status) {
      OrderStatus.pending => order.copyWith(
          status: OrderStatus.accepted,
          acceptedAt: now,
        ),
      OrderStatus.accepted => order.copyWith(status: OrderStatus.onTheWay),
      OrderStatus.onTheWay => order.copyWith(
          status: OrderStatus.delivered,
          deliveredAt: now,
        ),
      _ => null,
    };
    if (next == null) return;
    await _replaceOrder(next);
  }

  Future<void> cancelOrder(String id) async {
    final order = orderById(id);
    if (order == null || !order.status.isActive) return;
    await _replaceOrder(order.copyWith(status: OrderStatus.cancelled));
  }

  Future<Order> reorder(String id) async {
    final previous = orderById(id);
    if (previous == null) {
      throw StateError('order not found');
    }
    return placeOrder(
      cylinderType: previous.cylinderType,
      quantity: previous.quantity,
      address: previous.address,
      note: previous.note,
    );
  }

  Future<void> _replaceOrder(Order updated) async {
    orders = orders
        .map((order) => order.id == updated.id ? updated : order)
        .toList();
    await _orderRepository.save(orders);
    notifyListeners();
  }

  String _newOrderId() {
    var candidate = '';
    do {
      candidate = 'MF-${1000 + _random.nextInt(9000)}';
    } while (orders.any((order) => order.id == candidate));
    return candidate;
  }

  Future<void> _persistUser() async {
    final current = user;
    if (current == null) return;
    await _store?.write(_userKey, jsonEncode(current.toJson()));
  }

  Future<void> _persistAddresses() async {
    await _store?.write(
      _addressesKey,
      jsonEncode(addresses.map((address) => address.toJson()).toList()),
    );
  }
}
