import 'dart:convert';
import 'package:http/http.dart' as http;

class DictaService {
  static const String baseUrl = 'https://dicta-api.dicta.org.il';
  
  Future<String> cleanText(String text) async {
    try {
      print('Dicta Service - Starting text cleaning');
      print('Dicta Service - Original text: "$text"');
      
      final requestBody = {
        'text': text,
        'addNiqqud': false,
        'genre': 'modern',
      };
      print('Dicta Service - Sending request with body: $requestBody');

      final response = await http.post(
        Uri.parse('$baseUrl/api/nakdan'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      print('Dicta Service - Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final cleanedText = json.decode(response.body)['text'];
        print('Dicta Service - Successfully cleaned text');
        print('Dicta Service - Cleaned text: "$cleanedText"');
        return cleanedText;
      } else {
        print('Dicta Service - Error response: ${response.body}');
        print('Dicta Service - Falling back to original text');
        return text;
      }
    } catch (e) {
      print('Dicta Service - Error occurred: $e');
      print('Dicta Service - Falling back to original text');
      return text;
    }
  }
} 