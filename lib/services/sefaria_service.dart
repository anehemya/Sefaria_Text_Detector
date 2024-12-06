import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/sefaria_match.dart';
import 'dicta_service.dart';

class SefariaService {
  static const String baseUrl = 'https://www.sefaria.org/api';
  static const int pageSize = 10;
  
  final DictaService _dictaService;
  
  SefariaService([DictaService? dictaService]) 
      : _dictaService = dictaService ?? DictaService();

  Future<Map<String, dynamic>> searchText(
    String query, {
    int from = 0,
  }) async {
    try {
      print('\nSefaria Service - Starting new search');
      print('Sefaria Service - Original query: "$query"');
      
      print('Sefaria Service - Sending text to Dicta for cleaning...');
      final cleanedQuery = await _dictaService.cleanText(query);
      print('Sefaria Service - Received cleaned text: "$cleanedQuery"');
      
      final requestBody = {
        "query": {
          "match_phrase": {
            "exact": cleanedQuery
          }
        },
        "size": pageSize,
        "from": from
      };
      print('Sefaria Service - Sending search request with body: $requestBody');

      final response = await http.post(
        Uri.parse('$baseUrl/search/text/_search'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      print('Sefaria Service - Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final results = json.decode(response.body);
        final hitCount = results['hits']['total'];
        print('Sefaria Service - Search successful');
        print('Sefaria Service - Found $hitCount results');
        return results;
      } else {
        print('Sefaria Service - Search failed with status: ${response.statusCode}');
        print('Sefaria Service - Error response: ${response.body}');
        throw Exception('Failed to search Sefaria: ${response.statusCode}');
      }
    } catch (e) {
      print('Sefaria Service - Error occurred: $e');
      throw Exception('Error searching Sefaria: $e');
    }
  }

  String generateSefariaLink(String ref) {
    print('Sefaria Service - Generating link for ref: "$ref"');
    final link = 'https://www.sefaria.org/${Uri.encodeComponent(ref)}';
    print('Sefaria Service - Generated link: $link');
    return link;
  }

  List<SefariaMatch> parseResults(Map<String, dynamic> searchResult) {
    print('Sefaria Service - Parsing search results');
    try {
      final hits = searchResult['hits']['hits'] as List;
      return hits.map((hit) {
        final source = hit['_source'];
        final match = SefariaMatch(
          reference: source['ref'] ?? '',
          url: generateSefariaLink(source['ref'] ?? ''),
          snippet: source['highlight'] ?? source['content'] ?? '',
        );
        print('Sefaria Service - Parsed match: $match');
        return match;
      }).toList();
    } catch (e) {
      print('Sefaria Service - Error parsing results: $e');
      return [];
    }
  }
}