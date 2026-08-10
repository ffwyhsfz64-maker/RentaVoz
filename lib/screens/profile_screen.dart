import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/review.dart';
import '../services/auth_service.dart';
import '../services/review_service.dart';
import '../widgets/review_card.dart';
import 'review_detail_screen.dart';
import 'write_review_screen.dart';
import 'auth/login_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _displayName;

  @override
  void initState() {
    super.initState();
    _displayName = AuthService.currentUser?.displayName;
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
          final reviews = snap.data ?? [];
          final avgRating = reviews.isEmpty
              ? 0.0
              : reviews.map((r) => r.overallRating).reduce((a, b) => a + b) / reviews.length;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _ProfileHeader(
                  user: user,
                  displayName: _displayName,
                  reviewCount: reviews.length,
                  avgRating: avgRating,
                  onEditName: () => _showEditNameDialog(s),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Text(
                    s.profileMyReviews,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              if (snap.connectionState == ConnectionState.waiting)
                const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
              else if (reviews.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.rate_review_outlined, size: 64, color: Colors.grey),
                        const SizedBox(height: 12),
                        Text(s.profileNoReviews, style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => Dismissible(
                      key: Key(reviews[i].id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        color: Colors.red,
                        child: const Icon(Icons.delete_outline, color: Colors.white),
                      ),
                      confirmDismiss: (_) => showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(s.deleteConfirmTitle),
                          content: Text(s.deleteConfirmBody),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(s.cancel)),
                            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(s.delete)),
                          ],
                        ),
                      ),
                      onDismissed: (_) async {
                        await ReviewService.deleteReview(reviews[i].id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s.reviewDeleted)));
                        }
                      },
                      child: GestureDetector(
                        onLongPress: () => _showActions(context, s, reviews[i]),
                        child: ReviewCard(
                          review: reviews[i],
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => ReviewDetailScreen(review: reviews[i])),
                          ),
                        ),
                      ),
                    ),
                    childCount: reviews.length,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.user,
    required this.displayName,
    required this.reviewCount,
    required this.avgRating,
    required this.onEditName,
  });

  final User user;
  final String? displayName;
  final int reviewCount;
  final double avgRating;
  final VoidCallback onEditName;

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
    final photoUrl = user.photoURL;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // 아바타 + 이름 + 이메일
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            child: Row(
              children: [
                // 아바타
                CircleAvatar(
                  radius: 36,
                  backgroundColor: const Color(0xFF2E7D32),
                  backgroundImage: photoUrl != null ? CachedNetworkImageProvider(photoUrl) : null,
                  child: photoUrl == null
                      ? Text(initial, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold))
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 이름 + 편집 버튼
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            tooltip: s.profileEditNameTitle,
                            onPressed: onEditName,
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      if (user.email != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          user.email!,
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        _memberSince(s),
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // 통계
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: _StatCell(
                    value: reviewCount.toString(),
                    label: s.profileReviewCount(reviewCount),
                  ),
                ),
                Container(width: 1, height: 40, color: theme.dividerColor),
                Expanded(
                  child: _StatCell(
                    value: reviewCount == 0 ? '-' : avgRating.toStringAsFixed(1),
                    label: s.profileAvgRating,
                    icon: reviewCount > 0 ? Icons.star_rounded : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.value, required this.label, this.icon});
  final String value;
  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
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
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ],
    );
  }
}
