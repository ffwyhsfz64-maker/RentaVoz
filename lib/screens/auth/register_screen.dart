import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../services/auth_service.dart';
import '../legal_screen.dart';
import '../verify_email_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _pass2Ctrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  bool _agreed = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _pass2Ctrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context)!.registerTermsRequired)),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await AuthService.registerWithEmail(_emailCtrl.text.trim(), _passCtrl.text);
      await AuthService.sendEmailVerification();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const VerifyEmailScreen()),
          (_) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        final s = S.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_authError(e.code, s))),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _openLegal(LegalType type) => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => LegalScreen(type: type)),
      );

  String _authError(String code, S s) => switch (code) {
        'email-already-in-use' => s.authErrEmailInUse,
        'invalid-email' => s.authErrInvalidEmail,
        'weak-password' => s.authErrWeakPw,
        _ => s.authErrRegDefault,
      };

  Widget _TermsCheckbox({required bool agreed, required ValueChanged<bool?> onChanged}) {
    final s = S.of(context)!;
    final color = const Color(0xFF2E7D32);
    final linkStyle = TextStyle(
      color: color,
      decoration: TextDecoration.underline,
      decorationColor: color,
      fontSize: 12,
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: agreed,
          onChanged: onChanged,
          activeColor: color,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 11),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => _openLegal(LegalType.privacy),
                  child: Text(s.privacyPolicy, style: linkStyle),
                ),
                Text(' & ', style: Theme.of(context).textTheme.bodySmall),
                GestureDetector(
                  onTap: () => _openLegal(LegalType.terms),
                  child: Text(s.termsOfService, style: linkStyle),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(s.createAccount)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autocorrect: false,
                  decoration: InputDecoration(
                    labelText: s.emailLabel,
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || !v.contains('@')) ? s.emailInvalid : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: s.passwordLabel,
                    prefixIcon: const Icon(Icons.lock_outlined),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) =>
                      (v == null || v.length < 6) ? s.passwordMinLength : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _pass2Ctrl,
                  obscureText: _obscure,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _register(),
                  decoration: InputDecoration(
                    labelText: s.confirmPasswordLabel,
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v != _passCtrl.text ? s.passwordMismatch : null,
                ),
                const SizedBox(height: 20),
                _TermsCheckbox(
                  agreed: _agreed,
                  onChanged: (v) => setState(() => _agreed = v ?? false),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _loading ? null : _register,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: _loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(s.registerButton),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
