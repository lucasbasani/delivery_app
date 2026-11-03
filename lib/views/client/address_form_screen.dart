import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/address_model.dart';
import '../../providers/address_provider.dart';
import '../../utils/validators.dart';
import '../../widgets/address_form_fields.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

/// Formulário para criar (address == null) ou editar um endereço salvo.
class AddressFormScreen extends StatefulWidget {
  final AddressModel? address;

  const AddressFormScreen({super.key, this.address});

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();
  final _fields = AddressControllers();
  bool _saving = false;

  bool get _isEditing => widget.address != null;

  @override
  void initState() {
    super.initState();
    final address = widget.address;
    if (address != null) {
      _labelController.text = address.label;
      _fields.fill(address);
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    _fields.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final address = _fields.toModel(
      id: widget.address?.id,
      label: _labelController.text.trim(),
    );
    final error = await context.read<AddressProvider>().save(address);

    if (!mounted) return;
    setState(() => _saving = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isEditing ? 'Endereço atualizado.' : 'Endereço salvo.'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar endereço' : 'Novo endereço'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              CustomTextField(
                controller: _labelController,
                label: 'Nome do endereço',
                hint: 'Ex.: Casa, Trabalho',
                prefixIcon: Icons.bookmark_outline,
                maxLength: 20,
                validator: (v) =>
                    Validators.requiredField(v, 'um nome para o endereço'),
              ),
              const SizedBox(height: 6),
              AddressFormFields(
                controllers: _fields,
                onUfChanged: (uf) => setState(() => _fields.uf = uf),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: _isEditing ? 'SALVAR ALTERAÇÕES' : 'SALVAR ENDEREÇO',
                isLoading: _saving,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
