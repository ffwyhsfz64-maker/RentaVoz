import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../l10n/app_localizations.dart';
import '../models/review.dart';
import '../services/auth_service.dart';
import '../services/bookmark_service.dart';
import '../services/follow_service.dart';
import '../services/review_service.dart';
import '../services/storage_service.dart';
import '../widgets/review_card.dart';
import 'address_reviews_screen.dart';
import 'review_detail_screen.dart';
import 'write_review_screen.dart';
import 'auth/login_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _displayName;
  String? _photoURL;

  @override
  void initState() {
    super.initState();
    _displayName = AuthService.currentUser?.displayName;
    _photoURL = AuthService.currentUser?.photoURL;
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadAvatar(S s) async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Galería'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Cámara'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final picked = await picker.pickImage(source: source, imageQuality: 80, maxWidth: 512);
    if (picked == null || !mounted) return;
    try {
      final uid = AuthService.currentUser!.uid;
      final url = await StorageService.uploadAvatar(uid, File(picked.path));
      await AuthService.updatePhotoURL(url);
      await AuthService.reloadUser();
      if (!mounted) return;
      setState(() => _photoURL = url);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.photoUploadSuccess), backgroundColor: const Color(0xFF2E7D32)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.photoUploadError), backgroundColor: Colors.red),
      );
    }
  }

  void _showEditNameDialog(S s) {
    final ctrl = TextEditingController(text: _displayName ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.profileEditNameTitle),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(hintText: s.profileEditNameHint),
          textCapitalization: TextCapitalization.words,
          maxLength: 30,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(s.cancel)),
          FilledButton(
            onPressed: () async {
              final name = ctrl.text.trim();
              if (name.isEmpty) return;
              Navigator.pop(ctx);
              try {
                await AuthService.updateDisplayName(name);
                // Reload to get updated displayName
                await FirebaseAuth.instance.currentUser?.reload();
                if (!mounted) return;
                setState(() => _displayName = name);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(s.profileSaveSuccess), backgroundColor: const Color(0xFF2E7D32)),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(s.profileSaveError), backgroundColor: Colors.red),
                );
              }
            },
            child: Text(s.profileSave),
          ),
        ],
      ),
    );
  }

  void _showActions(BuildContext context, S s, Review review) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(s.editReview),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => WriteReviewScreen(existingReview: review)));
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: Text(s.deleteReview, style: const TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(context);
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(s.deleteConfirmTitle),
                    content: Text(s.deleteConfirmBody),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(s.cancel)),
                      FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(s.delete)),
                    ],
                  ),
                );
                if (confirm == true) {
                  await ReviewService.deleteReview(review.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s.reviewDeleted)));
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context, S s) async {
    await AuthService.signOut();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context)!;
    final user = AuthService.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text(s.profileTitle)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 12),
              Text(s.loginNeedAccount),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                child: Text(s.loginToSeeReviews),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(s.profileTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: s.settingsTitle,
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: s.logout,
            onPressed: () => _logout(context, s),
          ),
        ],
      ),
      body: StreamBuilder<List<Review>>(
        stream: ReviewService.userReviewsStream(user.uid),
        builder: (context, snap) {
          final myReviews = snap.data ?? [];
          final avgRating = myReviews.isEmpty
              ? 0.0
              : myReviews.map((r) => r.overallRating).reduce((a, b) => a + b) / myReviews.length;

          return NestedScrollView(
            headerSliverBuilder: (_, __) => [
              SliverToBoxAdapter(
                child: _ProfileHeader(
                  user: user,
                  displayName: _displayName,
                  photoURL: _photoURL,
                  reviewCount: myReviews.length,
                  avgRating: avgRating,
                  onEditName: () => _showEditNameDialog(s),
                  onEditPhoto: () => _pickAndUploadAvatar(s),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _TabBarDelegate(
                  TabBar(
                    controller: _tabController,
                    tabs: [
                      Tab(text: s.profileMyReviews),
                      Tab(text: s.profileSavedReviews),
                      Tab(icon: const Icon(Icons.notifications_none, size: 20)),
                    ],
                  ),
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                // ── 내 리뷰 탭 ─────────────────────────────────
                snap.connectionState == ConnectionState.waiting
                    ? const Center(child: CircularProgressIndicator())
                    : myReviews.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.rate_review_outlined, size: 64, color: Colors.grey),
                                const SizedBox(height: 12),
                                Text(s.profileNoReviews, style: const TextStyle(color: Colors.grey)),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(top: 4, bottom: 16),
                            itemCount: myReviews.length,
                            itemBuilder: (ctx, i) => Dismissible(
                              key: Key(myReviews[i].id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                color: Colors.red,
                                child: const Icon(Icons.delete_outline, color: Colors.white),
                              ),
                              confirmDismiss: (_) => showDialog<bool>(
                                context: context,
                                builder: (c) => AlertDialog(
                                  title: Text(s.deleteConfirmTitle),
                                  content: Text(s.deleteConfirmBody),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(c, false), child: Text(s.cancel)),
                                    FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(s.delete)),
                                  ],
                                ),
                              ),
                              onDismissed: (_) async {
                                await ReviewService.deleteReview(myReviews[i].id);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s.reviewDeleted)));
                                }
                              },
                              child: GestureDetector(
                                onLongPress: () => _showActions(context, s, myReviews[i]),
                                child: ReviewCard(
                                  review: myReviews[i],
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => ReviewDetailScreen(review: myReviews[i])),
                                  ),
                                ),
                              ),
                            ),
                          ),

                // ── 저장한 리뷰 탭 ─────────────────────────────
                _SavedReviewsTab(uid: user.uid),

                // ── 팔로우한 주소 탭 ────────────────────────────
                _FollowedAddressesTab(uid: user.uid),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  const _TabBarDelegate(this.tabBar);
  final TabBar tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate old) => false;
}

