import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/bookmark_service.dart';

class BookmarkButton extends StatefulWidget {
  const BookmarkButton({
    super.key,
    required this.reviewId,
    this.size = 22.0,
    this.color,
  });

  final String reviewId;
  final double size;
  final Color? color;

  @override
  State<BookmarkButton> createState() => _BookmarkButtonState();
}

class _BookmarkButtonState extends State<BookmarkButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  bool _saved = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scale = Tween<double>(begin: 1.0, end: 1.35).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _load();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    final saved = await BookmarkService.isBookmarked(uid, widget.reviewId);
    if (mounted) setState(() { _saved = saved; _loading = false; });
  }

  Future<void> _toggle() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final prev = _saved;
    setState(() => _saved = !prev);

    await _ctrl.forward();
    _ctrl.reverse();

    final nowSaved = await BookmarkService.toggle(uid, widget.reviewId);
    if (!mounted) return;
    setState(() => _saved = nowSaved);

    final s = S.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(nowSaved ? s.bookmarkAdded : s.bookmarkRemoved),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return SizedBox(
        width: widget.size + 8,
        height: widget.size + 8,
        child: const Center(
          child: SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 1.5)),
        ),
      );
    }

    final s = S.of(context)!;
    final iconColor = widget.color ?? Theme.of(context).colorScheme.primary;

    return ScaleTransition(
      scale: _scale,
      child: IconButton(
        icon: Icon(
          _saved ? Icons.bookmark : Icons.bookmark_outline,
          size: widget.size,
          color: _saved ? iconColor : Colors.grey,
        ),
        tooltip: _saved ? s.bookmarkRemove : s.bookmarkAdd,
        onPressed: _toggle,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
