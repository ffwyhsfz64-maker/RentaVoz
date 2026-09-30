import 'dart:convert';
import 'dart:developer' as dev;
import 'package:http/http.dart' as http;
import '../config/api_keys.dart';

class TranslationResult {
  final List<String> translations;
  final List<String> detectedSources; // 각 텍스트의 감지된 원본 언어 코드
  const TranslationResult({required this.translations, required this.detectedSources});
}

class TranslationService {
  static const _endpoint = 'https://translation.googleapis.com/language/translate/v2';

  /// [texts] 배열을 [targetLang]으로 번역. 번역문 + 감지된 원본 언어를 함께 반환.
  static Future<TranslationResult> translate(List<String> texts, String targetLang) async {
    if (texts.every((t) => t.trim().isEmpty)) {
      return TranslationResult(
        translations: texts,
        detectedSources: List.filled(texts.length, targetLang),
      );
    }

    final body = jsonEncode({
      'q': texts,
      'target': targetLang,
      'format': 'text',
    });

    final uri = Uri.parse('$_endpoint?key=$kGoogleApiKey');
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'X-Ios-Bundle-Identifier': 'com.onuri.rentavoz',
      },
      body: body,
    );

    if (response.statusCode != 200) {
      dev.log('Translation API ${response.statusCode}: ${response.body}', name: 'TranslationService');
      throw Exception('${response.statusCode}: ${response.body}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final items = json['data']['translations'] as List;
    final translations = items.map((t) => t['translatedText'] as String).toList();
    final detectedSources = items
        .map((t) => (t['detectedSourceLanguage'] as String?) ?? targetLang)
        .toList();

    return TranslationResult(translations: translations, detectedSources: detectedSources);
  }
}
