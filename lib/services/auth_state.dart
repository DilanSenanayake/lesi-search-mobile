import 'package:flutter/foundation.dart';

import '../models/models.dart';
import 'api_client.dart';
import 'token_storage.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState extends ChangeNotifier {
  AuthState({
    required TokenStorage tokenStorage,
    required ApiClient api,
  })  : _tokenStorage = tokenStorage,
        _api = api;

  final TokenStorage _tokenStorage;
  final ApiClient _api;

  AuthStatus status = AuthStatus.unknown;
  UserProfile? user;
  AlertSubscription? alertSubscription;
  String? errorMessage;
  bool busy = false;

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get needsEmailVerification =>
      user != null && user!.emailVerified == false;

  Future<void> bootstrap() async {
    final token = await _tokenStorage.readToken();
    if (token == null || token.isEmpty) {
      status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }
    try {
      final me = await _api.me();
      user = me.user;
      alertSubscription = me.alert;
      status = AuthStatus.authenticated;
    } on ApiException catch (e) {
      if (e.isUnauthorized) {
        await _tokenStorage.clear();
        status = AuthStatus.unauthenticated;
        user = null;
      } else {
        // Keep session optimistic if offline briefly.
        status = AuthStatus.authenticated;
        errorMessage = e.message;
      }
    } catch (e) {
      status = AuthStatus.authenticated;
      errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> handleUnauthorized() async {
    await _tokenStorage.clear();
    user = null;
    alertSubscription = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<AuthSession?> login(String email, String password) async {
    return _runAuth(() async {
      final session = await _api.login(email: email, password: password);
      await _persist(session);
      return session;
    });
  }

  Future<AuthSession?> register({
    required String email,
    required String password,
    required String confirmPassword,
    String firstName = '',
    String lastName = '',
  }) async {
    return _runAuth(() async {
      final session = await _api.register(
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        firstName: firstName,
        lastName: lastName,
      );
      await _persist(session);
      return session;
    });
  }

  Future<bool> verifyEmail(String otp) async {
    busy = true;
    errorMessage = null;
    notifyListeners();
    try {
      user = await _api.verifyEmail(otp);
      busy = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      busy = false;
      notifyListeners();
      return false;
    }
  }

  Future<String?> resendOtp() async {
    try {
      return await _api.resendOtp();
    } on ApiException catch (e) {
      errorMessage = e.message;
      notifyListeners();
      return null;
    }
  }

  Future<bool> refreshMe() async {
    try {
      final me = await _api.me();
      user = me.user;
      alertSubscription = me.alert;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfile({
    required String firstName,
    required String lastName,
    String phoneNumber = '',
  }) async {
    busy = true;
    errorMessage = null;
    notifyListeners();
    try {
      user = await _api.updateProfile(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
      );
      busy = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      busy = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> saveAlerts(SearchFilters filters) async {
    busy = true;
    errorMessage = null;
    notifyListeners();
    try {
      alertSubscription = await _api.upsertAlerts(filters);
      busy = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      busy = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _tokenStorage.clear();
    user = null;
    alertSubscription = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  /// Permanently deletes the account on the server and clears local session.
  Future<bool> deleteAccount(String password) async {
    busy = true;
    errorMessage = null;
    notifyListeners();
    try {
      await _api.deleteAccount(password: password, confirm: 'DELETE');
      await _tokenStorage.clear();
      user = null;
      alertSubscription = null;
      status = AuthStatus.unauthenticated;
      busy = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      busy = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> _persist(AuthSession session) async {
    await _tokenStorage.saveSession(
      accessToken: session.accessToken,
      email: session.user.email,
    );
    user = session.user;
    status = AuthStatus.authenticated;
  }

  Future<AuthSession?> _runAuth(Future<AuthSession> Function() action) async {
    busy = true;
    errorMessage = null;
    notifyListeners();
    try {
      final session = await action();
      busy = false;
      notifyListeners();
      return session;
    } on ApiException catch (e) {
      errorMessage = e.message;
      busy = false;
      notifyListeners();
      return null;
    }
  }
}
