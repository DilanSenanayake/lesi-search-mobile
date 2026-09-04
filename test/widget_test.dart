import 'package:flutter_test/flutter_test.dart';
import 'package:lesi_search_mobile/models/models.dart';

void main() {
  test('placeholder keeps suite green', () {
    expect(SearchFilters(vehicleType: 'car').vehicleType, 'car');
  });
}
