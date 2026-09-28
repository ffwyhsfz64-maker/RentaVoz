import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../main.dart';
import '../services/auth_service.dart';
import 'about_screen.dart';
import 'legal_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const _langs = [
    ('Español', 'es', '🇲🇽'),
    ('English', 'en', '🇺🇸'),
    ('한국어', 'ko', '🇰🇷'),
    ('日本語', 'ja', '🇯🇵'),
    ('中文', 'zh', '🇨🇳'),
  ];

  @override
  Widget build(BuildContext context) {
    final s = S.of(context)!;
    final currentCode = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(title: Text(s.settingsTitle)),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(s.languageLabel, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          ..._langs.map((lang) {
            final (name, code, flag) = lang;
            final selected = code == currentCode;
            return ListTile(
              leading: Text(flag, style: const TextStyle(fontSize: 24)),
              title: Text(name),
              trailing: selected ? const Icon(Icons.check_circle, color: Color(0xFF2E7D32)) : null,
              selected: selected,
              onTap: () {
                RentaVozApp.of(context)?.setLocale(Locale(code));
                Navigator.pop(context);
              },
            );
          }),

          const Divider(height: 32),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              s.legalSection,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(s.privacyPolicy),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LegalScreen(type: LegalType.privacy)),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.gavel_outlined),
            title: Text(s.termsOfService),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LegalScreen(type: LegalType.terms)),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(s.appAbout),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AboutScreen()),
            ),
          ),

          // 계정 삭제 섹션 (로그인 상태일 때만 표시)
          if (AuthService.currentUser != null) ...[
            const Divider(height: 32),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                s.dangerZone,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.delete_forever_outlined, color: Colors.red[700]),
              title: Text(s.deleteAccount, style: TextStyle(color: Colors.red[700])),
              onTap: () => _showDeleteAccountDialog(context, s),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Future<void> _showDeleteAccountDialog(BuildContext context, S s) async {
    final isGoogle = AuthService.isGoogleUser;
    final isApple = AuthService.isAppleUser;
    final passwordCtrl = TextEditingController();
    bool loading = false;
    bool obscure = true;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red[700], size: 24),
              const SizedBox(width: 8),
              Expanded(child: Text(s.deleteAccountTitle)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.deleteAccountBody, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.red[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        s.deleteAccountWarning,
                        style: TextStyle(fontSize: 12, color: Colors.red[700]),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isGoogle && !isApple) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: passwordCtrl,
                  obscureText: obscure,
                  decoration: InputDecoration(
                    labelText: s.deleteAccountPasswordHint,
                    prefixIcon: const Icon(Icons.lock_outlined),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      onPressed: () => setStateDialog(() => obscure = !obscure),
                    ),
                  ),
                ),
              ] else ...[
                const SizedBox(height: 12),
                Text(
                  isApple ? s.deleteAccountReauthApple : s.deleteAccountReauthGoogle,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: loading ? null : () => Navigator.pop(ctx),
              child: Text(s.cancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red[700]),
              onPressed: loading
                  ? null
                  : () async {
                      setStateDialog(() => loading = true);
                      try {
                        await AuthService.deleteAccount(
                          password: (isGoogle || isApple) ? null : passwordCtrl.text,
                        );
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(s.deleteAccountSuccess),
                              backgroundColor: Colors.red[700],
                            ),
                          );
                          // AuthGate가 자동으로 로그인 화면으로 이동시킴
                        }
                      } on FirebaseAuthException catch (e) {
                        setStateDialog(() => loading = false);
                        if (!ctx.mounted) return;
                        final msg = (e.code == 'wrong-password' || e.code == 'invalid-credential')
                            ? s.deleteAccountErrorWrongPw
                            : s.deleteAccountErrorDefault;
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(content: Text(msg), backgroundColor: Colors.red[700]),
                        );
                      } catch (e) {
                        setStateDialog(() => loading = false);
                        if (!ctx.mounted) return;
                        if (e.toString().contains('cancelled')) {
                          Navigator.pop(ctx);
                          return;
                        }
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(content: Text(s.deleteAccountErrorDefault), backgroundColor: Colors.red[700]),
                        );
                      }
                    },
              child: loading
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(s.deleteAccountConfirm),
            ),
          ],
        ),
      ),
    );

    passwordCtrl.dispose();
  }
}
