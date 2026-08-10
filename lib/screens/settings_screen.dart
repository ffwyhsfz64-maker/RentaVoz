import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';
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
        ],
      ),
    );
  }
}
