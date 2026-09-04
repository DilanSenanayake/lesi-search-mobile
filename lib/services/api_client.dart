import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/models.dart';
import 'token_storage.dart';

typedef UnauthorizedHandler = Future<void> Function();

class ApiClient {
  ApiClient({
    required TokenStorage tokenStorage,
    http.Client? httpClient,
    this.onUnauthorized,
    this.baseUrl = AppConfig.apiBaseUrl,
  })  : _tokenStorage = tokenStorage,
        _http = httpClient ?? http.Client();

  final TokenStorage _tokenStorage;
  final http.Client _http;
  final UnauthorizedHandler? onUnauthorized;
  final String baseUrl;

  Uri _uri(String path) {
    final root = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    return Uri.parse('$root$path');
  }

  Future<Map<String, dynamic>> _request({
    required String method,
    required String path,
    Map<String, dynamic>? body,
    bool auth = false,
    Duration? timeout,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (auth) {
      final token = await _tokenStorage.readToken();
      if (token == null || token.isEmpty) {
        throw ApiException(
          message: 'Not signed in.',
          code: 'unauthorized',
          statusCode: 401,
        );
      }
      headers['Authorization'] = 'Bearer $token';
    }

    final uri = _uri(path);
    final encoded = body == null ? null : jsonEncode(body);
    late http.Response response;

    try {
      switch (method) {
        case 'GET':
          response = await _http
              .get(uri, headers: headers)
              .timeout(timeout ?? AppConfig.defaultTimeout);
          break;
        case 'PATCH':
          response = await _http
              .patch(uri, headers: headers, body: encoded)
              .timeout(timeout ?? AppConfig.defaultTimeout);
          break;
        case 'POST':
        default:
          response = await _http
              .post(uri, headers: headers, body: encoded)
              .timeout(timeout ?? AppConfig.defaultTimeout);
          break;
      }
    } on Exception catch (_) {
      throw ApiException(
        message:
            'Unable to reach the server. Check your internet connection and try again.',
        code: 'network_error',
      );
    }

    Map<String, dynamic> json;
    try {
      final decoded = jsonDecode(response.body.isEmpty ? '{}' : response.body);
      json = decoded is Map<String, dynamic>
          ? decoded
          : <String, dynamic>{'ok': false, 'raw': decoded};
    } catch (_) {
      throw ApiException(
        message: 'Invalid server response (${response.statusCode}).',
        statusCode: response.statusCode,
        code: 'invalid_response',
      );
    }

    if (response.statusCode == 401 && auth) {
      await onUnauthorized?.call();
    }

    if (response.statusCode >= 400 || json['ok'] == false) {
      final error = json['error'];
      String message = 'Request failed (${response.statusCode}).';
      String? code;
      Map<String, dynamic> details = {};
      if (error is Map) {
        message = (error['message'] ?? message).toString();
        code = error['code']?.toString();
        if (error['details'] is Map) {
          details = Map<String, dynamic>.from(error['details'] as Map);
        }
      } else if (json['error'] is String) {
        message = json['error'].toString();
      }
      throw ApiException(
        message: message,
        code: code,
        statusCode: response.statusCode,
        details: details,
      );
    }

    return json;
  }

  Future<Map<String, dynamic>> health() =>
      _request(method: 'GET', path: '/api/mobile/v1/health/');

  Future<AuthSession> register({
    required String email,
    required String password,
    required String confirmPassword,
    String firstName = '',
    String lastName = '',
  }) async {
    final json = await _request(
      method: 'POST',
      path: '/api/mobile/v1/auth/register/',
      body: {
        'email': email,
        'password': password,
        'confirm_password': confirmPassword,
        'first_name': firstName,
        'last_name': lastName,
      },
    );
    return AuthSession.fromJson(json);
  }

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final json = await _request(
      method: 'POST',
      path: '/api/mobile/v1/auth/login/',
      body: {'email': email, 'password': password},
    );
    return AuthSession.fromJson(json);
  }

