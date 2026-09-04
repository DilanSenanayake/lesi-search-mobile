/// Mirrors website filter options and app config.
class AppConfig {
  AppConfig._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://www.lesisearch.com',
  );

  static const Duration evaluateTimeout = Duration(seconds: 120);
  static const Duration defaultTimeout = Duration(seconds: 30);

  static const List<({String value, String label})> vehicleTypes = [
    (value: '', label: 'Any type'),
    (value: 'car', label: 'Car'),
    (value: 'van', label: 'Van'),
    (value: 'suv_jeep', label: 'SUV / Jeep'),
    (value: 'motorcycle', label: 'Motorbike'),
    (value: 'pickup', label: 'Pickup / Double Cab'),
    (value: 'bus', label: 'Bus'),
    (value: 'lorry', label: 'Lorry'),
    (value: 'three_wheel', label: 'Three Wheel'),
    (value: 'bicycle', label: 'Bicycles'),
  ];

  static const List<String> makes = [
    'Toyota',
    'Suzuki',
    'Honda',
    'Nissan',
    'Mitsubishi',
    'Hyundai',
    'Kia',
    'BMW',
    'Mercedes-Benz',
    'Mazda',
    'Tata',
    'Isuzu',
    'Perodua',
    'Volkswagen',
    'Other',
  ];

  static const List<({String group, List<String> places})> locations = [
    (
      group: 'Colombo District',
      places: [
        'Colombo',
        'Maharagama',
        'Nugegoda',
        'Dehiwala-Mount-Lavinia',
      ],
    ),
    (group: 'Gampaha District', places: ['Gampaha']),
    (group: 'Kandy District', places: ['Kandy']),
    (group: 'Galle & South', places: ['Galle', 'Matara', 'Hambantota']),
    (
      group: 'Other',
      places: [
        'Kurunegala',
        'Anuradapura',
        'Badulla',
        'Trincomalee',
        'Jaffna',
      ],
    ),
  ];

  static List<int> yearChoices() {
    final current = DateTime.now().year;
    return List<int>.generate(current - 1979, (i) => current - i);
  }

  static String vehicleTypeLabel(String? value) {
    if (value == null || value.isEmpty) return 'Any type';
    for (final t in vehicleTypes) {
      if (t.value == value) return t.label;
    }
    return value;
  }
}
