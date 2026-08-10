import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'feed_screen.dart';
import 'map_screen.dart';
import 'write_review_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late final AnimationController _fabController;

  final List<Widget> _screens = const [
    FeedScreen(),
    MapScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..forward();
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  void _onTabChanged(int i) {
    _fabController.reverse().then((_) {
      setState(() => _currentIndex = i);
      _fabController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _screens[_currentIndex],
      ),
      extendBody: true,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: _onTabChanged,
          elevation: 0,
          height: 64,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          indicatorColor: colorScheme.primaryContainer,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.article_outlined),
              selectedIcon: Icon(Icons.article, color: colorScheme.onPrimaryContainer),
              label: s.tabHome,
            ),
            NavigationDestination(
              icon: const Icon(Icons.map_outlined),
              selectedIcon: Icon(Icons.map_rounded, color: colorScheme.onPrimaryContainer),
              label: s.tabMap,
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded, color: colorScheme.onPrimaryContainer),
              label: s.tabProfile,
            ),
          ],
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: CurvedAnimation(parent: _fabController, curve: Curves.easeOutBack),
        child: FloatingActionButton.extended(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const WriteReviewScreen()),
          ),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 4,
          icon: const Icon(Icons.rate_review_rounded),
          label: Text(s.newReview, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}
