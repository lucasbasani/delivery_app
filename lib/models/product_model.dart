import 'package:flutter/material.dart';

class ProductModel {
  final int id;
  final String name;
  final String description;
  final String category;
  final double price;
  final IconData icon;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.icon,
  });

  /// O Firestore não guarda IconData, então cada produto salva o nome
  /// do ícone e aqui ele é convertido de volta.
  static const Map<String, IconData> _icons = {
    'lunch_dining': Icons.lunch_dining,
    'fastfood': Icons.fastfood,
    'local_pizza': Icons.local_pizza,
    'local_drink': Icons.local_drink,
    'cake': Icons.cake,
  };

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: (map['id'] as num).toInt(),
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      price: (map['price'] as num).toDouble(),
      icon: _icons[map['icon']] ?? Icons.restaurant,
    );
  }
}
