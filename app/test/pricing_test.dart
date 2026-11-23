import 'package:flutter_test/flutter_test.dart';
import 'package:jarti/core/utils/arabic.dart';
import 'package:jarti/data/models/pricing.dart';

void main() {
  group('Pricing', () {
    const pricing = Pricing(cylinderPrice: 7.00, deliveryFee: 0.10);

    test('one cylinder costs 7.10', () {
      expect(pricing.totalFor(1), closeTo(7.10, 0.0001));
    });

    test('two cylinders cost 14.10 (delivery charged once)', () {
      expect(pricing.totalFor(2), closeTo(14.10, 0.0001));
    });

    test('four cylinders cost 28.10', () {
      expect(pricing.totalFor(4), closeTo(28.10, 0.0001));
    });

    test('money is always formatted with two decimals', () {
      expect(formatMoney(pricing.totalFor(1)), '7.10 د.أ');
    });
  });

  group('Jordanian phone numbers', () {
    test('normalizes local, international and Arabic-digit input', () {
      expect(normalizePhone('079 123 4567'), '0791234567');
      expect(normalizePhone('+962 79 123 4567'), '0791234567');
      expect(normalizePhone('٠٧٩١٢٣٤٥٦٧'), '0791234567');
    });

    test('accepts 077, 078 and 079 prefixes only', () {
      expect(isValidJordanMobile('0771234567'), isTrue);
      expect(isValidJordanMobile('0781234567'), isTrue);
      expect(isValidJordanMobile('0791234567'), isTrue);
      expect(isValidJordanMobile('0711234567'), isFalse);
      expect(isValidJordanMobile('079123456'), isFalse);
    });
  });

  group('Arabic labels', () {
    test('cylinder counts use dual and plural forms', () {
      expect(cylinderCountLabel(1), 'أسطوانة واحدة');
      expect(cylinderCountLabel(2), 'أسطوانتان');
      expect(cylinderCountLabel(3), '3 أسطوانات');
    });
  });
}
