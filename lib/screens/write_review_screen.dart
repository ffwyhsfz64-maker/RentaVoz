import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/review.dart';
import '../services/auth_service.dart';
import '../services/review_service.dart';
import '../services/storage_service.dart';
import '../services/vision_service.dart';
import '../widgets/address_field.dart';

class WriteReviewScreen extends StatefulWidget {
  const WriteReviewScreen({super.key, this.existingReview});

  final Review? existingReview;

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _rentCtrl = TextEditingController();
  String _address = '';
  double _lat = 0;
  double _lng = 0;
  final _prosCtrl = TextEditingController();
  final _consCtrl = TextEditingController();

  DateTime? _moveInDate;
  DateTime? _moveOutDate;

  bool get _isEditing => widget.existingReview != null;

  double _landlordRating = 3;
  double _conditionRating = 3;
  double _locationRating = 3;
  double _securityRating = 3;

  String _rentalType = 'house';
  bool _sharedBathroom = false;
  bool _sharedKitchen = false;
  bool _hadFormalContract = false;
  bool _avalRequired = false;
  bool _depositReturned = false;
  bool _utilitiesIncluded = false;
  final List<File> _photoFiles = [];
  File? _comprobanteFile;
  bool _comprobanteIsPdf = false;
  ComprobanteValidationResult? _comprobanteValidation;
  bool _uploading = false;
  bool _validating = false;

  @override
  void initState() {
    super.initState();
    final r = widget.existingReview;
    if (r != null) {
      _address = r.address;
      _lat = r.lat;
      _lng = r.lng;
      _rentCtrl.text = r.monthlyRent.toStringAsFixed(0);
      _moveInDate = r.moveInDate;
      _moveOutDate = r.moveOutDate;
      _landlordRating = r.landlordRating;
      _conditionRating = r.conditionRating;
      _locationRating = r.locationRating;
      _securityRating = r.securityRating;
      _rentalType = r.rentalType;
      _sharedBathroom = r.sharedBathroom;
      _sharedKitchen = r.sharedKitchen;
      _hadFormalContract = r.hadFormalContract;
      _avalRequired = r.avalRequired;
      _depositReturned = r.depositReturned;
      _utilitiesIncluded = r.utilitiesIncluded;
      _prosCtrl.text = r.pros;
      _consCtrl.text = r.cons;
      _existingPhotoUrls = List<String>.from(r.photoUrls);
    }
  }

  List<String> _existingPhotoUrls = [];

  @override
  void dispose() {
    _rentCtrl.dispose();
    _prosCtrl.dispose();
    _consCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhotos() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage(imageQuality: 80);
    if (picked.isEmpty) return;
    final remaining = 5 - _existingPhotoUrls.length - _photoFiles.length;
    final toAdd = picked.take(remaining).map((x) => File(x.path)).toList();
    if (toAdd.isNotEmpty) setState(() => _photoFiles.addAll(toAdd));
  }

