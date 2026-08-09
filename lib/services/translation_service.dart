import 'dart:convert';
import 'dart:developer' as dev;
import 'package:http/http.dart' as http;
import '../config/api_keys.dart';

class TranslationService {
  static const _endpoint = 'https://translation.googleapis.com/language/translate/v2';

  /// [texts] 배열을 [targetLang]으로 번역해서 같은 순서의 문자열 배열 반환.
  static Future<List<String>> translate(List<String> texts, String targetLang) async {
    if (texts.every((t) => t.trim().isEmpty)) return texts;

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
    final translations = (json['data']['translations'] as List)
        .map((t) => (t['translatedText'] as String))
        .toList();

    return translations;
  }
}
