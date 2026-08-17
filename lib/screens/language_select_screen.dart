import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

class LanguageSelectScreen extends StatefulWidget {
  final VoidCallback onSelected;
  const LanguageSelectScreen({super.key, required this.onSelected});

  @override
  State<LanguageSelectScreen> createState() => _LanguageSelectScreenState();
}

class _LanguageSelectScreenState extends State<LanguageSelectScreen> {
  String? _selected;

  static const _languages = [
    {'code': 'es', 'flag': '🇲🇽', 'name': 'Español', 'sub': 'Spanish'},
    {'code': 'en', 'flag': '🇺🇸', 'name': 'English', 'sub': 'English'},
    {'code': 'ko', 'flag': '🇰🇷', 'name': '한국어', 'sub': 'Korean'},
    {'code': 'ja', 'flag': '🇯🇵', 'name': '日本語', 'sub': 'Japanese'},
    {'code': 'zh', 'flag': '🇨🇳', 'name': '中文', 'sub': 'Chinese'},
  ];

  Future<void> _confirm() async {
    if (_selected == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', _selected!);
    await prefs.setBool('language_selected', true);
    if (mounted) {
      RentaVozApp.of(context)?.setLocale(Locale(_selected!));
      widget.onSelected();
    }
  }

  @override
  Widget build(BuildContext context) {
    final green = const Color(0xFF2E7D32);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              // Logo
              Row(
                children: [
                  Icon(Icons.location_on, color: green, size: 32),
                  const SizedBox(width: 8),
                  Text(
                    'RentaVoz',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                'Select your language',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'You can change this later in Settings',
                style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              ),
              const SizedBox(height: 28),
              // Language list
              Expanded(
                child: ListView.separated(
                  itemCount: _languages.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final lang = _languages[i];
                    final code = lang['code']!;
                    final isSelected = _selected == code;
                    return GestureDetector(
                      onTap: () => setState(() => _selected = code),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? green.withAlpha(20)
                              : Colors.white,
                          border: Border.all(
                            color: isSelected ? green : Colors.grey.shade200,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Text(
                              lang['flag']!,
                              style: const TextStyle(fontSize: 28),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lang['name']!,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? green
                                        : Colors.grey[800],
                                  ),
                                ),
                                Text(
                                  lang['sub']!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            if (isSelected)
                              Icon(Icons.check_circle, color: green, size: 22),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              // Confirm button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _selected != null ? _confirm : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: green,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade200,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}