  Future<UserProfile> verifyEmail(String otp) async {
    final json = await _request(
      method: 'POST',
      path: '/api/mobile/v1/auth/verify-email/',
      body: {'otp': otp},
      auth: true,
    );
    return UserProfile.fromJson(
      Map<String, dynamic>.from(json['user'] as Map? ?? {}),
    );
  }

  Future<String> resendOtp() async {
    final json = await _request(
      method: 'POST',
      path: '/api/mobile/v1/auth/resend-otp/',
      auth: true,
    );
    return (json['message'] ?? 'OTP sent.').toString();
  }

  Future<({UserProfile user, AlertSubscription? alert})> me() async {
    final json = await _request(
      method: 'GET',
      path: '/api/mobile/v1/me/',
      auth: true,
    );
    final user = UserProfile.fromJson(
      Map<String, dynamic>.from(json['user'] as Map? ?? {}),
    );
    AlertSubscription? alert;
    if (json['alert_subscription'] is Map) {
      alert = AlertSubscription.fromJson(
        Map<String, dynamic>.from(json['alert_subscription'] as Map),
      );
    }
    return (user: user, alert: alert);
  }

  Future<UserProfile> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
  }) async {
    final body = <String, dynamic>{};
    if (firstName != null) body['first_name'] = firstName;
    if (lastName != null) body['last_name'] = lastName;
    if (phoneNumber != null) body['phone_number'] = phoneNumber;
    final json = await _request(
      method: 'PATCH',
      path: '/api/mobile/v1/me/',
      body: body,
      auth: true,
    );
    return UserProfile.fromJson(
      Map<String, dynamic>.from(json['user'] as Map? ?? {}),
    );
  }

  Future<EvaluateResult> evaluate(SearchFilters filters) async {
    final token = await _tokenStorage.readToken();
    final json = await _request(
      method: 'POST',
      path: '/api/mobile/v1/evaluate/',
      body: filters.toJson(),
      auth: token != null && token.isNotEmpty,
      timeout: AppConfig.evaluateTimeout,
    );
    return EvaluateResult.fromJson(json);
  }

  Future<AlertSubscription?> getAlerts() async {
    final json = await _request(
      method: 'GET',
      path: '/api/mobile/v1/alerts/',
      auth: true,
    );
    if (json['alert_subscription'] is Map) {
      return AlertSubscription.fromJson(
        Map<String, dynamic>.from(json['alert_subscription'] as Map),
      );
    }
    return null;
  }

  Future<AlertSubscription> upsertAlerts(SearchFilters filters) async {
    final json = await _request(
      method: 'POST',
      path: '/api/mobile/v1/alerts/',
      body: filters.toJson(),
      auth: true,
    );
    return AlertSubscription.fromJson(
      Map<String, dynamic>.from(json['alert_subscription'] as Map? ?? {}),
    );
  }

  Future<String> startGuestAlerts({
    required String email,
    required SearchFilters filters,
  }) async {
    final body = filters.toJson()..['email'] = email;
    final json = await _request(
      method: 'POST',
      path: '/api/mobile/v1/alerts/guest/start/',
      body: body,
    );
    return (json['message'] ?? 'OTP sent.').toString();
  }

  Future<AlertSubscription?> verifyGuestAlerts({
    required String email,
    required String otp,
  }) async {
    final json = await _request(
      method: 'POST',
      path: '/api/mobile/v1/alerts/guest/verify/',
      body: {'email': email, 'otp': otp},
    );
    if (json['alert_subscription'] is Map) {
      return AlertSubscription.fromJson(
        Map<String, dynamic>.from(json['alert_subscription'] as Map),
      );
    }
    return null;
  }

  /// Permanently deletes the signed-in account. Requires password + confirm=DELETE.
  Future<void> deleteAccount({
    required String password,
    String confirm = 'DELETE',
  }) async {
    await _request(
      method: 'POST',
      path: '/api/mobile/v1/account/delete/',
      body: {
        'password': password,
        'confirm': confirm,
      },
      auth: true,
    );
  }
}
