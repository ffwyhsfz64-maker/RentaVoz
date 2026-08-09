import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onDone});
  final VoidCallback onDone;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageCtrl = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    widget.onDone();
  }

  List<_Page> _buildPages(S s) => [
    _Page(icon: Icons.home_work_outlined, title: s.onb1Title, body: s.onb1Body, color: const Color(0xFF2E7D32)),
    _Page(icon: Icons.rate_review_outlined, title: s.onb2Title, body: s.onb2Body, color: const Color(0xFF1565C0)),
    _Page(icon: Icons.verified_outlined, title: s.onb3Title, body: s.onb3Body, color: const Color(0xFF6A1B9A)),
    _Page(icon: Icons.map_outlined, title: s.onb4Title, body: s.onb4Body, color: const Color(0xFFE65100)),
    _Page(icon: Icons.edit_outlined, title: s.onb5Title, body: s.onb5Body, color: const Color(0xFF2E7D32)),
  ];

  @override
  Widget build(BuildContext context) {
    final s = S.of(context)!;
    final pages = _buildPages(s);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageCtrl,
                onPageChanged: (i) => setState(() => _page = i),
                itemCount: pages.length,
                itemBuilder: (_, i) => _PageView(page: pages[i]),
              ),
            ),

            // 도트 인디케이터
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(pages.length, (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
                width: _page == i ? 20 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _page == i ? const Color(0xFF2E7D32) : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              )),
            ),

            // 버튼
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                children: [
                  if (_page > 0)
                    TextButton(
                      onPressed: () => _pageCtrl.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      ),
                      child: Text(s.back),
                    ),
                  const Spacer(),
                  if (_page < pages.length - 1)
                    FilledButton(
                      onPressed: () => _pageCtrl.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      ),
                      child: Text(s.next),
                    )
                  else
                    FilledButton(
                      onPressed: _finish,
                      child: Text(s.getStarted),
                    ),
                ],
              ),
            ),

            TextButton(
              onPressed: _finish,
              child: Text(s.skip, style: const TextStyle(color: Colors.grey)),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _PageView extends StatelessWidget {
  const _PageView({required this.page});
  final _Page page;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: page.color.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Icon(page.icon, size: 52, color: page.color),
          ),
          const SizedBox(height: 32),
          Text(
            page.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            page.body,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _Page {
  final IconData icon;
  final String title;
  final String body;
  final Color color;
  const _Page({required this.icon, required this.title, required this.body, required this.color});
}
