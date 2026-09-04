import 'package:flutter_test/flutter_test.dart';
import 'package:lesi_search_mobile/models/models.dart';

void main() {
  test('SearchFilters omits empty optionals', () {
    final json = SearchFilters(
      make: 'Toyota',
      model: '',
      vehicleType: 'car',
      maxPages: 2,
    ).toJson();

    expect(json['make'], 'Toyota');
    expect(json.containsKey('model'), false);
    expect(json['vehicle_type'], 'car');
    expect(json['max_pages'], 2);
  });

  test('RankedVehicle priceLabel formats integers', () {
    final v = RankedVehicle(rank: 1, price: 4500000);
    expect(v.priceLabel, 'Rs 4,500,000');
  });

  test('EvaluateResult parses ranked list', () {
    final result = EvaluateResult.fromJson({
      'meta': {'total_from_search': 10, 'duration_ms': 1000},
      'filters': {'make': 'Toyota'},
      'search_links': {},
      'data': {
        'ranked_vehicles': [
          {'rank': 1, 'name': 'Aqua', 'price': 5000000},
        ],
      },
    });
    expect(result.vehicles, hasLength(1));
    expect(result.vehicles.first.name, 'Aqua');
    expect(result.totalFromSearch, 10);
  });
}
