import 'package:cloud_firestore/cloud_firestore.dart';
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
  String _typeFilter = 'all';
  _SortOption _sort = _SortOption.newest;

  List<Review> _reviews = [];
  DocumentSnapshot? _lastDoc;
  bool _hasMore = true;
  bool _loading = true;
  bool _loadingMore = false;

  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchInitial();
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200) {
      _fetchMore();
    }
  }

  bool get _isRatingSort => _sort != _SortOption.newest;
  String? get _rentalTypeFilter => _typeFilter == 'all' ? null : _typeFilter;

  List<Review> _sortedReviews(List<Review> list) {
    final sorted = List<Review>.from(list);
    switch (_sort) {
      case _SortOption.newest:
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case _SortOption.highest:
        sorted.sort((a, b) => b.overallRating.compareTo(a.overallRating));
      case _SortOption.lowest:
        sorted.sort((a, b) => a.overallRating.compareTo(b.overallRating));
    }
    return sorted;
  }

  Future<void> _fetchInitial() async {
    setState(() { _loading = true; _reviews = []; _lastDoc = null; _hasMore = true; });
    try {
      if (_isRatingSort) {
        final all = await ReviewService.fetchAll(rentalType: _rentalTypeFilter);
        if (!mounted) return;
        setState(() {
          final base = all.isEmpty ? dummyReviews : all;
          _reviews = _sortedReviews(base);
          _lastDoc = null;
          _hasMore = false;
          _loading = false;
        });
      } else {
        final page = await ReviewService.fetchPage(rentalType: _rentalTypeFilter);
        if (!mounted) return;
        setState(() {
          _reviews = page.reviews.isEmpty ? dummyReviews : page.reviews;
          _lastDoc = page.lastDoc;
          _hasMore = page.reviews.length >= 15 && page.reviews.isNotEmpty;
          _loading = false;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() { _reviews = dummyReviews; _loading = false; _hasMore = false; });
    }
  }

  Future<void> _fetchMore() async {
    if (_loadingMore || !_hasMore || _lastDoc == null || _isRatingSort) return;
    if (_search.isNotEmpty) return;
    setState(() => _loadingMore = true);
    try {
      final page = await ReviewService.fetchPage(rentalType: _rentalTypeFilter, after: _lastDoc);
      if (!mounted) return;
      setState(() {
        _reviews.addAll(page.reviews);
        _lastDoc = page.lastDoc;
        _hasMore = page.reviews.length >= 15;
        _loadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingMore = false);
    }
  }

  void _applyFilter({String? type, _SortOption? sort}) {
    setState(() {
      if (type != null) _typeFilter = type;
      if (sort != null) _sort = sort;
    });
    _fetchInitial();
  }

  List<Review> get _displayed {
    if (_search.isEmpty) return _reviews;
    final q = _search.toLowerCase();
    return _reviews.where((r) => r.address.toLowerCase().contains(q)).toList();
  }

  void _showSortSheet(S s) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 12),
            _SortTile(label: s.sortNewest, icon: Icons.access_time_outlined, selected: _sort == _SortOption.newest,
                onTap: () { Navigator.pop(context); _applyFilter(sort: _SortOption.newest); }),
            _SortTile(label: s.sortHighest, icon: Icons.arrow_upward, selected: _sort == _SortOption.highest,
                onTap: () { Navigator.pop(context); _applyFilter(sort: _SortOption.highest); }),
            _SortTile(label: s.sortLowest, icon: Icons.arrow_downward, selected: _sort == _SortOption.lowest,
                onTap: () { Navigator.pop(context); _applyFilter(sort: _SortOption.lowest); }),
            const SizedBox(height: 8),
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
    final displayed = _displayed;
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollCtrl,
        slivers: [
          // ── Brand SliverAppBar ────────────────────────────────
          SliverAppBar(
            floating: true,
            snap: true,
            centerTitle: false,
            title: RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'Renta',
                    style: TextStyle(
                      color: Color(0xFF2E7D32),
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  TextSpan(
                    text: 'Voz',
                    style: TextStyle(
                      color: Color(0xFF1B5E20),
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
              ),
            ],
          ),

          // ── Pinned search + filters ───────────────────────────
          SliverPersistentHeader(
            pinned: true,
            delegate: _SearchBarDelegate(
              child: ColoredBox(
                color: theme.scaffoldBackgroundColor,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                      child: SearchBar(
                        hintText: s.searchHint,
                        leading: const Icon(Icons.search, size: 20),
                        onChanged: (v) => setState(() => _search = v),
                        elevation: const WidgetStatePropertyAll(1.5),
                        padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 12)),
                        shape: WidgetStatePropertyAll(
                          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 42,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ActionChip(
                              avatar: const Icon(Icons.sort, size: 15),
                              label: Text(sortLabel, style: const TextStyle(fontSize: 12)),
                              onPressed: () => _showSortSheet(s),
                              backgroundColor: _sort != _SortOption.newest
                                  ? theme.colorScheme.primaryContainer
                                  : null,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                          ),
                          _FilterChipWidget(label: s.filterAll, selected: _typeFilter == 'all', onSelected: (_) => _applyFilter(type: 'all')),
                          const SizedBox(width: 6),
                          _FilterChipWidget(label: '🏠 ${s.filterHouse}', selected: _typeFilter == 'house', onSelected: (_) => _applyFilter(type: 'house')),
                          const SizedBox(width: 6),
                          _FilterChipWidget(label: '🚪 ${s.filterRoom}', selected: _typeFilter == 'room', onSelected: (_) => _applyFilter(type: 'room')),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
            ),
          ),

          // ── Content ───────────────────────────────────────────
          if (_loading)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
          else if (displayed.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 12),
                    Text(
                      _search.isEmpty ? s.noReviewsYet : s.noResultsFor(_search),
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            SliverPadding(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              sliver: SliverList.builder(
                itemCount: displayed.length + (_hasMore && _search.isEmpty ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == displayed.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return ReviewCard(
                    review: displayed[index],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ReviewDetailScreen(review: displayed[index])),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SearchBarDelegate extends SliverPersistentHeaderDelegate {
  const _SearchBarDelegate({required this.child});
  final Widget child;

  static const _height = 102.0; // searchbar(56) + chips(42) + padding(4)

  @override
  double get minExtent => _height;
  @override
  double get maxExtent => _height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => child;

  @override
  bool shouldRebuild(_SearchBarDelegate old) => old.child != child;
}

class _FilterChipWidget extends StatelessWidget {
  const _FilterChipWidget({required this.label, required this.selected, required this.onSelected});
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
