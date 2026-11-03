import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/address_model.dart';
import '../../providers/address_provider.dart';
import 'address_form_screen.dart';

/// Lista dos endereços salvos, com criar, editar e excluir.
class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AddressProvider>().loadAddresses();
    });
  }

  void _openForm([AddressModel? address]) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddressFormScreen(address: address)),
    );
  }

  Future<void> _delete(AddressModel address) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir endereço'),
        content: Text('Deseja excluir "${address.label}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    final error = await context.read<AddressProvider>().delete(address.id!);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ?? 'Endereço excluído.'),
        backgroundColor: error == null ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AddressProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Meus endereços')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Novo endereço'),
      ),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(AddressProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(
        child: TextButton.icon(
          onPressed: provider.loadAddresses,
          icon: const Icon(Icons.refresh),
          label: Text('${provider.error} Tentar novamente'),
        ),
      );
    }

    if (provider.addresses.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Nenhum endereço salvo.\n'
            'Cadastre um aqui ou marque "Salvar endereço" no checkout.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
      itemCount: provider.addresses.length,
      itemBuilder: (context, index) {
        final address = provider.addresses[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          child: ListTile(
            leading: const Icon(Icons.location_on, color: Colors.blue),
            title: Text(
              address.label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(address.summary),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Editar',
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => _openForm(address),
                ),
                IconButton(
                  tooltip: 'Excluir',
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _delete(address),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
