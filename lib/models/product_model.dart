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
}