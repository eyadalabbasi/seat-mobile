import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_client.dart';
import '../../../core/config/app_config.dart';
import '../../../l10n/app_localizations.dart';
import '../data/auth_repository.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key, required this.languageSelected});
  final ValueGetter<bool> languageSelected;
  @override
  ConsumerState<SplashScreen> createState() => _SplashState();
}

class _SplashState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      final session = ref.read(sessionProvider);
      context.go(
        session.value == true
            ? '/home'
            : widget.languageSelected()
            ? '/login'
            : '/language',
      );
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Semantics(
        label: 'SEAT',
        header: true,
        child: const Text(
          'SEAT',
          style: TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.w700,
            letterSpacing: 5,
          ),
        ),
      ),
    ),
  );
}

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key, required this.onLocale});
  final ValueChanged<Locale> onLocale;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Text(
                l.chooseLanguage,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: () {
                  onLocale(const Locale('en'));
                  context.go('/login');
                },
                child: Text(l.english),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  onLocale(const Locale('ar'));
                  context.go('/login');
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                child: Text(l.arabic),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class PhoneLoginScreen extends ConsumerStatefulWidget {
  const PhoneLoginScreen({super.key});
  @override
  ConsumerState<PhoneLoginScreen> createState() => _PhoneState();
}

class _PhoneState extends ConsumerState<PhoneLoginScreen> {
  late final TextEditingController controller;
  bool loading = false;
  String? error;
  bool get preview => ref.read(appConfigProvider).useFixtures;
  @override
  void initState() {
    super.initState();
    controller = TextEditingController(
      text: ref.read(appConfigProvider).useFixtures ? '+97330000000' : '+973',
    );
  }

  Future<void> submit() async {
    setState(() => loading = true);
    try {
      final challenge = await ref
          .read(authRepositoryProvider)
          .requestOtp(controller.text.replaceAll(' ', ''));
      if (mounted) {
        context.push(
          '/otp',
          extra: {'challengeId': challenge, 'phone': controller.text},
        );
      }
    } on ApiFailure catch (e) {
      setState(() => error = e.message);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l.phoneTitle,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 24),
              Directionality(
                textDirection: TextDirection.ltr,
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.phone,
                  autofillHints: const [AutofillHints.telephoneNumber],
                  decoration: InputDecoration(
                    hintText: l.phoneHint,
                    errorText: error,
                  ),
                ),
              ),
              if (preview) ...[
                const SizedBox(height: 8),
                Text(
                  l.developmentLoginHint,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              const Spacer(),
              FilledButton(
                onPressed: loading ? null : submit,
                child: loading
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l.continueLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key, required this.challengeId, required this.phone});
  final String challengeId, phone;
  @override
  ConsumerState<OtpScreen> createState() => _OtpState();
}

class _OtpState extends ConsumerState<OtpScreen> {
  late final TextEditingController controller;
  bool loading = false;
  String? error;
  bool get preview => ref.read(appConfigProvider).useFixtures;
  @override
  void initState() {
    super.initState();
    controller = TextEditingController(
      text: ref.read(appConfigProvider).useFixtures ? '123456' : '',
    );
  }

  Future<void> submit() async {
    setState(() => loading = true);
    try {
      await ref
          .read(authRepositoryProvider)
          .verifyOtp(widget.challengeId, controller.text);
      await ref.read(sessionProvider.notifier).signedIn();
      if (mounted) context.go('/home');
    } on ApiFailure {
      setState(() => error = AppLocalizations.of(context).invalidOtp);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l.otpTitle,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 8),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(widget.phone),
              ),
              const SizedBox(height: 24),
              Directionality(
                textDirection: TextDirection.ltr,
                child: TextField(
                  controller: controller,
                  maxLength: 6,
                  keyboardType: TextInputType.number,
                  autofillHints: const [AutofillHints.oneTimeCode],
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 28, letterSpacing: 12),
                  decoration: InputDecoration(errorText: error),
                ),
              ),
              if (preview)
                Text(
                  l.developmentOtpHint,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              const Spacer(),
              FilledButton(
                onPressed: loading || controller.text.length != 6
                    ? null
                    : submit,
                child: Text(l.verify),
              ),
              TextButton(
                onPressed: () => context.pop(),
                child: Text(l.resendCode),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
