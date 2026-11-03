import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/order_model.dart';
import '../services/order_service.dart';

class OrderProvider extends ChangeNotifier {
  final OrderService _service;

  OrderProvider(this._service);

  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String? _error;

  List<OrderModel> get orders => List.unmodifiable(_orders);
  bool get isLoading => _isLoading;
  String? get error => _error;

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  Future<void> loadOrders() async {
    final userId = _userId;
    if (userId == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _orders = await _service.fetchByUser(userId);
    } catch (_) {
      _error = 'Não foi possível carregar seus pedidos.';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Salva o pedido no Firestore. Retorna o pedido com id ou `null` se falhar.
  Future<OrderModel?> placeOrder(OrderModel order) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    OrderModel? saved;
    try {
      saved = await _service.create(order);
      _orders.insert(0, saved);
    } catch (_) {
      _error = 'Não foi possível enviar o pedido. Tente novamente.';
    }

    _isLoading = false;
    notifyListeners();
    return saved;
  }

  void clear() {
    _orders = [];
    notifyListeners();
  }
}
