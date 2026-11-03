import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/order_model.dart';
import '../../providers/order_provider.dart';
import '../../utils/formatters.dart';

/// Histórico de pedidos do usuário logado, lido do Firestore.
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().loadOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrderProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Meus pedidos')),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(OrderProvider provider) {
    if (provider.isLoading && provider.orders.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(
        child: TextButton.icon(
          onPressed: provider.loadOrders,
          icon: const Icon(Icons.refresh),
          label: Text('${provider.error} Tentar novamente'),
        ),
      );
    }

    if (provider.orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.receipt_long, size: 60, color: Colors.grey),
            const SizedBox(height: 10),
            const Text('Você ainda não fez pedidos.',
                style: TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Ver cardápio'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: provider.loadOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.orders.length,
        itemBuilder: (context, index) =>
            _OrderCard(order: provider.orders[index]),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final number = order.shortId;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: ExpansionTile(
        shape: const Border(),
        title: Text(
          'Pedido #$number · ${formatPrice(order.total)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${formatDateTime(order.createdAt)} · ${order.status}',
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...order.items.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(child: Text('${item.quantity}x ${item.name}')),
                  Text(formatPrice(item.total)),
                ],
              ),
            ),
          ),
          const Divider(height: 20),
          Text('Entrega: ${order.address.summary}'),
          const SizedBox(height: 4),
          Text('Recebedor: ${order.recipientName} · ${formatPhone(order.phone)}'),
          const SizedBox(height: 4),
          Text('Pagamento: ${order.paymentMethod.label}'
              '${order.changeFor != null ? ' (troco para ${formatPrice(order.changeFor!)})' : ''}'),
          if (order.notes.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text('Observações: ${order.notes}'),
          ],
          const SizedBox(height: 4),
          Text(
            'Subtotal ${formatPrice(order.subtotal)} + '
            'entrega ${formatPrice(order.deliveryFee)}',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
