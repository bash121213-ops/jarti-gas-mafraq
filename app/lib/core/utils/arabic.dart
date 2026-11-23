/// Arabic text, phone and money helpers. UI strings stay Arabic; identifiers
/// and comments stay English.
library;

const List<String> _arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
const List<String> _persianDigits = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];

/// Converts Arabic-Indic and Persian digits typed on some keyboards to ASCII.
String normalizeDigits(String input) {
  final buffer = StringBuffer();
  for (final rune in input.runes) {
    final char = String.fromCharCode(rune);
    final arabicIndex = _arabicDigits.indexOf(char);
    final persianIndex = _persianDigits.indexOf(char);
    if (arabicIndex >= 0) {
      buffer.write(arabicIndex);
    } else if (persianIndex >= 0) {
      buffer.write(persianIndex);
    } else {
      buffer.write(char);
    }
  }
  return buffer.toString();
}

/// Normalizes a Jordanian mobile number to the local `07XXXXXXXX` form.
///
/// Accepts spaces, dashes, a leading `+962` or `00962` and Arabic digits.
String normalizePhone(String raw) {
  var value = normalizeDigits(raw);
  value = value.replaceAll(RegExp(r'[\s\-()]'), '');
  if (value.startsWith('+962')) {
    value = value.substring(4);
  } else if (value.startsWith('00962')) {
    value = value.substring(5);
  } else if (value.startsWith('962')) {
    value = value.substring(3);
  }
  if (value.startsWith('7')) {
    value = '0$value';
  }
  return value;
}

/// Jordanian mobiles start with 077, 078 or 079 and have ten digits.
bool isValidJordanMobile(String normalized) =>
    RegExp(r'^07[789]\d{7}$').hasMatch(normalized);

/// Formats a phone number for display, e.g. `079 123 4567`.
String formatPhone(String normalized) {
  if (normalized.length != 10) return normalized;
  return '${normalized.substring(0, 3)} ${normalized.substring(3, 6)} '
      '${normalized.substring(6)}';
}

/// Money is always shown with two decimals and the Jordanian dinar symbol.
String formatMoney(double value) => '${value.toStringAsFixed(2)} د.أ';

/// Arabic-friendly cylinder count, e.g. `أسطوانة واحدة`, `أسطوانتان`,
/// `٣ أسطوانات`.
String cylinderCountLabel(int count) {
  switch (count) {
    case 0:
      return 'لا أسطوانات';
    case 1:
      return 'أسطوانة واحدة';
    case 2:
      return 'أسطوانتان';
    default:
      return '$count أسطوانات';
  }
}

/// Short time label such as `٩:٤١ ص`. Uses Western digits to match prices.
String formatTimeOfDay(DateTime time) {
  final hour24 = time.hour;
  final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
  final minutes = time.minute.toString().padLeft(2, '0');
  final suffix = hour24 < 12 ? 'ص' : 'م';
  return '$hour12:$minutes $suffix';
}

String formatDate(DateTime time) {
  final months = [
    'كانون الثاني', 'شباط', 'آذار', 'نيسان', 'أيار', 'حزيران',
    'تموز', 'آب', 'أيلول', 'تشرين الأول', 'تشرين الثاني', 'كانون الأول',
  ];
  return '${time.day} ${months[time.month - 1]} ${time.year}';
}
