import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/address_model.dart';
import '../utils/validators.dart';
import 'custom_text_field.dart';

/// Agrupa os controllers dos campos de endereço.
/// É usado tanto no checkout quanto no cadastro de endereços salvos.
class AddressControllers {
  final cep = TextEditingController();
  final street = TextEditingController();
  final number = TextEditingController();
  final complement = TextEditingController();
  final district = TextEditingController();
  final city = TextEditingController();
  String? uf;

  /// Preenche os campos com um endereço existente.
  void fill(AddressModel address) {
    cep.text = address.cep;
    street.text = address.street;
    number.text = address.number;
    complement.text = address.complement;
    district.text = address.district;
    city.text = address.city;
    // O dropdown só aceita um valor que esteja na lista de UFs
    uf = Validators.ufs.contains(address.uf) ? address.uf : null;
  }

  /// Monta o modelo com o que foi digitado (chamar após validar o Form).
  AddressModel toModel({String? id, String label = ''}) {
    return AddressModel(
      id: id,
      label: label,
      cep: Validators.onlyDigits(cep.text),
      street: street.text.trim(),
      number: number.text.trim().toUpperCase(),
      complement: complement.text.trim(),
      district: district.text.trim(),
      city: city.text.trim(),
      uf: uf ?? '',
    );
  }

  void dispose() {
    cep.dispose();
    street.dispose();
    number.dispose();
    complement.dispose();
    district.dispose();
    city.dispose();
  }
}

/// Campos de endereço com validação. Deve ficar dentro de um `Form`.
class AddressFormFields extends StatelessWidget {
  final AddressControllers controllers;
  final ValueChanged<String?> onUfChanged;

  const AddressFormFields({
    super.key,
    required this.controllers,
    required this.onUfChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextField(
          controller: controllers.cep,
          label: 'CEP',
          hint: 'Somente números',
          prefixIcon: Icons.markunread_mailbox_outlined,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(8),
          ],
          validator: Validators.cep,
        ),
        const SizedBox(height: 14),
        CustomTextField(
          controller: controllers.street,
          label: 'Rua',
          prefixIcon: Icons.signpost_outlined,
          textCapitalization: TextCapitalization.words,
          validator: (v) => Validators.requiredField(v, 'a rua'),
        ),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: CustomTextField(
                controller: controllers.number,
                label: 'Número',
                hint: 'Ex.: 410 ou S/N',
                prefixIcon: Icons.tag,
                validator: Validators.houseNumber,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: CustomTextField(
                controller: controllers.complement,
                label: 'Complemento',
                hint: 'Opcional',
                prefixIcon: Icons.apartment_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        CustomTextField(
          controller: controllers.district,
          label: 'Bairro',
          prefixIcon: Icons.location_city_outlined,
          textCapitalization: TextCapitalization.words,
          validator: (v) => Validators.requiredField(v, 'o bairro'),
        ),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: CustomTextField(
                controller: controllers.city,
                label: 'Cidade',
                prefixIcon: Icons.map_outlined,
                textCapitalization: TextCapitalization.words,
                validator: (v) => Validators.requiredField(v, 'a cidade'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: DropdownButtonFormField<String>(
                // A key muda quando o endereço é preenchido por código,
                // para o campo exibir o novo estado.
                key: ValueKey('uf-${controllers.uf}'),
                value: controllers.uf,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'UF'),
                items: Validators.ufs
                    .map((uf) => DropdownMenuItem(value: uf, child: Text(uf)))
                    .toList(),
                validator: Validators.uf,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onChanged: onUfChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
