class ApiException implements Exception {
  ApiException({
    required this.message,
    this.code,
    this.statusCode,
    this.details = const {},
  });

  final String message;
  final String? code;
  final int? statusCode;
  final Map<String, dynamic> details;

  bool get isUnauthorized =>
      statusCode == 401 || code == 'unauthorized' || code == 'token_expired';

  @override
  String toString() => message;
}

class UserProfile {
  UserProfile({
    required this.id,
    required this.email,
    this.firstName = '',
    this.lastName = '',
    this.displayName = '',
    this.emailVerified = false,
    this.phoneNumber = '',
  });

  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String displayName;
  final bool emailVerified;
  final String phoneNumber;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as int? ?? 0,
      email: (json['email'] ?? '').toString(),
      firstName: (json['first_name'] ?? '').toString(),
      lastName: (json['last_name'] ?? '').toString(),
      displayName: (json['display_name'] ?? '').toString(),
      emailVerified: json['email_verified'] == true,
      phoneNumber: (json['phone_number'] ?? '').toString(),
    );
  }

  String get fullName {
    final combined = '$firstName $lastName'.trim();
    if (combined.isNotEmpty) return combined;
    if (displayName.isNotEmpty) return displayName;
    return email;
  }
}

class SearchFilters {
  SearchFilters({
    this.make,
    this.model,
    this.location,
    this.vehicleType = 'any',
    this.minPrice,
    this.maxPrice,
    this.minYear,
    this.maxYear,
    this.maxPages = 3,
  });

  final String? make;
  final String? model;
  final String? location;
  final String vehicleType;
  final int? minPrice;
  final int? maxPrice;
  final int? minYear;
  final int? maxYear;
  final int maxPages;

  Map<String, dynamic> toJson() {
    return {
      if (make != null && make!.trim().isNotEmpty) 'make': make!.trim(),
      if (model != null && model!.trim().isNotEmpty) 'model': model!.trim(),
      if (location != null && location!.trim().isNotEmpty)
        'location': location!.trim(),
      'vehicle_type': vehicleType,
      if (minPrice != null) 'min_price': minPrice,
      if (maxPrice != null) 'max_price': maxPrice,
      if (minYear != null) 'min_year': minYear,
      if (maxYear != null) 'max_year': maxYear,
      'max_pages': maxPages,
    };
  }

  SearchFilters copyWith({
    String? make,
    String? model,
    String? location,
    String? vehicleType,
    int? minPrice,
    int? maxPrice,
    int? minYear,
    int? maxYear,
    int? maxPages,
    bool clearMinPrice = false,
    bool clearMaxPrice = false,
    bool clearMinYear = false,
    bool clearMaxYear = false,
  }) {
    return SearchFilters(
      make: make ?? this.make,
      model: model ?? this.model,
      location: location ?? this.location,
      vehicleType: vehicleType ?? this.vehicleType,
      minPrice: clearMinPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: clearMaxPrice ? null : (maxPrice ?? this.maxPrice),
      minYear: clearMinYear ? null : (minYear ?? this.minYear),
      maxYear: clearMaxYear ? null : (maxYear ?? this.maxYear),
      maxPages: maxPages ?? this.maxPages,
    );
  }
}

class RankedVehicle {
  RankedVehicle({
    required this.rank,
    this.name,
    this.source,
    this.url,
    this.price,
    this.year,
    this.mileage,
    this.postedDays,
    this.postedDate,
    this.location,
    this.thumbnailUrl,
    this.make,
    this.model,
    this.gear,
    this.fuelType,
    this.engineCc,
    this.options,
    this.details,
    this.contact,
  });

  final int rank;
  final String? name;
  final String? source;
  final String? url;
  final dynamic price;
  final dynamic year;
  final dynamic mileage;
  final dynamic postedDays;
  final String? postedDate;
  final String? location;
  final String? thumbnailUrl;
  final String? make;
  final String? model;
  final String? gear;
  final String? fuelType;
  final dynamic engineCc;
  final dynamic options;
  final dynamic details;
  final dynamic contact;

  factory RankedVehicle.fromJson(Map<String, dynamic> json) {
    return RankedVehicle(
      rank: json['rank'] as int? ?? 0,
      name: json['name']?.toString(),
      source: json['source']?.toString(),
      url: json['url']?.toString(),
      price: json['price'],
      year: json['year'],
      mileage: json['mileage'],
      postedDays: json['posted_days'],
      postedDate: json['posted_date']?.toString(),
      location: json['location']?.toString(),
      thumbnailUrl: json['thumbnail_url']?.toString(),
      make: json['make']?.toString(),
      model: json['model']?.toString(),
      gear: json['gear']?.toString(),
      fuelType: json['fuel_type']?.toString(),
      engineCc: json['engine_cc'],
      options: json['options'],
      details: json['details'],
      contact: json['contact'],
    );
  }

  String get priceLabel {
    if (price == null) return 'Negotiable';
    final n = int.tryParse(price.toString().replaceAll(',', ''));
    if (n == null) return price.toString();
    return 'Rs ${_formatNumber(n)}';
  }

  static String _formatNumber(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

class EvaluateResult {
  EvaluateResult({
    required this.vehicles,
    required this.filters,
    required this.totalFromSearch,
    required this.durationMs,
    this.searchLinks = const {},
  });

  final List<RankedVehicle> vehicles;
  final Map<String, dynamic> filters;
  final int totalFromSearch;
  final int durationMs;
  final Map<String, dynamic> searchLinks;

  factory EvaluateResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final ranked = (data['ranked_vehicles'] as List<dynamic>? ?? [])
        .whereType<Map>()
        .map((e) => RankedVehicle.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    final meta = json['meta'] as Map<String, dynamic>? ?? {};
    return EvaluateResult(
      vehicles: ranked,
      filters: Map<String, dynamic>.from(json['filters'] as Map? ?? {}),
      totalFromSearch: meta['total_from_search'] as int? ?? 0,
      durationMs: meta['duration_ms'] as int? ?? 0,
      searchLinks: Map<String, dynamic>.from(json['search_links'] as Map? ?? {}),
    );
  }
}

class AlertSubscription {
  AlertSubscription({
    required this.email,
    required this.isGuest,
    required this.isActive,
    this.startsAt,
    this.expiresAt,
    this.filters = const {},
  });

  final String email;
  final bool isGuest;
  final bool isActive;
  final DateTime? startsAt;
  final DateTime? expiresAt;
  final Map<String, dynamic> filters;

  factory AlertSubscription.fromJson(Map<String, dynamic> json) {
    DateTime? parseDt(dynamic v) {
      if (v == null) return null;
      return DateTime.tryParse(v.toString());
    }

    return AlertSubscription(
      email: (json['email'] ?? '').toString(),
      isGuest: json['is_guest'] == true,
      isActive: json['is_active'] == true,
      startsAt: parseDt(json['starts_at']),
      expiresAt: parseDt(json['expires_at']),
      filters: Map<String, dynamic>.from(json['filters'] as Map? ?? {}),
    );
  }
}

class AuthSession {
  AuthSession({
    required this.accessToken,
    required this.user,
    this.expiresIn,
    this.next,
    this.message,
  });

  final String accessToken;
  final UserProfile user;
  final int? expiresIn;
  final String? next;
  final String? message;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      accessToken: (json['access_token'] ?? '').toString(),
      user: UserProfile.fromJson(
        Map<String, dynamic>.from(json['user'] as Map? ?? {}),
      ),
      expiresIn: json['expires_in'] as int?,
      next: json['next']?.toString(),
      message: json['message']?.toString(),
    );
  }
}
