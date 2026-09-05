import 'package:shared_preferences/shared_preferences.dart';

import '../legal/legal_copy.dart';

/// Persists first-run acceptance of Terms & Privacy.
///
/// Re-prompts only if [LegalCopy.lastUpdated] changes after the user accepted.
class LegalAcceptance {
  LegalAcceptance._();

  static const _acceptedVersionKey = 'lesi_legal_accepted_version';

  static Future<bool> hasAcceptedCurrent() async {
    final prefs = await SharedPreferences.getInstance();
    final accepted = prefs.getString(_acceptedVersionKey);
    return accepted == LegalCopy.lastUpdated;
  }

  static Future<void> acceptCurrent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_acceptedVersionKey, LegalCopy.lastUpdated);
  }
}
