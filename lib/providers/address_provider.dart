import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/address_model.dart';
import '../services/address_service.dart';

class AddressProvider extends ChangeNotifier {
  final AddressService _service;

  AddressProvider(this._service);

  List<AddressModel> _addresses = [];
  bool _isLoading = false;
  String? _error;

  List<AddressModel> get addresses => List.unmodifiable(_addresses);
  bool get isLoading => _isLoading;
  String? get error => _error;

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  Future<void> loadAddresses() async {
    final userId = _userId;
    if (userId == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _addresses = await _service.fetchAll(userId);
    } catch (_) {
      _error = 'Não foi possível carregar os endereços.';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Cria (sem id) ou atualiza (com id). Retorna a mensagem de erro ou `null`.
  Future<String?> save(AddressModel address) async {
    final userId = _userId;
    if (userId == null) return 'Sessão expirada. Entre novamente.';

    try {
      if (address.id == null) {
        final created = await _service.create(userId, address);
        _addresses.add(created);
      } else {
        await _service.update(userId, address);
        final index = _addresses.indexWhere((a) => a.id == address.id);
        if (index >= 0) _addresses[index] = address;
      }
      _addresses.sort((a, b) => a.label.compareTo(b.label));
      notifyListeners();
      return null;
    } catch (_) {
      return 'Não foi possível salvar o endereço.';
    }
  }

  Future<String?> delete(String addressId) async {
    final userId = _userId;
    if (userId == null) return 'Sessão expirada. Entre novamente.';

    try {
      await _service.delete(userId, addressId);
      _addresses.removeWhere((a) => a.id == addressId);
      notifyListeners();
      return null;
    } catch (_) {
      return 'Não foi possível excluir o endereço.';
    }
  }

  void clear() {
    _addresses = [];
    notifyListeners();
  }
}
