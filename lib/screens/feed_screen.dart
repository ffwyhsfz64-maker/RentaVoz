import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../data/dummy_reviews.dart';
import '../models/review.dart';
import '../services/review_service.dart';
import '../widgets/review_card.dart';
import 'review_detail_screen.dart';
import 'settings_screen.dart';

enum _SortOption { newest, highest, lowest }

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  String _search = '';
  String _typeFilter = 'all'; // 'all' | 'house' | 'room'
  _SortOption _sort = _SortOption.newest;

  List<Review> _apply(List<Review> reviews) {
    var list = reviews.where((r) {
      if (_search.isNotEmpty && !r.address.toLowerCase().contains(_search.toLowerCase())) {
        return false;
      }
      if (_typeFilter == 'house') return r.rentalType == 'house';
      if (_typeFilter == 'room') return r.rentalType == 'room';
      return true;
    }).toList();

    switch (_sort) {
      case _SortOption.newest:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case _SortOption.highest:
        list.sort((a, b) => b.overallRating.compareTo(a.overallRating));
      case _SortOption.lowest:
        list.sort((a, b) => a.overallRating.compareTo(b.overallRating));
    }
    return list;
  }

  void _showSortSheet(S s) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SortTile(
              label: s.sortNewest,
              icon: Icons.access_time_outlined,
              selected: _sort == _SortOption.newest,
              onTap: () { setState(() => _sort = _SortOption.newest); Navigator.pop(context); },
            ),
            _SortTile(
              label: s.sortHighest,
              icon: Icons.arrow_upward,
              selected: _sort == _SortOption.highest,
              onTap: () { setState(() => _sort = _SortOption.highest); Navigator.pop(context); },
            ),
            _SortTile(
              label: s.sortLowest,
              icon: Icons.arrow_downward,
              selected: _sort == _SortOption.lowest,
              onTap: () { setState(() => _sort = _SortOption.lowest); Navigator.pop(context); },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context)!;
    final sortLabel = switch (_sort) {
      _SortOption.newest => s.sortNewest,
      _SortOption.highest => s.sortHighest,
      _SortOption.lowest => s.sortLowest,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('RentaVoz'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(104),
          child: Column(
            children: [
              // 검색창
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
                child: SearchBar(
                  hintText: s.searchHint,
                  leading: const Icon(Icons.search, size: 20),
                  onChanged: (v) => setState(() => _search = v),
                  elevation: const WidgetStatePropertyAll(1),
                  padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 12)),
                ),
              ),
              // 필터 칩 + 정렬 버튼
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    // 정렬 버튼
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ActionChip(
                        avatar: const Icon(Icons.sort, size: 16),
                        label: Text(sortLabel, style: const TextStyle(fontSize: 12)),
                        onPressed: () => _showSortSheet(s),
                        backgroundColor: _sort != _SortOption.newest
                            ? Theme.of(context).colorScheme.primaryContainer
                            : null,
                      ),
                    ),
                    // 타입 필터 칩
                    _FilterChip(
                      label: s.filterAll,
                      selected: _typeFilter == 'all',
                      onSelected: (_) => setState(() => _typeFilter = 'all'),
                    ),
                    const SizedBox(width: 6),
                    _FilterChip(
                      label: '🏠 ${s.filterHouse}',
                      selected: _typeFilter == 'house',
                      onSelected: (_) => setState(() => _typeFilter = 'house'),
                    ),
                    const SizedBox(width: 6),
                    _FilterChip(
                      label: '🚪 ${s.filterRoom}',
                      selected: _typeFilter == 'room',
                      onSelected: (_) => setState(() => _typeFilter = 'room'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
      body: StreamBuilder<List<Review>>(
        stream: ReviewService.feedStream(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }

          final reviews = _apply(
            (snap.data?.isEmpty ?? true) ? dummyReviews : snap.data!,
          );

          if (reviews.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(
                    _search.isEmpty ? s.noReviewsYet : s.noResultsFor(_search),
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: reviews.length,
            itemBuilder: (context, index) => ReviewCard(
              review: reviews[index],
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ReviewDetailScreen(review: reviews[index])),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, required this.onSelected});
  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: selected,
      onSelected: onSelected,
      showCheckmark: false,
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}

class _SortTile extends StatelessWidget {
  const _SortTile({required this.label, required this.icon, required this.selected, required this.onTap});
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: selected ? Theme.of(context).colorScheme.primary : null),
      title: Text(label, style: TextStyle(fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
      trailing: selected ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary) : null,
      onTap: onTap,
    );
  }
}
