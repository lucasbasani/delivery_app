import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/product_model.dart';
import '../../providers/address_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/product_card.dart';
import 'addresses_screen.dart';
import 'cart_screen.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _selectedCategory = 'Todos';
  String _searchText = '';

  final List<String> _categories = [
    'Todos',
    'Lanches',
    'Pizzas',
    'Porções',
    'Bebidas',
    'Sobremesas',
  ];

  @override
  void initState() {
    super.initState();
    // Busca o cardápio no Firestore depois que a tela é montada.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ProductModel> _filter(List<ProductModel> products) {
    final search = _searchText.toLowerCase();

    return products.where((product) {
      final matchesCategory = _selectedCategory == 'Todos' ||
          product.category == _selectedCategory;

      final matchesSearch = product.name.toLowerCase().contains(search) ||
          product.description.toLowerCase().contains(search);

      return matchesCategory && matchesSearch;
    }).toList();
  }

  void _addToCart(ProductModel product) {
    context.read<CartProvider>().addProduct(product);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} foi adicionado à sacola!'),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _open(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sair da conta'),
        content: const Text('Deseja realmente sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Sair', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    context.read<CartProvider>().clearCart();
    context.read<OrderProvider>().clear();
    context.read<AddressProvider>().clear();
    // O AuthGate volta para o login automaticamente.
    await context.read<AuthProvider>().logout();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final cartProvider = context.watch<CartProvider>();
    final productProvider = context.watch<ProductProvider>();

    final userName = authProvider.user?.name ?? 'Cliente';
    final filteredProducts = _filter(productProvider.products);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'PedeAi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                tooltip: 'Minha sacola',
                onPressed: () => _open(const CartScreen()),
                icon: const Icon(Icons.shopping_bag_outlined),
              ),
              if (cartProvider.totalItems > 0)
                Positioned(
                  right: 5,
                  top: 5,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
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
              switch (value) {
                case 'orders':
                  _open(const OrdersScreen());
                  break;
                case 'addresses':
                  _open(const AddressesScreen());
                  break;
                case 'profile':
                  _open(const ProfileScreen());
                  break;
                case 'logout':
                  _logout();
                  break;
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'orders',
                child: _MenuItem(Icons.receipt_long, 'Meus pedidos'),
              ),
              PopupMenuItem(
                value: 'addresses',
                child: _MenuItem(Icons.location_on_outlined, 'Meus endereços'),
              ),
              PopupMenuItem(
                value: 'profile',
                child: _MenuItem(Icons.person_outline, 'Minha conta'),
              ),
              PopupMenuItem(
                value: 'logout',
                child: _MenuItem(Icons.logout, 'Sair', color: Colors.red),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                    hintText: 'Buscar no PedeAi...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchText.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchText = '';
                              });
                            },
                            icon: const Icon(Icons.clear),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 42,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final selected = category == _selectedCategory;

                      return ChoiceChip(
                        label: Text(category),
                        selected: selected,
                        onSelected: (_) {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                        selectedColor: Colors.blue,
                        labelStyle: TextStyle(
                          color: selected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildProductList(productProvider, filteredProducts),
          ),
        ],
      ),
    );
  }

  /// Lista com os estados de carregamento, erro e lista vazia.
  Widget _buildProductList(
    ProductProvider provider,
    List<ProductModel> products,
  ) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 60, color: Colors.grey),
            const SizedBox(height: 10),
            Text(provider.error!, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: provider.loadProducts,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (products.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 60, color: Colors.grey),
            SizedBox(height: 10),
            Text('Nenhum produto encontrado.', style: TextStyle(fontSize: 16)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: provider.loadProducts,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return ProductCard(
            product: product,
            onAdd: () => _addToCart(product),
          );
        },
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;

  const _MenuItem(this.icon, this.text, {this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color ?? Colors.black87),
        const SizedBox(width: 10),
        Text(text),
      ],
    );
  }
}
