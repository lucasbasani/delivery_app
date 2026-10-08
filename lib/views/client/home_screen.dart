import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/product_card.dart';
import '../auth/login_screen.dart';
import 'cart_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  String _selectedCategory = 'Todos';
  String _searchText = '';

  final List<ProductModel> _products = [
    ProductModel(
      id: 1,
      name: 'Hambúrguer Clássico',
      description:
          'Pão, carne, queijo, alface e tomate.',
      category: 'Lanches',
      price: 25.90,
      icon: Icons.lunch_dining,
    ),
    ProductModel(
      id: 2,
      name: 'X-Salada',
      description:
          'Hambúrguer, queijo, alface, tomate e molho especial.',
      category: 'Lanches',
      price: 28.90,
      icon: Icons.fastfood,
    ),
    ProductModel(
      id: 3,
      name: 'Pizza Calabresa',
      description:
          'Molho de tomate, queijo e calabresa.',
      category: 'Pizzas',
      price: 39.90,
      icon: Icons.local_pizza,
    ),
    ProductModel(
      id: 4,
      name: 'Pizza Quatro Queijos',
      description:
          'Mussarela, provolone, parmesão e gorgonzola.',
      category: 'Pizzas',
      price: 44.90,
      icon: Icons.local_pizza,
    ),
    ProductModel(
      id: 5,
      name: 'Batata Frita',
      description:
          'Porção de batatas crocantes.',
      category: 'Porções',
      price: 18.90,
      icon: Icons.fastfood,
    ),
    ProductModel(
      id: 6,
      name: 'Refrigerante',
      description:
          'Refrigerante gelado 350ml.',
      category: 'Bebidas',
      price: 7.00,
      icon: Icons.local_drink,
    ),
    ProductModel(
      id: 7,
      name: 'Suco Natural',
      description:
          'Suco natural de laranja.',
      category: 'Bebidas',
      price: 9.90,
      icon: Icons.local_drink,
    ),
    ProductModel(
      id: 8,
      name: 'Brownie',
      description:
          'Brownie de chocolate com calda.',
      category: 'Sobremesas',
      price: 14.90,
      icon: Icons.cake,
    ),
  ];

  final List<String> _categories = [
    'Todos',
    'Lanches',
    'Pizzas',
    'Porções',
    'Bebidas',
    'Sobremesas',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ProductModel> get _filteredProducts {
    return _products.where((product) {
      final matchesCategory =
          _selectedCategory == 'Todos' ||
          product.category == _selectedCategory;

      final search = _searchText.toLowerCase();

      final matchesSearch =
          product.name.toLowerCase().contains(search) ||
          product.description
              .toLowerCase()
              .contains(search);

      return matchesCategory && matchesSearch;
    }).toList();
  }

  String formatPrice(double price) {
    return 'R\$ ${price.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  void _addToCart(ProductModel product) {
    context.read<CartProvider>().addProduct(product);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${product.name} foi adicionado à sacola!',
        ),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider =
        context.watch<AuthProvider>();

    final cartProvider =
        context.watch<CartProvider>();

    final userName =
        authProvider.user?.name ?? 'Cliente';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'PedeAi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                tooltip: 'Minha sacola',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const CartScreen(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.shopping_bag_outlined,
                ),
              ),

              if (cartProvider.totalItems > 0)
                Positioned(
                  right: 5,
                  top: 5,
                  child: Container(
                    padding:
                        const EdgeInsets.all(5),
                    decoration:
                        const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${cartProvider.totalItems}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                if (value == 'logout') {
  context.read<AuthProvider>().logout();
  context.read<CartProvider>().clearCart();

  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
      builder: (_) => const LoginScreen(),
    ),
    (route) => false,
  );
}
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(
                        Icons.logout,
                        color: Colors.red,
                      ),
                      SizedBox(width: 8),
                      Text('Sair'),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              18,
              16,
              10,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Olá, $userName! 👋',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'O que você deseja pedir hoje?',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 18),

                TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchText = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText:
                        'Buscar no PedeAi...',
                    prefixIcon: const Icon(
                      Icons.search,
                    ),
                    suffixIcon:
                        _searchText.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  _searchController
                                      .clear();

                                  setState(() {
                                    _searchText =
                                        '';
                                  });
                                },
                                icon: const Icon(
                                  Icons.clear,
                                ),
                              )
                            : null,
                  ),
                ),

                const SizedBox(height: 14),

                SizedBox(
                  height: 42,
                  child: ListView.separated(
                    scrollDirection:
                        Axis.horizontal,
                    itemCount: _categories.length,
                    separatorBuilder:
                        (_, __) =>
                            const SizedBox(
                      width: 8,
                    ),
                    itemBuilder:
                        (context, index) {
                      final category =
                          _categories[index];

                      final selected =
                          category ==
                              _selectedCategory;

                      return ChoiceChip(
                        label:
                            Text(category),
                        selected: selected,
                        onSelected: (_) {
                          setState(() {
                            _selectedCategory =
                                category;
                          });
                        },
                        selectedColor:
                            Colors.blue,
                        labelStyle: TextStyle(
                          color: selected
                              ? Colors.white
                              : Colors.black87,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: _filteredProducts.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 60,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Nenhum produto encontrado.',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding:
                        const EdgeInsets.fromLTRB(
                      16,
                      4,
                      16,
                      20,
                    ),
                    itemCount:
                        _filteredProducts.length,
                    itemBuilder:
                        (context, index) {
                      final product =
                          _filteredProducts[index];

                      return ProductCard(
                        product: product,
                        onAdd: () =>
                            _addToCart(product),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}