  Future<void> _pickPhotosFromCamera() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (picked == null) return;
    final total = _existingPhotoUrls.length + _photoFiles.length;
    if (total >= 5) return;
    setState(() => _photoFiles.add(File(picked.path)));
  }

  Future<void> _pickComprobante() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'heic'],
    );
    if (result == null || result.files.single.path == null) return;

    final path = result.files.single.path!;
    final file = File(path);
    final isPdf = path.toLowerCase().endsWith('.pdf');

    setState(() {
      _comprobanteFile = file;
      _comprobanteIsPdf = isPdf;
      _comprobanteValidation = null;
    });

    if (isPdf) {
      setState(() {
        _comprobanteValidation = const ComprobanteValidationResult(
          isValid: true,
          message: 'PDF adjunto (sin verificación de fecha)',
        );
      });
      return;
    }

    setState(() => _validating = true);
    final validation = await VisionService.validateComprobante(file);
    if (mounted) {
      setState(() {
        _comprobanteValidation = validation;
        _validating = false;
      });
      if (!validation.isValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(validation.message),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _pickDate(bool isMoveIn) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isMoveIn) {
          _moveInDate = picked;
        } else {
          _moveOutDate = picked;
        }
      });
    }
  }

  Widget _ratingRow(String label, double value, ValueChanged<double> onChanged) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        ...List.generate(5, (i) => IconButton(
          icon: Icon(
            i < value ? Icons.star : Icons.star_border,
            color: const Color(0xFF2E7D32),
            size: 28,
          ),
          onPressed: () => onChanged((i + 1).toDouble()),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        )),
      ],
    );
  }

  Widget _switchRow(String label, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      title: Text(label),
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final dateFmtLocale = locale == 'zh' || locale == 'ja' || locale == 'ko' ? 'en' : locale;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? s.editReview : s.newReview),
        actions: [
          TextButton(
            onPressed: _uploading ? null : _submit,
            child: Text(_isEditing ? s.saveButton : s.publishAction),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // --- 임대 유형 ---
            Text(s.rentalTypeLabel, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: [
                ButtonSegment(value: 'house', label: Text(s.rentalTypeHouse), icon: const Icon(Icons.home_outlined, size: 18)),
                ButtonSegment(value: 'room', label: Text(s.rentalTypeRoom), icon: const Icon(Icons.door_front_door_outlined, size: 18)),
              ],
              selected: {_rentalType},
              onSelectionChanged: (v) => setState(() => _rentalType = v.first),
              style: const ButtonStyle(visualDensity: VisualDensity.compact),
            ),
            const SizedBox(height: 24),

            // --- 주소 ---
            Text(s.addressLabel, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            AddressField(
              initialValue: _address,
              onSelected: (result) => setState(() {
                _address = result.address;
                _lat = result.lat;
                _lng = result.lng;
              }),
            ),
            const SizedBox(height: 24),

            // --- 기간 및 임대료 ---
            Text(s.periodLabel, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(_moveInDate == null ? s.moveIn : DateFormat('MMM yyyy', dateFmtLocale).format(_moveInDate!)),
                    onPressed: () => _pickDate(true),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(_moveOutDate == null ? s.moveOut : DateFormat('MMM yyyy', dateFmtLocale).format(_moveOutDate!)),
                    onPressed: () => _pickDate(false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _rentCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: s.rentLabel,
                prefixText: '\$ ',
                border: const OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.isEmpty) ? 'Ingresa el monto' : null,
            ),
            const SizedBox(height: 24),

            // --- 평점 ---
            Text(s.ratingsLabel, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _ratingRow(s.landlordRating, _landlordRating, (v) => setState(() => _landlordRating = v)),
            _ratingRow(s.conditionRating, _conditionRating, (v) => setState(() => _conditionRating = v)),
            _ratingRow(s.locationRating, _locationRating, (v) => setState(() => _locationRating = v)),
            _ratingRow(s.securityRating, _securityRating, (v) => setState(() => _securityRating = v)),
            const SizedBox(height: 24),

            // --- 계약 세부사항 ---
            Text(s.contractSection, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            if (_rentalType == 'room') ...[
              _switchRow(s.sharedBathroom, _sharedBathroom, (v) => setState(() => _sharedBathroom = v)),
              _switchRow(s.sharedKitchen, _sharedKitchen, (v) => setState(() => _sharedKitchen = v)),
            ],
            _switchRow(s.formalContract, _hadFormalContract, (v) => setState(() => _hadFormalContract = v)),
            _switchRow(s.avalRequired, _avalRequired, (v) => setState(() => _avalRequired = v)),
            _switchRow(s.depositReturned, _depositReturned, (v) => setState(() => _depositReturned = v)),
            _switchRow(s.utilitiesIncluded, _utilitiesIncluded, (v) => setState(() => _utilitiesIncluded = v)),
            const SizedBox(height: 24),

            // --- 장단점 ---
            TextFormField(
              controller: _prosCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: s.goodSection,
                prefixIcon: const Icon(Icons.thumb_up_outlined, color: Color(0xFF2E7D32)),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _consCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: s.badSection,
                prefixIcon: const Icon(Icons.thumb_down_outlined, color: Colors.red),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // --- 사진 ---
            Text(s.photosSection, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (_existingPhotoUrls.isNotEmpty || _photoFiles.isNotEmpty)
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ..._existingPhotoUrls.map((url) => _PhotoThumb(
                      child: Image.network(url, fit: BoxFit.cover),
                      onRemove: () => setState(() => _existingPhotoUrls.remove(url)),
                    )),
                    ..._photoFiles.map((f) => _PhotoThumb(
                      child: Image.file(f, fit: BoxFit.cover),
                      onRemove: () => setState(() => _photoFiles.remove(f)),
                    )),
                  ],
                ),
              ),
            if (_existingPhotoUrls.length + _photoFiles.length < 5)
              Row(
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.photo_library_outlined, size: 16),
                    label: Text(s.addPhotos),
                    onPressed: _pickPhotos,
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.camera_alt_outlined, size: 16),
                    label: const Text('Cámara'),
                    onPressed: _pickPhotosFromCamera,
                  ),
                ],
              ),
            Text(
              '${_existingPhotoUrls.length + _photoFiles.length}/5',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // --- 납부 증명서 ---
            Row(
              children: [
                Text(s.comprobanteSection, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                const Tooltip(
                  message: 'Sube tu recibo de renta para verificar\nque realmente viviste en este lugar.\nTu información personal será protegida.',
                  child: Icon(Icons.info_outline, size: 16, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              s.comprobanteOptional,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            if (_comprobanteFile != null) ...[
              _comprobanteIsPdf
                  ? Container(
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.red.withAlpha(15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withAlpha(60)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.picture_as_pdf, color: Colors.red, size: 32),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              _comprobanteFile!.path.split('/').last,
                              style: const TextStyle(fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(_comprobanteFile!, height: 160, width: double.infinity, fit: BoxFit.cover),
                    ),
              const SizedBox(height: 8),
              if (_validating)
                Row(
                  children: [
                    const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                    const SizedBox(width: 8),
                    Text(s.analyzingDoc, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                  ],
                )
              else if (_comprobanteValidation != null)
                Row(
                  children: [
                    Icon(
                      _comprobanteValidation!.isValid ? Icons.check_circle : Icons.warning_amber_rounded,
                      color: _comprobanteValidation!.isValid ? const Color(0xFF2E7D32) : Colors.orange,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _comprobanteValidation!.message,
                        style: TextStyle(
                          fontSize: 12,
                          color: _comprobanteValidation!.isValid ? const Color(0xFF2E7D32) : Colors.orange,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() {
                        _comprobanteFile = null;
                        _comprobanteValidation = null;
                      }),
                      child: Text(s.removeDoc),
                    ),
                  ],
                ),
            ] else
              OutlinedButton.icon(
                icon: const Icon(Icons.upload_file_outlined),
                label: Text(s.uploadComprobante),
                onPressed: _pickComprobante,
              ),
            const SizedBox(height: 32),

            FilledButton(
              onPressed: _uploading ? null : _submit,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: _uploading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(s.publishButton),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final s = S.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    if (_moveInDate == null || _moveOutDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.selectDates)),
      );
      return;
    }
    if (_address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.selectAddress)),
      );
      return;
    }
    setState(() => _uploading = true);
    final reviewId = _isEditing ? widget.existingReview!.id : const Uuid().v4();
    String? comprobanteUrl = _isEditing ? widget.existingReview!.comprobanteUrl : null;
    List<String> photoUrls = List<String>.from(_existingPhotoUrls);
    try {
      if (_comprobanteFile != null && (_comprobanteValidation?.isValid ?? false)) {
        comprobanteUrl = await StorageService.uploadComprobante(reviewId, _comprobanteFile!);
      }
      if (_photoFiles.isNotEmpty) {
        final newUrls = await StorageService.uploadPhotos(reviewId, _photoFiles);
        photoUrls.addAll(newUrls);
      }
    } catch (_) {}

    final uid = AuthService.currentUser?.uid ?? 'anonymous';
    final review = Review(
      id: reviewId,
      userId: uid,
      address: _address,
      lat: _lat,
      lng: _lng,
      moveInDate: _moveInDate!,
      moveOutDate: _moveOutDate!,
      monthlyRent: double.tryParse(_rentCtrl.text) ?? 0,
      landlordRating: _landlordRating,
      conditionRating: _conditionRating,
      locationRating: _locationRating,
      securityRating: _securityRating,
      rentalType: _rentalType,
      sharedBathroom: _rentalType == 'room' ? _sharedBathroom : false,
      sharedKitchen: _rentalType == 'room' ? _sharedKitchen : false,
      hadFormalContract: _hadFormalContract,
      avalRequired: _avalRequired,
      depositReturned: _depositReturned,
      utilitiesIncluded: _utilitiesIncluded,
      pros: _prosCtrl.text.trim(),
      cons: _consCtrl.text.trim(),
      photoUrls: photoUrls,
      comprobanteUrl: comprobanteUrl,
      createdAt: _isEditing ? widget.existingReview!.createdAt : DateTime.now(),
    );
    try {
      await ReviewService.addReview(review);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isEditing ? s.reviewUpdated : s.reviewPublished)),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al publicar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }
}

class _PhotoThumb extends StatelessWidget {
  const _PhotoThumb({required this.child, required this.onRemove});
  final Widget child;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          margin: const EdgeInsets.only(right: 8),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
          child: child,
        ),
        Positioned(
          top: 2,
          right: 10,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
              child: const Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
