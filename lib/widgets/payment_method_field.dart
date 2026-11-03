import 'package:flutter/material.dart';

import '../models/order_model.dart';

/// Campo de formulário para escolher a forma de pagamento.
/// Por ser um FormField, participa do `validate()` do Form:
/// o pedido não é enviado sem uma forma de pagamento escolhida.
class PaymentMethodField extends FormField<PaymentMethod> {
  PaymentMethodField({
    super.key,
    super.initialValue,
    required ValueChanged<PaymentMethod> onChanged,
  }) : super(
          validator: (value) =>
              value == null ? 'Escolha a forma de pagamento' : null,
          builder: (state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...PaymentMethod.values.map((method) {
                  final selected = state.value == method;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    elevation: 0,
                    color: selected ? Colors.blue.shade50 : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: selected ? Colors.blue : Colors.grey.shade300,
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: ListTile(
                      leading: Icon(method.icon, color: Colors.blue),
                      title: Text(method.label),
                      trailing: Icon(
                        selected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: selected ? Colors.blue : Colors.grey,
                      ),
                      onTap: () {
                        state.didChange(method);
                        onChanged(method);
                      },
                    ),
                  );
                }),
                if (state.hasError)
                  Padding(
                    padding: const EdgeInsets.only(left: 12, top: 4),
                    child: Text(
                      state.errorText!,
                      style: TextStyle(
                        color: Theme.of(state.context).colorScheme.error,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            );
          },
        );
}
