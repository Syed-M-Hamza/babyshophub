import '../utils/parsers.dart';

class Address {
  const Address({
    required this.id,
    required this.label,
    required this.fullName,
    required this.phone,
    required this.line,
    required this.city,
    required this.postalCode,
    required this.isDefault,
  });

  final String id;
  final String label;
  final String fullName;
  final String phone;
  final String line;
  final String city;
  final String postalCode;
  final bool isDefault;

  String get summary => '$line, $city $postalCode';

  Address copyWith({bool? isDefault}) {
    return Address(
      id: id,
      label: label,
      fullName: fullName,
      phone: phone,
      line: line,
      city: city,
      postalCode: postalCode,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  factory Address.fromDoc(String id, Map<String, dynamic> data) {
    return Address(
      id: id,
      label: (data['label'] as String?) ?? 'Home',
      fullName: (data['fullName'] as String?) ?? '',
      phone: (data['phone'] as String?) ?? '',
      line: (data['line'] as String?) ?? '',
      city: (data['city'] as String?) ?? '',
      postalCode: (data['postalCode'] as String?) ?? '',
      isDefault: readBool(data['isDefault']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'fullName': fullName,
      'phone': phone,
      'line': line,
      'city': city,
      'postalCode': postalCode,
      'isDefault': isDefault,
    };
  }
}
