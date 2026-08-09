import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_keys.dart';

class ComprobanteValidationResult {
  final bool isValid;
  final String message;
  final DateTime? detectedDate;

  const ComprobanteValidationResult({
    required this.isValid,
    required this.message,
    this.detectedDate,
  });
}

class VisionService {
  static const _headers = {
    'Content-Type': 'application/json',
    'x-ios-bundle-identifier': 'com.onuri.rentavoz',
  };

  static Future<ComprobanteValidationResult> validateComprobante(File image) async {
    final bytes = await image.readAsBytes();
    final base64Image = base64Encode(bytes);

    final uri = Uri.parse(
      'https://vision.googleapis.com/v1/images:annotate?key=$kGoogleApiKey',
    );

    final body = jsonEncode({
      'requests': [
        {
          'image': {'content': base64Image},
          'features': [
            {'type': 'TEXT_DETECTION', 'maxResults': 1}
          ],
        }
      ]
    });

    try {
      final res = await http.post(uri, headers: _headers, body: body);
      if (res.statusCode != 200) {
        return const ComprobanteValidationResult(
          isValid: false,
          message: 'No se pudo analizar el documento. Intenta de nuevo.',
        );
      }

      final data = jsonDecode(res.body);
      final text = (data['responses']?[0]?['fullTextAnnotation']?['text'] as String?) ?? '';

      if (text.isEmpty) {
        return const ComprobanteValidationResult(
          isValid: false,
          message: 'No se pudo leer texto en la imagen. Asegúrate de que sea legible.',
        );
      }

      return _parseDates(text);
    } catch (e) {
      return const ComprobanteValidationResult(
        isValid: false,
        message: 'Error al analizar el documento.',
      );
    }
  }

  static ComprobanteValidationResult _parseDates(String text) {
    final upperText = text.toUpperCase();
    final now = DateTime.now();
    final threeMonthsAgo = now.subtract(const Duration(days: 90));

    // Buscar todas las fechas en el texto
    final dates = _extractDates(upperText);

    if (dates.isEmpty) {
      return const ComprobanteValidationResult(
        isValid: false,
        message: 'No se encontraron fechas en el documento. Verifica que sea un comprobante válido.',
      );
    }

    // Ordenar fechas de más reciente a más antigua
    dates.sort((a, b) => b.compareTo(a));
    final mostRecent = dates.first;

    if (mostRecent.isAfter(threeMonthsAgo)) {
      return ComprobanteValidationResult(
        isValid: true,
        message: 'Documento válido (${_fmtDate(mostRecent)})',
        detectedDate: mostRecent,
      );
    } else {
      return ComprobanteValidationResult(
        isValid: false,
        message:
            'El comprobante es de ${_fmtDate(mostRecent)}, '
            'más de 3 meses de antigüedad. '
            'Se requiere un comprobante reciente.',
        detectedDate: mostRecent,
      );
    }
  }

  static List<DateTime> _extractDates(String text) {
    final dates = <DateTime>[];

    // Formato DD/MM/YYYY o DD-MM-YYYY
    final pattern1 = RegExp(r'\b(\d{1,2})[/\-](\d{1,2})[/\-](20\d{2})\b');
    for (final m in pattern1.allMatches(text)) {
      final d = _tryParseDate(int.parse(m.group(1)!), int.parse(m.group(2)!), int.parse(m.group(3)!));
      if (d != null) dates.add(d);
    }

    // Formato YYYY/MM/DD o YYYY-MM-DD
    final pattern2 = RegExp(r'\b(20\d{2})[/\-](\d{1,2})[/\-](\d{1,2})\b');
    for (final m in pattern2.allMatches(text)) {
      final d = _tryParseDate(int.parse(m.group(3)!), int.parse(m.group(2)!), int.parse(m.group(1)!));
      if (d != null) dates.add(d);
    }

    // Formato "01 ENERO 2026" o "1 DE ENERO DE 2026"
    final monthNames = {
      'ENERO': 1, 'FEBRERO': 2, 'MARZO': 3, 'ABRIL': 4,
      'MAYO': 5, 'JUNIO': 6, 'JULIO': 7, 'AGOSTO': 8,
      'SEPTIEMBRE': 9, 'OCTUBRE': 10, 'NOVIEMBRE': 11, 'DICIEMBRE': 12,
      'ENE': 1, 'FEB': 2, 'MAR': 3, 'ABR': 4, 'MAY': 5, 'JUN': 6,
      'JUL': 7, 'AGO': 8, 'SEP': 9, 'OCT': 10, 'NOV': 11, 'DIC': 12,
    };
    final pattern3 = RegExp(
      r'\b(\d{1,2})\s+(?:DE\s+)?(ENERO|FEBRERO|MARZO|ABRIL|MAYO|JUNIO|JULIO|AGOSTO|SEPTIEMBRE|OCTUBRE|NOVIEMBRE|DICIEMBRE|ENE|FEB|MAR|ABR|MAY|JUN|JUL|AGO|SEP|OCT|NOV|DIC)\s+(?:DE\s+)?(20\d{2})\b',
    );
    for (final m in pattern3.allMatches(text)) {
      final month = monthNames[m.group(2)!];
      if (month != null) {
        final d = _tryParseDate(int.parse(m.group(1)!), month, int.parse(m.group(3)!));
        if (d != null) dates.add(d);
      }
    }

    // Solo mes y año: "ENERO 2026" — usar último día del mes
    final pattern4 = RegExp(
      r'\b(ENERO|FEBRERO|MARZO|ABRIL|MAYO|JUNIO|JULIO|AGOSTO|SEPTIEMBRE|OCTUBRE|NOVIEMBRE|DICIEMBRE)\s+(20\d{2})\b',
    );
    for (final m in pattern4.allMatches(text)) {
      final month = monthNames[m.group(1)!]!;
      final year = int.parse(m.group(2)!);
      final lastDay = DateTime(year, month + 1, 0).day;
      final d = _tryParseDate(lastDay, month, year);
      if (d != null) dates.add(d);
    }

    return dates;
  }

  static DateTime? _tryParseDate(int day, int month, int year) {
    try {
      if (month < 1 || month > 12 || day < 1 || day > 31 || year < 2000 || year > 2099) return null;
      final date = DateTime(year, month, day);
      // Ignorar fechas futuras lejanas o muy antiguas
      if (date.isAfter(DateTime.now().add(const Duration(days: 30)))) return null;
      if (date.isBefore(DateTime(2000))) return null;
      return date;
    } catch (_) {
      return null;
    }
  }

  static String _fmtDate(DateTime d) {
    const months = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}
