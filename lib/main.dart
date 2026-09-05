import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/models.dart';
import 'screens/alerts_sheet.dart';
import 'screens/auth_screens.dart';
import 'screens/feedback_screen.dart';
import 'screens/legal_screens.dart';
import 'screens/profile_screen.dart';
import 'screens/results_screen.dart';
import 'screens/search_screen.dart';
import 'screens/terms_acceptance_screen.dart';
import 'services/api_client.dart';
import 'services/auth_state.dart';
import 'services/legal_acceptance.dart';
import 'services/token_storage.dart';
import 'theme/lesi_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = TokenStorage();
  late final AuthState auth;
  final api = ApiClient(
    tokenStorage: storage,
    onUnauthorized: () => auth.handleUnauthorized(),
  );
  auth = AuthState(tokenStorage: storage, api: api);

  runApp(
    MultiProvider(
      providers: [
        Provider<TokenStorage>.value(value: storage),
        Provider<ApiClient>.value(value: api),
        ChangeNotifierProvider<AuthState>.value(value: auth),
      ],
      child: const LesiSearchApp(),
    ),
  );

  await auth.bootstrap();
}

class LesiSearchApp extends StatelessWidget {
  const LesiSearchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LesiSearch',
      debugShowCheckedModeBanner: false,
      theme: LesiTheme.light(),
      home: const _BootGate(),
      onGenerateRoute: (settings) {
        Widget page;
        switch (settings.name) {
          case '/':
          case '/home':
            page = const _BootGate();
            break;
          case '/login':
            page = const LoginScreen();
            break;
          case '/register':
            page = const RegisterScreen();
            break;
          case '/verify-email':
            page = const VerifyEmailScreen();
            break;
          case '/profile':
            final profileArgs =
                settings.arguments as Map<String, dynamic>? ?? {};
            page = ProfileScreen(
              scrollToAlerts: profileArgs['scrollToAlerts'] == true,
              alertFilters: profileArgs['filters'] as SearchFilters?,
            );
            break;
          case '/legal':
          case '/about':
            page = const AboutLegalScreen();
            break;
          case '/legal/terms':
            page = const TermsAndConditionsScreen();
            break;
          case '/legal/privacy':
            page = const PrivacyPolicyScreen();
            break;
          case '/feedback':
            page = const FeedbackScreen();
            break;
          case '/alerts/setup':
            final alertArgs =
                settings.arguments as Map<String, dynamic>? ?? {};
            page = GuestAlertsScreen(
              filters: alertArgs['filters'] as SearchFilters? ?? SearchFilters(),
            );
            break;
          case '/results':
            final args = settings.arguments as Map<String, dynamic>? ?? {};
            page = ResultsScreen(
              result: args['result'] as EvaluateResult,
              filters: args['filters'] as SearchFilters,
            );
            break;
          default:
            page = const SearchScreen();
        }
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (_, __, ___) => page,
          transitionsBuilder: (_, animation, __, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            );
            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.02, 0.02),
                  end: Offset.zero,
                ).animate(curved),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 260),
        );
      },
    );
  }
}

class _BootGate extends StatefulWidget {
  const _BootGate();

  @override
  State<_BootGate> createState() => _BootGateState();
}

class _BootGateState extends State<_BootGate> {
  bool? _legalAccepted;

  @override
  void initState() {
    super.initState();
    _loadLegal();
  }

  Future<void> _loadLegal() async {
    final accepted = await LegalAcceptance.hasAcceptedCurrent();
    if (!mounted) return;
    setState(() => _legalAccepted = accepted);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();
    if (auth.status == AuthStatus.unknown || _legalAccepted == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (!_legalAccepted!) {
      return TermsAcceptanceScreen(
        onAccepted: () {
          if (!mounted) return;
          setState(() => _legalAccepted = true);
        },
      );
    }
    // Do not gate the home screen on email OTP — OTP is only shown after
    // register (and guest alerts use a separate flow).
    return const SearchScreen();
  }
}
