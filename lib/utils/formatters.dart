import 'package:intl/intl.dart';

String formatMoney(int amount) {
  final negative = amount < 0;
  final digits = amount.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return '${negative ? '-' : ''}Rs $buffer';
}

String formatDate(DateTime? date) {
  if (date == null) return '—';
  return DateFormat('d MMM yyyy, h:mm a').format(date);
}

String formatStatus(String status) {
  return status
      .split('_')
      .map((part) => part.isEmpty ? part : '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}

String greetingFor(DateTime time) {
  final hour = time.hour;
  if (hour < 12) return 'Good morning';
  if (hour < 17) return 'Good afternoon';
  return 'Good evening';
}
