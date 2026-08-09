import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'feed_screen.dart';
import 'map_screen.dart';
import 'write_review_screen.dart';
import 'my_reviews_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    FeedScreen(),
    MapScreen(),
    MyReviewsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final s = S.of(context)!;
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.feed_outlined), selectedIcon: const Icon(Icons.feed), label: s.tabHome),
          NavigationDestination(icon: const Icon(Icons.map_outlined), selectedIcon: const Icon(Icons.map), label: s.tabMap),
          NavigationDestination(icon: const Icon(Icons.person_outline), selectedIcon: const Icon(Icons.person), label: s.tabMyReviews),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const WriteReviewScreen()),
          );
        },
        icon: const Icon(Icons.rate_review_outlined),
        label: Text(s.newReview),
      ),
    );
  }
}
