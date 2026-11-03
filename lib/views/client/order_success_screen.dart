import 'package:flutter/material.dart';

import '../../models/order_model.dart';
import '../../utils/formatters.dart';
import 'orders_screen.dart';

class OrderSuccessScreen extends StatelessWidget {
  final OrderModel order;

  const OrderSuccessScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final number = order.shortId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedido confirmado'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Icon(Icons.check_circle, color: Colors.green, size: 90),
              const SizedBox(height: 16),
              const Text(
                'Pedido realizado!',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'Pedido #$number',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _info(Icons.location_on_outlined, order.address.summary),
                      _info(order.paymentMethod.icon, order.paymentMethod.label),
                      if (order.changeFor != null)
                        _info(Icons.attach_money,
                            'Troco para ${formatPrice(order.changeFor!)}'),
                      _info(Icons.shopping_bag_outlined,
                          '${order.totalItems} item(ns) · total ${formatPrice(order.total)}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const OrdersScreen()),
                    );
                  },
                  icon: const Icon(Icons.receipt_long),
                  label: const Text('VER MEUS PEDIDOS'),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Voltar ao cardápio'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _info(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }
}
