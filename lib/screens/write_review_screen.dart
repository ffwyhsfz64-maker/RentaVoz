import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WriteReviewScreen extends StatefulWidget {
  const WriteReviewScreen({super.key});

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressCtrl = TextEditingController();
  final _rentCtrl = TextEditingController();
  final _prosCtrl = TextEditingController();
  final _consCtrl = TextEditingController();

  DateTime? _moveInDate;
  DateTime? _moveOutDate;

  double _landlordRating = 3;
  double _conditionRating = 3;
  double _locationRating = 3;
  double _securityRating = 3;

  bool _hadFormalContract = false;
  bool _avalRequired = false;
  bool _depositReturned = false;
  bool _utilitiesIncluded = false;

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
  void dispose() {
    _addressCtrl.dispose();
    _rentCtrl.dispose();
    _prosCtrl.dispose();
    _consCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva reseña'),
        actions: [
          TextButton(
            onPressed: _submit,
            child: const Text('Publicar'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // --- Dirección ---
            Text('Dirección', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _addressCtrl,
              decoration: const InputDecoration(
                hintText: 'Ej. Calle Morelos 123, Col. Centro, Querétaro',
                prefixIcon: Icon(Icons.location_on_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.isEmpty) ? 'Ingresa la dirección' : null,
            ),
            const SizedBox(height: 24),

            // --- Período y renta ---
            Text('Período de arrendamiento', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(_moveInDate == null ? 'Entrada' : DateFormat('MMM yyyy', 'es').format(_moveInDate!)),
                    onPressed: () => _pickDate(true),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(_moveOutDate == null ? 'Salida' : DateFormat('MMM yyyy', 'es').format(_moveOutDate!)),
                    onPressed: () => _pickDate(false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _rentCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Renta mensual (MXN)',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.isEmpty) ? 'Ingresa el monto' : null,
            ),
            const SizedBox(height: 24),

            // --- Calificaciones ---
            Text('Calificaciones', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _ratingRow('Arrendador / Propietario', _landlordRating, (v) => setState(() => _landlordRating = v)),
            _ratingRow('Estado del inmueble', _conditionRating, (v) => setState(() => _conditionRating = v)),
            _ratingRow('Ubicación', _locationRating, (v) => setState(() => _locationRating = v)),
            _ratingRow('Seguridad', _securityRating, (v) => setState(() => _securityRating = v)),
            const SizedBox(height: 24),

            // --- Detalles del contrato ---
            Text('Detalles del contrato', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            _switchRow('Contrato formal', _hadFormalContract, (v) => setState(() => _hadFormalContract = v)),
            _switchRow('Requirió aval', _avalRequired, (v) => setState(() => _avalRequired = v)),
            _switchRow('Depósito devuelto', _depositReturned, (v) => setState(() => _depositReturned = v)),
            _switchRow('Servicios incluidos (agua/luz/gas)', _utilitiesIncluded, (v) => setState(() => _utilitiesIncluded = v)),
            const SizedBox(height: 24),

            // --- Pros / Contras ---
            Text('Lo bueno y lo malo', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _prosCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: '¿Qué te gustó?',
                prefixIcon: Icon(Icons.thumb_up_outlined, color: Color(0xFF2E7D32)),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _consCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: '¿Qué no te gustó?',
                prefixIcon: Icon(Icons.thumb_down_outlined, color: Colors.red),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // --- Fotos ---
            Text('Fotos', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: const Text('Agregar fotos'),
              onPressed: () {
                // TODO: image_picker integration
              },
            ),
            const SizedBox(height: 32),

            FilledButton(
              onPressed: _submit,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Publicar reseña'),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_moveInDate == null || _moveOutDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona las fechas de entrada y salida')),
      );
      return;
    }
    // TODO: save to Firestore
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reseña publicada (próximamente con Firebase)')),
    );
    Navigator.pop(context);
  }
}
