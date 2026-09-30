import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../l10n/app_localizations.dart';
import '../models/review.dart';
import '../services/report_service.dart';
import '../services/review_service.dart';
import '../services/translation_service.dart';
import 'address_reviews_screen.dart';
import 'write_review_screen.dart';
import '../widgets/bookmark_button.dart';

class ReviewDetailScreen extends StatefulWidget {
  const ReviewDetailScreen({super.key, required this.review});
  final Review review;

  @override
  State<ReviewDetailScreen> createState() => _ReviewDetailScreenState();
}

class _ReviewDetailScreenState extends State<ReviewDetailScreen> {
  // Keep a live copy from Firestore so edits by others are reflected
  Review get _review => _liveReview ?? widget.review;
  Review? _liveReview;
  StreamSubscription<Review?>? _reviewSub;

  @override
  void initState() {
    super.initState();
    _reviewSub = ReviewService.reviewStream(widget.review.id).listen((r) {
      if (r != null && mounted) setState(() => _liveReview = r);
    });
  }

  @override
  void dispose() {
    _reviewSub?.cancel();
    super.dispose();
  }

  String? _translatedPros;
  String? _translatedCons;
  String? _translatedToLang; // 현재 캐시된 번역의 대상 언어
  bool _sourceIsSameAsTarget = false; // 원문이 이미 현재 UI 언어인지 (감지 결과)
  bool _showTranslation = false;
  bool _translating = false;
  String? _translationError;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _maybeAutoTranslate();
  }

  // 리뷰를 열거나 언어를 바꿀 때, 원문 언어를 자동 감지해 필요하면 번역한다.
  void _maybeAutoTranslate() {
    final currentLang = Localizations.localeOf(context).languageCode;
    final review = _review;
    final hasContent = review.pros.isNotEmpty || review.cons.isNotEmpty;
    if (!hasContent) return;
    // 저장된 작성 언어가 현재 UI 언어와 확실히 같으면 호출 불필요 (비용 절감)
    if (review.language != null && review.language == currentLang) return;
    if (_translating) return;
    if (_translatedToLang == currentLang) return; // 이미 이 언어로 번역 완료
    _translate();
  }

  Future<void> _translate() async {
    final targetLang = Localizations.localeOf(context).languageCode;
    setState(() {
      _translating = true;
      _translationError = null;
    });

    try {
      final review = _review;
      final texts = [
        review.pros.isNotEmpty ? review.pros : ' ',
        review.cons.isNotEmpty ? review.cons : ' ',
      ];
      final result = await TranslationService.translate(texts, targetLang);
      // 실제 내용이 있는 항목의 감지 언어만 확인
      final detected = <String>[];
      if (review.pros.isNotEmpty) detected.add(result.detectedSources[0]);
      if (review.cons.isNotEmpty) detected.add(result.detectedSources[1]);
      final sameLang = detected.isNotEmpty && detected.every((l) => l == targetLang);
      setState(() {
        _translatedPros = result.translations[0].trim();
        _translatedCons = result.translations[1].trim();
        _translatedToLang = targetLang;
        _sourceIsSameAsTarget = sameLang;
        _showTranslation = !sameLang; // 이미 같은 언어면 원문 그대로 표시
      });
    } catch (e) {
      if (!mounted) return;
      final s = S.of(context)!;
      setState(() => _translationError = '${s.translationError}\n($e)');
    } finally {
      if (mounted) setState(() => _translating = false);
    }
  }

  void _share(S s) {
    final review = _review;
    final stars = '⭐' * review.overallRating.round();
    final buf = StringBuffer();
    buf.writeln('$stars ${review.overallRating.toStringAsFixed(1)}/5.0');
    buf.writeln('📍 ${review.address}');
    buf.writeln();
    if (review.pros.isNotEmpty) buf.writeln('👍 ${review.pros}');
    if (review.cons.isNotEmpty) buf.writeln('👎 ${review.cons}');
    buf.writeln();
    buf.writeln('${s.shareRent}: \$${review.monthlyRent.toStringAsFixed(0)} MXN');
    buf.writeln('${s.sharePeriod}: ${_fmtDate(review.moveInDate)} – ${_fmtDate(review.moveOutDate)}');
    buf.writeln();
    buf.write(s.shareAppPromo);

    Share.share(buf.toString(), subject: s.shareReviewSubject);
  }

  void _toggleTranslation() {
    if (_showTranslation) {
      setState(() => _showTranslation = false);
    } else if (_translatedPros != null) {
      setState(() => _showTranslation = true);
    } else {
      _translate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context)!;
    final theme = Theme.of(context);
    final review = _review;
    final hasContent = review.pros.isNotEmpty || review.cons.isNotEmpty;
    final currentLang = Localizations.localeOf(context).languageCode;
    // 저장된 언어가 현재 UI 언어와 같거나(비용 절감), 감지 결과 같으면 번역 UI 숨김
    final knownSameLang = review.language != null && review.language == currentLang;
    final canTranslate = !knownSameLang && !_sourceIsSameAsTarget;

    return Scaffold(
      appBar: AppBar(
        title: Text(s.detailTitle),
        actions: [
          if (FirebaseAuth.instance.currentUser != null)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: BookmarkButton(reviewId: review.id, size: 24),
            ),
          IconButton(icon: const Icon(Icons.share_outlined), onPressed: () => _share(s)),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (v) {
              if (v == 'report') _showReportSheet(s);
              if (v == 'delete') _confirmDelete(s);
              if (v == 'edit') _editReview();
            },
            itemBuilder: (_) {
              final isOwner = FirebaseAuth.instance.currentUser?.uid == review.userId;
              return [
                if (isOwner) ...[
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF2E7D32)),
                        const SizedBox(width: 10),
                        Text(s.editReview),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                        const SizedBox(width: 10),
                        Text(s.deleteReview, style: const TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                ],
                PopupMenuItem(
                  value: 'report',
                  child: Row(
                    children: [
                      const Icon(Icons.flag_outlined, size: 18, color: Colors.red),
                      const SizedBox(width: 10),
                      Text(s.reportButton, style: const TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ── Photo carousel (if available) ───────────────────────
          if (review.photoUrls.isNotEmpty)
            _PhotoCarousel(urls: review.photoUrls),

          Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // 전체 평점 히어로
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.overallRating.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(s.overallOf5, style: const TextStyle(color: Colors.white70)),
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    children: [
                      _RatingBar(label: s.landlordRating, value: review.landlordRating),
                      _RatingBar(label: s.conditionRating, value: review.conditionRating),
                      _RatingBar(label: s.locationRating, value: review.locationRating),
                      _RatingBar(label: s.securityRating, value: review.securityRating),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 주소
          _Section(
            title: s.addressLabel,
            child: Row(
              children: [
                const Icon(Icons.location_on_outlined, color: Color(0xFF2E7D32)),
                const SizedBox(width: 8),
                Expanded(child: Text(review.address)),
              ],
            ),
          ),

          // 기간 및 임대료
          _Section(
            title: s.periodLabel,
            child: Row(
              children: [
                Expanded(child: _InfoTile(icon: Icons.calendar_month_outlined, label: s.moveIn, value: _fmtDate(review.moveInDate))),
                Expanded(child: _InfoTile(icon: Icons.calendar_month, label: s.moveOut, value: _fmtDate(review.moveOutDate))),
                Expanded(child: _InfoTile(icon: Icons.attach_money, label: s.rent, value: '\$${review.monthlyRent.toStringAsFixed(0)}')),
              ],
            ),
          ),

          // 계약
          _Section(
            title: s.contractSection,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 임대 유형 뱃지
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(
                        review.rentalType == 'room' ? Icons.door_front_door_outlined : review.rentalType == 'apartment' ? Icons.apartment_outlined : Icons.home_outlined,
                        size: 18,
                        color: review.rentalType == 'room' ? Colors.purple : review.rentalType == 'apartment' ? Colors.indigo : const Color(0xFF2E7D32),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        review.rentalType == 'room' ? s.rentalTypeRoom : s.rentalTypeHouse,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: review.rentalType == 'room' ? Colors.purple : const Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ),
                ),
                if (review.rentalType == 'room') ...[
                  _BoolRow(label: s.sharedBathroom, value: review.sharedBathroom, invertColor: true),
                  _BoolRow(label: s.sharedKitchen, value: review.sharedKitchen, invertColor: true),
                ],
                _BoolRow(label: s.formalContract, value: review.hadFormalContract),
                _BoolRow(label: s.avalRequired, value: review.avalRequired, invertColor: true),
                _BoolRow(label: s.depositReturned, value: review.depositReturned),
                _BoolRow(label: s.utilitiesIncluded, value: review.utilitiesIncluded),
              ],
            ),
          ),

          // 장단점 + 번역 버튼
          if (hasContent) ...[
            // 번역 상태 배너
            if (_showTranslation)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withAlpha(60)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.translate, size: 14, color: Colors.blue),
                    const SizedBox(width: 6),
                    Text(s.translationLabel, style: const TextStyle(fontSize: 12, color: Colors.blue)),
                    const Spacer(),
                    GestureDetector(
                      onTap: _toggleTranslation,
                      child: Text(s.showOriginal, style: const TextStyle(fontSize: 12, color: Colors.blue, decoration: TextDecoration.underline)),
                    ),
                  ],
                ),
              ),

            if (review.pros.isNotEmpty)
              _Section(
                title: s.goodSection,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.thumb_up_outlined, size: 18, color: Color(0xFF2E7D32)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _showTranslation && _translatedPros != null ? _translatedPros! : review.pros,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),

            if (review.cons.isNotEmpty)
              _Section(
                title: s.badSection,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.thumb_down_outlined, size: 18, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _showTranslation && _translatedCons != null ? _translatedCons! : review.cons,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),

            // 번역 버튼 (번역 중 / 에러 / 기본) — 작성 언어가 UI 언어와 다를 때만
            if (canTranslate)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _translating
                  ? Row(
                      children: [
                        const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                        const SizedBox(width: 8),
                        Text(s.translating, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                      ],
                    )
                  : _translationError != null
                      ? Row(
                          children: [
                            const Icon(Icons.error_outline, size: 16, color: Colors.orange),
                            const SizedBox(width: 6),
                            Expanded(child: Text(_translationError!, style: const TextStyle(fontSize: 12, color: Colors.orange))),
                            TextButton(
                              onPressed: _translate,
                              child: Text(s.translateButton),
                            ),
                          ],
                        )
                      : !_showTranslation
                          ? OutlinedButton.icon(
                              icon: const Icon(Icons.translate, size: 16),
                              label: Text(s.translateButton),
                              onPressed: _toggleTranslation,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.blue,
                                side: const BorderSide(color: Colors.blue),
                              ),
                            )
                          : const SizedBox.shrink(),
            ),
          ],

          // 사진
          if (review.photoUrls.isNotEmpty) ...[
            _Section(
              title: s.photosSection,
              child: SizedBox(
                height: 180,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: review.photoUrls.length,
                  separatorBuilder: (_, i) => const SizedBox(width: 8),
                  itemBuilder: (context, i) => GestureDetector(
                    onTap: () => _showPhoto(context, review.photoUrls, i),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: review.photoUrls[i],
                        width: 180,
                        height: 180,
                        fit: BoxFit.cover,
                        placeholder: (ctx, url) => const SizedBox(width: 180, child: Center(child: CircularProgressIndicator())),
                        errorWidget: (ctx, url, err) => const SizedBox(width: 180, child: Center(child: Icon(Icons.broken_image_outlined))),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],

          // 납부 증명서 (이미지 OCR 검증됨)
          if (review.isVerified) ...[
            _Section(
              title: s.comprobanteSection,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32).withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF2E7D32).withAlpha(80)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified_outlined, size: 16, color: Color(0xFF2E7D32)),
                        const SizedBox(width: 6),
                        Text(s.badgeVerified, style: const TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: review.comprobanteUrl!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const SizedBox(height: 120, child: Center(child: CircularProgressIndicator())),
                      errorWidget: (context, url, err) => const SizedBox(height: 60, child: Center(child: Icon(Icons.broken_image_outlined, color: Colors.grey))),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // 납부 증명서 (PDF 첨부 — 날짜 미검증)
          if (review.hasPdfAttachment) ...[
            _Section(
              title: s.comprobanteSection,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withAlpha(80)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.picture_as_pdf_outlined, size: 16, color: Colors.orange),
                    const SizedBox(width: 6),
                    Text(s.pdfAttached, style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 8),

          // 같은 주소 리뷰 배너
          FutureBuilder<List<Review>>(
            future: ReviewService.fetchSameLocation(
              address: review.address,
              lat: review.lat,
              lng: review.lng,
              excludeId: review.id,
            ),
            builder: (context, snap) {
              final others = snap.data ?? [];
              if (others.isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddressReviewsScreen(
                        address: review.address,
                        lat: review.lat,
                        lng: review.lng,
                        excludeId: review.id,
                      ),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32).withAlpha(15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF2E7D32).withAlpha(60)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.home_work_outlined, color: Color(0xFF2E7D32), size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            s.addressReviewsOther(others.length),
                            style: const TextStyle(
                              color: Color(0xFF2E7D32),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Color(0xFF2E7D32)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          Text(
            s.publishedOn(_fmtDateFull(review.createdAt)),
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          ]), // end Column
          ), // end Padding
        ],
      ),
    );
  }

  void _editReview() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => WriteReviewScreen(existingReview: _review)),
    );
  }

  Future<void> _confirmDelete(S s) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.deleteConfirmTitle),
        content: Text(s.deleteConfirmBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(s.cancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(s.delete),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    await ReviewService.deleteReview(widget.review.id, photoUrls: widget.review.photoUrls, comprobanteUrl: widget.review.comprobanteUrl);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s.reviewDeleted)));
    Navigator.of(context).pop();
  }

  void _showReportSheet(S s) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null) return;
    if (_review.userId == currentUid) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s.reportOwnReview)));
      return;
    }

    String? selected;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final reasons = [
            s.reportReasonFalse,
            s.reportReasonSpam,
            s.reportReasonInappropriate,
            s.reportReasonOther,
          ];
          return Padding(
            padding: EdgeInsets.only(
              left: 20, right: 20, top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.reportTitle, style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                RadioGroup<String>(
                  groupValue: selected,
                  onChanged: (v) => setSheetState(() => selected = v),
                  child: Column(
                    children: reasons.map((r) => RadioListTile<String>(
                      value: r,
                      title: Text(r),
                      contentPadding: EdgeInsets.zero,
                      activeColor: const Color(0xFF2E7D32),
                    )).toList(),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: selected == null
                        ? null
                        : () async {
                            Navigator.pop(ctx);
                            await _submitReport(s, selected!);
                          },
                    child: Text(s.reportSubmit),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _submitReport(S s, String reason) async {
    try {
      final already = await ReportService.hasReported(_review.id);
      if (!mounted) return;
      if (already) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s.reportAlready)));
        return;
      }
      await ReportService.submit(_review.id, reason);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.reportSuccess), backgroundColor: const Color(0xFF2E7D32)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.reportError), backgroundColor: Colors.red),
      );
    }
  }

  void _showPhoto(BuildContext context, List<String> urls, int initial) {
    final controller = PageController(initialPage: initial);
    showDialog(
      context: context,
      builder: (_) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            PageView.builder(
              controller: controller,
              itemCount: urls.length,
              itemBuilder: (_, i) => InteractiveViewer(
                child: Center(
                  child: CachedNetworkImage(imageUrl: urls[i], fit: BoxFit.contain),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmtDate(DateTime d) => '${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _fmtDateFull(DateTime d) {
    const months = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

// ─── 공통 위젯 ────────────────────────────────────────────────────

class _PhotoCarousel extends StatefulWidget {
  const _PhotoCarousel({required this.urls});
  final List<String> urls;

  @override
  State<_PhotoCarousel> createState() => _PhotoCarouselState();
}

class _PhotoCarouselState extends State<_PhotoCarousel> {
  int _page = 0;

  void _showFull(BuildContext context, int initial) {
    final controller = PageController(initialPage: initial);
    showDialog(
      context: context,
      builder: (_) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            PageView.builder(
              controller: controller,
              itemCount: widget.urls.length,
              itemBuilder: (_, i) => InteractiveViewer(
                child: Center(child: CachedNetworkImage(imageUrl: widget.urls[i], fit: BoxFit.contain)),
              ),
            ),
            Positioned(
              top: 40, right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: Stack(
        children: [
          PageView.builder(
            itemCount: widget.urls.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (_, i) => GestureDetector(
              onTap: () => _showFull(context, i),
              child: CachedNetworkImage(
                imageUrl: widget.urls[i],
                fit: BoxFit.cover,
                width: double.infinity,
                placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
                errorWidget: (_, __, ___) => const Center(child: Icon(Icons.broken_image_outlined, size: 48, color: Colors.grey)),
              ),
            ),
          ),
          if (widget.urls.length > 1)
            Positioned(
              bottom: 12,
              left: 0, right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.urls.length, (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _page == i ? 16 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _page == i ? Colors.white : Colors.white54,
                    borderRadius: BorderRadius.circular(3),
                  ),
                )),
              ),
            ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32).withAlpha(18),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF2E7D32),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),
          ),
          const SizedBox(height: 10),
          child,
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _RatingBar extends StatelessWidget {
  const _RatingBar({required this.label, required this.value});
  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(width: 70, child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11))),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: value / 5,
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(value.toStringAsFixed(0), style: const TextStyle(color: Colors.white, fontSize: 11)),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF2E7D32)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _BoolRow extends StatelessWidget {
  const _BoolRow({required this.label, required this.value, this.invertColor = false});
  final String label;
  final bool value;
  final bool invertColor;

  @override
  Widget build(BuildContext context) {
    // 아이콘 모양은 실제 값(예/아니오)을 그대로 표현하고,
    // 색상만 좋음(녹색)/나쁨(빨강)을 나타낸다. invertColor는 색상에만 영향.
    final positive = invertColor ? !value : value;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            value ? Icons.check_circle_outline : Icons.cancel_outlined,
            size: 18,
            color: positive ? const Color(0xFF2E7D32) : Colors.red,
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}
