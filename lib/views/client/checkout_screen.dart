import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/address_model.dart';
import '../../models/order_model.dart';
import '../../providers/address_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../services/preferences_service.dart';
import '../../utils/formatters.dart';
import '../../utils/validators.dart';
import '../../widgets/address_form_fields.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/payment_method_field.dart';
import 'order_success_screen.dart';

/// Taxa de entrega fixa do restaurante.
const double kDeliveryFee = 6.00;

/// Formulário de finalização: contato, endereço de entrega,
/// forma de pagamento e observações. Ao confirmar, o pedido
/// é salvo na coleção `orders` do Firestore.
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _address = AddressControllers();
  final _labelController = TextEditingController();
  final _changeController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedAddressId; // endereço salvo escolhido
  bool _saveAddress = false;
  PaymentMethod? _payment;

  @override
  void initState() {
    super.initState();

    // Contato preenchido com os dados do perfil
    final user = context.read<AuthProvider>().user;
    _nameController.text = user?.name ?? '';
    _phoneController.text = user?.phone ?? '';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AddressProvider>().loadAddresses();
      _loadLastPayment();
    });
  }

  /// Sugere a última forma de pagamento usada (SharedPreferences).
  Future<void> _loadLastPayment() async {
    final name =
        await context.read<PreferencesService>().getLastPaymentMethod();
    final method = PaymentMethodInfo.fromName(name);
    if (!mounted || method == null) return;
    setState(() {
      _payment = method;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _address.dispose();
    _labelController.dispose();
    _changeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _useSavedAddress(AddressModel address) {
    setState(() {
      _selectedAddressId = address.id;
      _address.fill(address);
      _saveAddress = false;
    });
  }

  void _useNewAddress() {
    setState(() {
      _selectedAddressId = null;
      _address.fill(AddressModel(
        cep: '',
        street: '',
        number: '',
        district: '',
        city: '',
        uf: '',
      ));
    });
  }

  String? _validateChange(String? value, double total) {
    if (value == null || value.trim().isEmpty) {
      return null; // troco é opcional
    }
    final amount = parseMoney(value);
    if (amount == null) {
      return 'Valor inválido';
    }
    if (amount < total) {
      return 'Deve ser maior ou igual ao total (${formatPrice(total)})';
    }
    return null;
  }

  Future<void> _submit() async {
    final cart = context.read<CartProvider>();
    if (cart.items.isEmpty) return;

    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Confira os campos destacados em vermelho.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final user = context.read<AuthProvider>().user!;
    final orderProvider = context.read<OrderProvider>();
    final addressProvider = context.read<AddressProvider>();
    final prefs = context.read<PreferencesService>();

    final address = _address.toModel();
    final payment = _payment!;

    final order = OrderModel(
      userId: user.uid,
      items: cart.items
          .map((item) => OrderItem(
                productId: item.product.id,
                name: item.product.name,
                price: item.product.price,
                quantity: item.quantity,
              ))
          .toList(),
      recipientName: _nameController.text.trim(),
      phone: Validators.onlyDigits(_phoneController.text),
      address: address,
      paymentMethod: payment,
      changeFor: payment == PaymentMethod.dinheiro
          ? parseMoney(_changeController.text)
          : null,
      notes: _notesController.text.trim(),
      subtotal: cart.total,
      deliveryFee: kDeliveryFee,
      createdAt: DateTime.now(),
    );

    final saved = await orderProvider.placeOrder(order);

    if (saved == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(orderProvider.error ?? 'Erro ao enviar o pedido.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_saveAddress && _selectedAddressId == null) {
      await addressProvider.save(
        address.copyWith(label: _labelController.text.trim()),
      );
    }
    await prefs.setLastPaymentMethod(payment.name);

    if (!mounted) return;

    // Vai para a confirmação, deixando só o cardápio por baixo.
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => OrderSuccessScreen(order: saved)),
      (route) => route.isFirst,
    );
    cart.clearCart();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final addressProvider = context.watch<AddressProvider>();
    final isSending = context.watch<OrderProvider>().isLoading;
    final total = cart.total + kDeliveryFee;

    return Scaffold(
      appBar: AppBar(title: const Text('Finalizar pedido')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ===== CONTATO =====
              const _SectionTitle(Icons.person_outline, 'Quem vai receber'),
              CustomTextField(
                controller: _nameController,
                label: 'Nome',
                prefixIcon: Icons.badge_outlined,
                textCapitalization: TextCapitalization.words,
                validator: Validators.name,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _phoneController,
                label: 'Telefone (com DDD)',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                ],
                validator: Validators.phone,
              ),

              // ===== ENDEREÇO =====
              const _SectionTitle(Icons.location_on_outlined, 'Endereço de entrega'),
              if (addressProvider.addresses.isNotEmpty) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    ...addressProvider.addresses.map(
                      (a) => ChoiceChip(
                        label: Text(a.label.isEmpty ? 'Endereço' : a.label),
                        selected: _selectedAddressId == a.id,
                        onSelected: (_) => _useSavedAddress(a),
                      ),
                    ),
                    ChoiceChip(
                      label: const Text('Novo endereço'),
                      selected: _selectedAddressId == null,
                      onSelected: (_) => _useNewAddress(),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
              ],
              AddressFormFields(
                controllers: _address,
                onUfChanged: (uf) => setState(() => _address.uf = uf),
              ),
              if (_selectedAddressId == null) ...[
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  value: _saveAddress,
                  title: const Text('Salvar este endereço para os próximos pedidos'),
                  onChanged: (value) {
                    setState(() {
                      _saveAddress = value ?? false;
                    });
                  },
                ),
                if (_saveAddress)
                  CustomTextField(
                    controller: _labelController,
                    label: 'Nome do endereço',
                    hint: 'Ex.: Casa, Trabalho',
                    prefixIcon: Icons.bookmark_outline,
                    maxLength: 20,
                    validator: (v) =>
                        Validators.requiredField(v, 'um nome para o endereço'),
                  ),
              ],

              // ===== PAGAMENTO =====
              const _SectionTitle(Icons.payment, 'Forma de pagamento'),
              PaymentMethodField(
                key: ValueKey(_payment),
                initialValue: _payment,
                onChanged: (method) {
                  setState(() {
                    _payment = method;
                  });
                },
              ),
              if (_payment == PaymentMethod.dinheiro) ...[
                const SizedBox(height: 6),
                CustomTextField(
                  controller: _changeController,
                  label: 'Troco para quanto?',
                  hint: 'Deixe em branco se não precisar',
                  prefixIcon: Icons.attach_money,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                  validator: (v) => _validateChange(v, total),
                ),
              ],

              // ===== OBSERVAÇÕES =====
              const _SectionTitle(Icons.notes, 'Observações'),
              CustomTextField(
                controller: _notesController,
                label: 'Observações do pedido',
                hint: 'Ex.: sem cebola, interfone quebrado...',
                prefixIcon: Icons.edit_note,
                maxLines: 3,
                maxLength: 200,
              ),

              // ===== RESUMO =====
              const _SectionTitle(Icons.receipt_long, 'Resumo'),
              _OrderSummary(cart: cart, total: total),
              const SizedBox(height: 20),
              CustomButton(
                text: 'CONFIRMAR PEDIDO · ${formatPrice(total)}',
                isLoading: isSending,
                onPressed: cart.items.isEmpty ? null : _submit,
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String text;

  const _SectionTitle(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _OrderSummary extends StatelessWidget {
  final CartProvider cart;
  final double total;

  const _OrderSummary({required this.cart, required this.total});

  Widget _row(String label, String value, {bool bold = false}) {
    final style = TextStyle(
      fontSize: bold ? 18 : 15,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(child: Text(label, style: style)),
          Text(value, style: style),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ...cart.items.map(
              (item) => _row(
                '${item.quantity}x ${item.product.name}',
                formatPrice(item.total),
              ),
            ),
            const Divider(height: 20),
            _row('Subtotal', formatPrice(cart.total)),
            _row('Taxa de entrega', formatPrice(kDeliveryFee)),
            const Divider(height: 20),
            _row('Total', formatPrice(total), bold: true),
          ],
        ),
      ),
    );
  }
}
