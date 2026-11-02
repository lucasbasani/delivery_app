import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/seed_products.dart';
import '../models/product_model.dart';

/// Leitura do cardápio na coleção `products` do Firestore.
class ProductService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('products');

  Future<List<ProductModel>> fetchProducts() async {
    await _seedIfEmpty();
    final snap = await _col.orderBy('id').get();
    return snap.docs
        .map((doc) => ProductModel.fromMap(doc.data()))
        .toList();
  }

  /// Na primeira execução a coleção está vazia: grava o cardápio
  /// inicial de uma vez só, usando um batch.
  Future<void> _seedIfEmpty() async {
    final snap = await _col.limit(1).get();
    if (snap.docs.isNotEmpty) return;

    final batch = _db.batch();
    for (final product in seedProducts) {
      batch.set(_col.doc('${product['id']}'), product);
    }
    await batch.commit();
  }
}
