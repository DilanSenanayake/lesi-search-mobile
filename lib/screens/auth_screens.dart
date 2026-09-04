import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_state.dart';
import '../theme/lesi_theme.dart';
import '../widgets/common.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthState>();
    final session = await auth.login(_email.text.trim(), _password.text);
    if (!mounted) return;
    if (session == null) {
      showErrorSnack(context, auth.errorMessage ?? 'Sign in failed.');
      return;
    }

    // Sign-in should not require OTP. OTP is only for sign-up and guest alerts.
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();
    final textTheme = Theme.of(context).textTheme;

    return LesiPage(
      showBack: true,
      title: 'Sign in',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          Text(
            'Welcome back',
            style: textTheme.headlineSmall,
          ),
          const SizedBox(height: 6),
          Text(
            'Sign in with your email to continue.',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 28),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const FieldLabel('Email'),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  decoration:
                      const InputDecoration(hintText: 'you@example.com'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Email is required'
                      : null,
                ),
                const SizedBox(height: 16),
                const FieldLabel('Password'),
                TextFormField(
                  controller: _password,
                  obscureText: _obscure,
                  autofillHints: const [AutofillHints.password],
                  decoration: InputDecoration(
                    hintText: 'Your password',
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _obscure = !_obscure),
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Password is required' : null,
                ),
                const SizedBox(height: 28),
                PrimaryButton(
                  label: 'Sign in',
                  loading: auth.busy,
                  onPressed: auth.busy ? null : _submit,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: TextButton(
              onPressed: () =>
                  Navigator.of(context).pushReplacementNamed('/register'),
              child: const Text('No account yet? Create one'),
            ),
          ),
        ],
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthState>();
    final session = await auth.register(
      email: _email.text.trim(),
      password: _password.text,
      confirmPassword: _confirm.text,
      firstName: _first.text.trim(),
      lastName: _last.text.trim(),
    );
    if (!mounted) return;
    if (session == null) {
      showErrorSnack(context, auth.errorMessage ?? 'Registration failed.');
      return;
    }
    showSuccessSnack(
      context,
      session.message ?? 'Check your email for a verification code.',
    );
    Navigator.of(context).pushReplacementNamed('/verify-email');
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();
    final textTheme = Theme.of(context).textTheme;

    return LesiPage(
      showBack: true,
      title: 'Create account',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          Text(
            'Join LesiSearch',
            style: textTheme.headlineSmall,
          ),
          const SizedBox(height: 6),
          Text(
            'Create an account, then verify your email with a one-time code.',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 28),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const FieldLabel('First name'),
                          TextFormField(
                            controller: _first,
                            textCapitalization: TextCapitalization.words,
                            decoration:
                                const InputDecoration(hintText: 'First'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const FieldLabel('Last name'),
                          TextFormField(
                            controller: _last,
                            textCapitalization: TextCapitalization.words,
                            decoration:
                                const InputDecoration(hintText: 'Last'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const FieldLabel('Email'),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration:
                      const InputDecoration(hintText: 'you@example.com'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Email is required'
                      : null,
                ),
                const SizedBox(height: 16),
                const FieldLabel('Password'),
                TextFormField(
                  controller: _password,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    hintText: 'At least 6 characters',
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _obscure = !_obscure),
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                  validator: (v) => (v == null || v.length < 6)
                      ? 'Password must be at least 6 characters'
                      : null,
                ),
                const SizedBox(height: 16),
                const FieldLabel('Confirm password'),
                TextFormField(
                  controller: _confirm,
                  obscureText: _obscure,
                  decoration:
                      const InputDecoration(hintText: 'Repeat password'),
                  validator: (v) =>
                      v != _password.text ? 'Passwords do not match' : null,
                ),
                const SizedBox(height: 20),
                Text.rich(
                  TextSpan(
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: LesiTheme.muted,
                        ),
                    children: [
                      const TextSpan(
                        text: 'By creating an account you agree to our ',
                      ),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.baseline,
                        baseline: TextBaseline.alphabetic,
                        child: GestureDetector(
                          onTap: () =>
                              Navigator.of(context).pushNamed('/legal/terms'),
                          child: Text(
                            'Terms',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: LesiTheme.accentDark,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                      ),
                      const TextSpan(text: ' and '),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.baseline,
                        baseline: TextBaseline.alphabetic,
                        child: GestureDetector(
                          onTap: () =>
                              Navigator.of(context).pushNamed('/legal/privacy'),
                          child: Text(
                            'Privacy Policy',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: LesiTheme.accentDark,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                      ),
                      const TextSpan(text: '.'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  label: 'Create account',
                  loading: auth.busy,
                  onPressed: auth.busy ? null : _submit,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () =>
                  Navigator.of(context).pushReplacementNamed('/login'),
              child: const Text('Already registered? Sign in'),
            ),
          ),
        ],
      ),
    );
  }
}

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final _otp = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _otp.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthState>();
    final ok = await auth.verifyEmail(_otp.text.trim());
    if (!mounted) return;
    if (!ok) {
      showErrorSnack(context, auth.errorMessage ?? 'Invalid OTP');
      return;
    }
    showSuccessSnack(context, 'Email verified successfully.');
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();
    final textTheme = Theme.of(context).textTheme;

    return LesiPage(
      showBack: Navigator.of(context).canPop(),
      title: 'Verify email',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          Text(
            'Check your inbox',
            style: textTheme.headlineSmall,
          ),
          const SizedBox(height: 6),
          Text.rich(
            TextSpan(
              style: textTheme.bodyMedium,
              children: [
                const TextSpan(text: 'Enter the 6-digit code sent to '),
                TextSpan(
                  text: auth.user?.email ?? 'your email',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: LesiTheme.ink,
                  ),
                ),
                const TextSpan(text: '.'),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const FieldLabel('OTP code'),
                TextFormField(
                  controller: _otp,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 8,
                    color: LesiTheme.ink,
                  ),
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    hintText: '------',
                    counterText: '',
                  ),
                  validator: (v) => (v == null || v.length != 6)
                      ? 'OTP must be a 6-digit code'
                      : null,
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: 'Verify email',
                  loading: auth.busy,
                  onPressed: auth.busy ? null : _verify,
                ),
                const SizedBox(height: 10),
                  SecondaryButton(
                    label: 'Resend OTP',
                    onPressed: auth.busy
                        ? null
                        : () async {
                            final msg = await auth.resendOtp();
                            if (!context.mounted) return;
                            if (msg == null) {
                              showErrorSnack(
                                context,
                                auth.errorMessage ?? 'Could not resend OTP',
                              );
                            } else {
                              showSuccessSnack(context, msg);
                            }
                          },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
