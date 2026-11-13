import 'package:cloud_firestore/cloud_firestore.dart';

int readInt(dynamic value, [int fallback = 0]) {
  if (value is int) return value;
  if (value is num) return value.round();
  return fallback;
}

double readDouble(dynamic value, [double fallback = 0]) {
  if (value is num) return value.toDouble();
  return fallback;
}

bool readBool(dynamic value, [bool fallback = false]) {
  if (value is bool) return value;
  return fallback;
}

DateTime? readDate(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  return null;
}

List<String> readStringList(dynamic value) {
  if (value is List) {
    return value.map((item) => item.toString()).where((item) => item.isNotEmpty).toList();
  }
  return const [];
}
