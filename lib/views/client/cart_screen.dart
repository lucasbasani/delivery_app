import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import '../../widgets/cart_item_card.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  String formatPrice(double price) {
    return 'R\$ ${price.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  void _finishOrder(
    BuildContext context,
    CartProvider cart,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
              ),
              SizedBox(width: 8),
              Text('Pedido realizado!'),
            ],
          ),
          content: Text(
            'Seu pedido no valor de ${formatPrice(cart.total)} '
            'foi registrado com sucesso.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    ).then((_) {
      cart.clearCart();

      if (context.mounted) {
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Minha Sacola',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: cart.items.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.shopping_bag_outlined,
                        size: 60,
                        color: Colors.blue,
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Sua sacola está vazia',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Adicione produtos para começar seu pedido.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 24),

                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.restaurant_menu,
                      ),
                      label: const Text(
                        'VER CARDÁPIO',
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items[index];

                      return CartItemCard(
                        item: item,
                        onIncrease: () {
                          cart.increaseQuantity(
                            item.product,
                          );
                        },
                        onDecrease: () {
                          cart.decreaseQuantity(
                            item.product,
                          );
                        },
                        onRemove: () {
                          cart.removeProduct(
                            item.product,
                          );
                        },
                      );
                    },
                  ),
                ),

                Container(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    18,
                    20,
                    24,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withOpacity(0.08),
                        blurRadius: 10,
                        offset:
                            const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          children: [
                            const Text(
                              'Quantidade de itens',
                              style: TextStyle(
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              '${cart.totalItems}',
                              style:
                                  const TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          children: [
                            const Text(
                              'Subtotal',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              formatPrice(
                                cart.total,
                              ),
                              style:
                                  const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),

                        const Divider(
                          height: 25,
                        ),

                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          children: [
                            const Text(
                              'TOTAL',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                            Text(
                              formatPrice(
                                cart.total,
                              ),
                              style:
                                  const TextStyle(
                                fontSize: 22,
                                fontWeight:
                                    FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _finishOrder(
                                context,
                                cart,
                              );
                            },
                            icon: const Icon(
                              Icons.check,
                            ),
                            label: const Text(
                              'FINALIZAR PEDIDO',
                              style: TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}