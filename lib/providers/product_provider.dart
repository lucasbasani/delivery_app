import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _service;

  ProductProvider(this._service);

  List<ProductModel> _products = [];
  bool _isLoading = false;
  String? _error;

  List<ProductModel> get products => List.unmodifiable(_products);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _products = await _service.fetchProducts();
    } catch (_) {
      _error = 'Não foi possível carregar o cardápio.';
    }

    _isLoading = false;
    notifyListeners();
  }
}