class _SavedReviewsTab extends StatefulWidget {
  const _SavedReviewsTab({required this.uid});
  final String uid;

  @override
  State<_SavedReviewsTab> createState() => _SavedReviewsTabState();
}

class _SavedReviewsTabState extends State<_SavedReviewsTab>
    with AutomaticKeepAliveClientMixin {
  late Future<List<Review>> _future;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _future = BookmarkService.fetchBookmarkedReviews(widget.uid);
  }

  void _reload() => setState(() {
        _future = BookmarkService.fetchBookmarkedReviews(widget.uid);
      });

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final s = S.of(context)!;
    return FutureBuilder<List<Review>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final reviews = snap.data ?? [];
        if (reviews.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.bookmark_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 12),
                Text(s.profileNoSavedReviews, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () async => _reload(),
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 4, bottom: 16),
            itemCount: reviews.length,
            itemBuilder: (_, i) => ReviewCard(
              review: reviews[i],
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ReviewDetailScreen(review: reviews[i])),
                );
                _reload();
              },
            ),
          ),
        );
      },
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.user,
    required this.displayName,
    required this.photoURL,
    required this.reviewCount,
    required this.avgRating,
    required this.onEditName,
    required this.onEditPhoto,
  });

  final User user;
  final String? displayName;
  final String? photoURL;
  final int reviewCount;
  final double avgRating;
  final VoidCallback onEditName;
  final VoidCallback onEditPhoto;

  String _memberSince(S s) {
    final t = user.metadata.creationTime;
    if (t == null) return '';
    const months = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
    return s.profileMemberSince('${months[t.month - 1]} ${t.year}');
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context)!;
    final theme = Theme.of(context);
    final effectiveDisplay = displayName?.isNotEmpty == true ? displayName : null;
    final effectiveFirebase = user.displayName?.isNotEmpty == true ? user.displayName : null;
    final name = effectiveDisplay ?? effectiveFirebase ?? s.profileGuest;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final photoUrl = photoURL ?? user.photoURL;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: const Color(0xFF2E7D32).withAlpha(80), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          // 아바타 + 이름 + 이메일
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Row(
              children: [
                // 아바타 with white border
                GestureDetector(
                  onTap: onEditPhoto,
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: CircleAvatar(
                          radius: 34,
                          backgroundColor: const Color(0xFF1B5E20),
                          backgroundImage: photoUrl != null ? CachedNetworkImageProvider(photoUrl) : null,
                          child: photoUrl == null
                              ? Text(initial, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold))
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: 0, right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [const BoxShadow(color: Colors.black26, blurRadius: 4)],
                          ),
                          child: const Icon(Icons.camera_alt, size: 12, color: Color(0xFF2E7D32)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.white70),
                            tooltip: s.profileEditNameTitle,
                            onPressed: onEditName,
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      if (user.email != null) ...[
                        const SizedBox(height: 4),
                        Text(user.email!, style: const TextStyle(color: Colors.white70, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                      const SizedBox(height: 4),
                      Text(_memberSince(s), style: const TextStyle(color: Colors.white60, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 통계 — white semi-transparent card
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(30),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white24),
            ),
            child: Row(
              children: [
                Expanded(child: _StatCell(value: reviewCount.toString(), label: s.profileReviewCount(reviewCount), light: true)),
                Container(width: 1, height: 36, color: Colors.white30),
                Expanded(child: _StatCell(value: reviewCount == 0 ? '-' : avgRating.toStringAsFixed(1), label: s.profileAvgRating, icon: reviewCount > 0 ? Icons.star_rounded : null, light: true)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FollowedAddressesTab extends StatefulWidget {
  const _FollowedAddressesTab({required this.uid});
  final String uid;

  @override
  State<_FollowedAddressesTab> createState() => _FollowedAddressesTabState();
}

class _FollowedAddressesTabState extends State<_FollowedAddressesTab>
    with AutomaticKeepAliveClientMixin {
  late Future<List<String>> _future;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _future = FollowService.fetchFollowedAddresses(widget.uid);
  }

  void _reload() =>
      setState(() => _future = FollowService.fetchFollowedAddresses(widget.uid));

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final s = S.of(context)!;
    return FutureBuilder<List<String>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final addresses = snap.data ?? [];
        if (addresses.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(s.noFollowedAddresses,
                      style: const TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text(s.followedAddressesHint,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                      textAlign: TextAlign.center),
                ],
              ),
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () async => _reload(),
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: addresses.length,
            separatorBuilder: (_, __) => const Divider(height: 1, indent: 16),
            itemBuilder: (_, i) => ListTile(
              leading: const Icon(Icons.notifications_active,
                  color: Color(0xFF2E7D32)),
              title: Text(addresses[i], maxLines: 2, overflow: TextOverflow.ellipsis),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddressReviewsScreen(
                      address: addresses[i],
                      lat: 0,
                      lng: 0,
                    ),
                  ),
                );
                _reload();
              },
            ),
          ),
        );
      },
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.value, required this.label, this.icon, this.light = false});
  final String value;
  final String label;
  final IconData? icon;
  final bool light;

  @override
  Widget build(BuildContext context) {
    final valueColor = light ? Colors.white : null;
    final labelColor = light ? Colors.white70 : Theme.of(context).colorScheme.onSurfaceVariant;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: Colors.amber),
              const SizedBox(width: 4),
            ],
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: valueColor),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: labelColor)),
      ],
    );
  }
}
