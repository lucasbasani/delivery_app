import '../utils/formatters.dart';

class AddressModel {
  final String? id; // id do documento no Firestore (null antes de salvar)
  final String label; // apelido: Casa, Trabalho...
  final String cep; // só dígitos
  final String street;
  final String number;
  final String complement;
  final String district;
  final String city;
  final String uf;

  AddressModel({
    this.id,
    this.label = '',
    required this.cep,
    required this.street,
    required this.number,
    this.complement = '',
    required this.district,
    required this.city,
    required this.uf,
  });

  /// Linha única para mostrar o endereço nas listas e no pedido.
  String get summary {
    final comp = complement.isNotEmpty ? ' - $complement' : '';
    return '$street, $number$comp - $district, $city/$uf · CEP ${formatCep(cep)}';
  }

  factory AddressModel.fromMap(String? id, Map<String, dynamic> map) {
    return AddressModel(
      id: id,
      label: map['label'] ?? '',
      cep: map['cep'] ?? '',
      street: map['street'] ?? '',
      number: map['number'] ?? '',
      complement: map['complement'] ?? '',
      district: map['district'] ?? '',
      city: map['city'] ?? '',
      uf: map['uf'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'cep': cep,
      'street': street,
      'number': number,
      'complement': complement,
      'district': district,
      'city': city,
      'uf': uf,
    };
  }

  AddressModel copyWith({String? id, String? label}) {
    return AddressModel(
      id: id ?? this.id,
      label: label ?? this.label,
      cep: cep,
      street: street,
      number: number,
      complement: complement,
      district: district,
      city: city,
      uf: uf,
    );
  }
}
