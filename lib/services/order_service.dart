import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/order_model.dart';

/// Pedidos ficam na coleção `orders`, cada um com o `userId` do dono.
class OrderService {
  final CollectionReference<Map<String, dynamic>> _col =
      FirebaseFirestore.instance.collection('orders');

  Future<OrderModel> create(OrderModel order) async {
    final ref = await _col.add(order.toMap());
    return order.copyWithId(ref.id);
  }

  /// Busca só os pedidos do usuário (exigido pelas regras do Firestore).
  /// A ordenação é feita aqui no app para não precisar de índice composto.
  Future<List<OrderModel>> fetchByUser(String userId) async {
    final snap = await _col.where('userId', isEqualTo: userId).get();
    final orders = snap.docs
        .map((doc) => OrderModel.fromMap(doc.id, doc.data()))
        .toList();
    orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return orders;
  }
}
