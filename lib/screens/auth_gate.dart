import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth/login_screen.dart';
import 'home_screen.dart';
import 'onboarding_screen.dart';
import 'verify_email_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snap.hasError || snap.data == null) return const LoginScreen();
        final user = snap.data!;
        final isGoogle = user.providerData.any((p) => p.providerId == 'google.com');
        if (!isGoogle && !user.emailVerified) return const VerifyEmailScreen();
        return const _OnboardingGate();
      },
    );
  }
}

class _OnboardingGate extends StatefulWidget {
  const _OnboardingGate();

  @override
  State<_OnboardingGate> createState() => _OnboardingGateState();
}

class _OnboardingGateState extends State<_OnboardingGate> {
  bool? _done;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((p) {
      setState(() => _done = p.getBool('onboarding_done') ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_done == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_done == false) {
      return OnboardingScreen(onDone: () => setState(() => _done = true));
    }
    return const HomeScreen();
  }
}
