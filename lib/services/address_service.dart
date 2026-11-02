import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/address_model.dart';

/// CRUD dos endereços salvos, na subcoleção `users/{uid}/addresses`.
class AddressService {
  CollectionReference<Map<String, dynamic>> _col(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('addresses');
  }

  Future<List<AddressModel>> fetchAll(String userId) async {
    final snap = await _col(userId).get();
    final list = snap.docs
        .map((doc) => AddressModel.fromMap(doc.id, doc.data()))
        .toList();
    list.sort((a, b) => a.label.compareTo(b.label));
    return list;
  }

  Future<AddressModel> create(String userId, AddressModel address) async {
    final ref = await _col(userId).add(address.toMap());
    return address.copyWith(id: ref.id);
  }

  Future<void> update(String userId, AddressModel address) {
    return _col(userId).doc(address.id).update(address.toMap());
  }

  Future<void> delete(String userId, String addressId) {
    return _col(userId).doc(addressId).delete();
  }
}
