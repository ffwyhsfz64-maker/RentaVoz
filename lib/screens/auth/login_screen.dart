import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../services/auth_service.dart';
import '../home_screen.dart';
import '../verify_email_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login({int retry = 0}) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final cred = await AuthService.signInWithEmail(_emailCtrl.text.trim(), _passCtrl.text);
      if (mounted) {
        final isGoogle = cred.user?.providerData.any((p) => p.providerId == 'google.com') ?? false;
        final verified = cred.user?.emailVerified ?? false;
        final dest = (!isGoogle && !verified) ? const VerifyEmailScreen() : const HomeScreen();
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => dest));
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('[Login] FirebaseAuthException code="${e.code}" msg="${e.message}"');
      if (e.code == 'keychain-error' && retry == 0) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) _login(retry: 1);
        return;
      }
      if (mounted) {
        final s = S.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_authError(e.code, s)), duration: const Duration(seconds: 4)),
        );
      }
    } catch (e) {
      debugPrint('[Login] Unexpected error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류: $e'), duration: const Duration(seconds: 6)),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() => _loading = true);
    try {
      await AuthService.signInWithGoogle();
      if (mounted) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
      }
    } catch (e) {
      if (mounted && e.toString() != 'Exception: cancelled') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google 로그인 실패: $e'), duration: const Duration(seconds: 4)),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _showForgotPassword(BuildContext context, S s) async {
    final emailCtrl = TextEditingController(text: _emailCtrl.text.trim());
    final messenger = ScaffoldMessenger.of(context);
    bool sending = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: Text(s.forgotPasswordTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.forgotPasswordBody, style: const TextStyle(fontSize: 13)),
              const SizedBox(height: 16),
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                decoration: InputDecoration(
                  labelText: s.emailLabel,
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(s.cancel)),
            FilledButton(
              onPressed: sending
                  ? null
                  : () async {
                      final email = emailCtrl.text.trim();
                      if (!email.contains('@')) return;
                      setStateDialog(() => sending = true);
                      try {
                        await AuthService.sendPasswordReset(email);
                        if (ctx.mounted) Navigator.pop(ctx);
                        messenger.showSnackBar(SnackBar(
                          content: Text(s.forgotPasswordSent),
                          backgroundColor: const Color(0xFF2E7D32),
                          duration: const Duration(seconds: 5),
                        ));
                      } on FirebaseAuthException catch (e) {
                        if (!ctx.mounted) return;
                        setStateDialog(() => sending = false);
                        messenger.showSnackBar(SnackBar(
                          content: Text(e.code == 'user-not-found' ? s.forgotPasswordErrNotFound : s.forgotPasswordErrDefault),
                        ));
                      }
                    },
              child: sending
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(s.forgotPasswordSend),
            ),
          ],
        ),
      ),
    );
    emailCtrl.dispose();
  }

  String _authError(String code, S s) => switch (code) {
        'user-not-found' => s.authErrNotFound,
        'wrong-password' || 'invalid-credential' || 'INVALID_LOGIN_CREDENTIALS' || 'invalid-login-credentials' => s.authErrWrongPw,
        'invalid-email' => s.authErrInvalidEmail,
        'too-many-requests' => s.authErrTooMany,
        'network-request-failed' => '네트워크 오류. 인터넷 연결을 확인해주세요.',
        'keychain-error' => '다시 시도해주세요.',
        _ => '${s.authErrDefault} (code: $code)',
      };

  @override
  Widget build(BuildContext context) {
    final s = S.of(context)!;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // ── Gradient background (top portion) ──────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            height: size.height * 0.42,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.home_work_outlined, size: 64, color: Colors.white),
                    const SizedBox(height: 12),
                    const Text(
                      'RentaVoz',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      s.appSubtitle,
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Form card (bottom) ─────────────────────────────────
          Positioned(
            top: size.height * 0.36,
            left: 0, right: 0, bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 16, offset: const Offset(0, -4))],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autocorrect: false,
                        decoration: InputDecoration(
                          labelText: s.emailLabel,
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                        ),
                        validator: (v) => (v == null || !v.contains('@')) ? s.emailInvalid : null,
                      ),
                      const SizedBox(height: 14),

                      TextFormField(
                        controller: _passCtrl,
                        obscureText: _obscure,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _login(),
                        decoration: InputDecoration(
                          labelText: s.passwordLabel,
                          prefixIcon: const Icon(Icons.lock_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          suffixIcon: IconButton(
                            icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                        ),
                        validator: (v) => (v == null || v.length < 6) ? s.passwordMinLength : null,
                      ),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => _showForgotPassword(context, s),
                          child: Text(s.forgotPassword, style: const TextStyle(fontSize: 13)),
                        ),
                      ),

                      FilledButton(
                        onPressed: _loading ? null : _login,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _loading
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : Text(s.loginButton, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 10),

                      OutlinedButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(s.createAccount, style: const TextStyle(fontSize: 16)),
                      ),

                      const SizedBox(height: 20),
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text('o continúa con', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 14),

                      OutlinedButton.icon(
                        onPressed: _loading ? null : _loginWithGoogle,
                        icon: Image.asset(
                          'assets/google_logo.png',
                          width: 20, height: 20,
                          errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata, size: 22),
                        ),
                        label: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text('Continuar con Google', style: TextStyle(fontSize: 15)),
                        ),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          side: const BorderSide(color: Colors.grey),
                          foregroundColor: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
