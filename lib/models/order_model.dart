import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'address_model.dart';

/// Formas de pagamento aceitas. Cartões são pagos na entrega
/// (o app não coleta dados de cartão).
enum PaymentMethod { pix, credito, debito, dinheiro }

extension PaymentMethodInfo on PaymentMethod {
  String get label {
    switch (this) {
      case PaymentMethod.pix:
        return 'Pix';
      case PaymentMethod.credito:
        return 'Cartão de crédito (na entrega)';
      case PaymentMethod.debito:
        return 'Cartão de débito (na entrega)';
      case PaymentMethod.dinheiro:
        return 'Dinheiro';
    }
  }

  IconData get icon {
    switch (this) {
      case PaymentMethod.pix:
        return Icons.qr_code_2;
      case PaymentMethod.credito:
      case PaymentMethod.debito:
        return Icons.credit_card;
      case PaymentMethod.dinheiro:
        return Icons.payments_outlined;
    }
  }

  /// Converte o texto salvo no banco de volta para o enum.
  static PaymentMethod? fromName(String? name) {
    for (final method in PaymentMethod.values) {
      if (method.name == name) return method;
    }
    return null;
  }
}

class OrderItem {
  final int productId;
  final String name;
  final double price;
  final int quantity;

  OrderItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
  });

  double get total => price * quantity;

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: (map['productId'] as num).toInt(),
      name: map['name'] ?? '',
      price: (map['price'] as num).toDouble(),
      quantity: (map['quantity'] as num).toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }
}

class OrderModel {
  final String? id;
  final String userId;
  final List<OrderItem> items;
  final String recipientName;
  final String phone;
  final AddressModel address;
  final PaymentMethod paymentMethod;
  final double? changeFor; // troco para (só em dinheiro)
  final String notes;
  final double subtotal;
  final double deliveryFee;
  final String status;
  final DateTime createdAt;

  OrderModel({
    this.id,
    required this.userId,
    required this.items,
    required this.recipientName,
    required this.phone,
    required this.address,
    required this.paymentMethod,
    this.changeFor,
    this.notes = '',
    required this.subtotal,
    required this.deliveryFee,
    this.status = 'Recebido',
    required this.createdAt,
  });

  double get total => subtotal + deliveryFee;

  /// Número curto para exibir (6 primeiros caracteres do id do Firestore).
  String get shortId {
    final value = id ?? '';
    return (value.length > 6 ? value.substring(0, 6) : value).toUpperCase();
  }

  int get totalItems =>
      items.fold<int>(0, (sum, item) => sum + item.quantity);

  factory OrderModel.fromMap(String id, Map<String, dynamic> map) {
    final created = map['createdAt'];
    return OrderModel(
      id: id,
      userId: map['userId'] ?? '',
      items: ((map['items'] as List<dynamic>?) ?? [])
          .map((e) => OrderItem.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      recipientName: map['recipientName'] ?? '',
      phone: map['phone'] ?? '',
      address: AddressModel.fromMap(
        null,
        Map<String, dynamic>.from(map['address'] ?? {}),
      ),
      paymentMethod: PaymentMethodInfo.fromName(map['paymentMethod']) ??
          PaymentMethod.pix,
      changeFor: (map['changeFor'] as num?)?.toDouble(),
      notes: map['notes'] ?? '',
      subtotal: ((map['subtotal'] as num?) ?? 0).toDouble(),
      deliveryFee: ((map['deliveryFee'] as num?) ?? 0).toDouble(),
      status: map['status'] ?? 'Recebido',
      createdAt: created is Timestamp ? created.toDate() : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'recipientName': recipientName,
      'phone': phone,
      'address': address.toMap(),
      'paymentMethod': paymentMethod.name,
      'changeFor': changeFor,
      'notes': notes,
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'total': total,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  OrderModel copyWithId(String newId) {
    return OrderModel(
      id: newId,
      userId: userId,
      items: items,
      recipientName: recipientName,
      phone: phone,
      address: address,
      paymentMethod: paymentMethod,
      changeFor: changeFor,
      notes: notes,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      status: status,
      createdAt: createdAt,
    );
  }
}
