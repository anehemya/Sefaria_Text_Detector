import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/sefaria_match.dart';
import '../models/ocr_result.dart';
import '../services/ocr_service.dart';
import '../services/sefaria_service.dart';
import '../services/dicta_service.dart'; 

class DisplayResultsScreen extends StatefulWidget {
  final OCRResult result;

  const DisplayResultsScreen({Key? key, required this.result}) : super(key: key);

  @override
  _DisplayResultsScreenState createState() => _DisplayResultsScreenState();
}

class _DisplayResultsScreenState extends State<DisplayResultsScreen> {
  final _dictaService = DictaService();
  late final _sefariaService = SefariaService(_dictaService);  // Update this
  List<SefariaMatch> matches = [];
  bool isLoading = false;
  int currentPage = 0;
  bool hasMoreResults = true;

  @override
  void initState() {
    super.initState();
    matches = widget.result.matches ?? [];
  }

  Future<void> _loadMoreResults() async {
    if (isLoading || !hasMoreResults) return;

    setState(() {
      isLoading = true;
    });

    try {
      final nextPage = currentPage + 1;
      final moreResults = await _sefariaService.searchText(
        widget.result.text,
        from: nextPage * SefariaService.pageSize,
      );

      final newMatches = _parseSefariaResults(moreResults);
      
      setState(() {
        matches.addAll(newMatches);
        currentPage = nextPage;
        hasMoreResults = newMatches.isNotEmpty;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading more results: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  List<SefariaMatch> _parseSefariaResults(Map<String, dynamic> searchResult) {
    try {
      final hits = searchResult['hits']['hits'] as List;
      return hits.map((hit) {
        final source = hit['_source'];
        return SefariaMatch(
          reference: source['ref'] ?? '',
          url: _sefariaService.generateSefariaLink(source['ref'] ?? ''),
          snippet: source['highlight'] ?? source['content'] ?? '',
        );
      }).toList();
    } catch (e) {
      print('Error parsing Sefaria results: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (matches.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Search Results')),
        body: const Center(
          child: Text('No matches found in Sefaria'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Found in Sefaria')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: matches.length + 1, // +1 for the loading indicator
        itemBuilder: (context, index) {
          if (index == matches.length) {
            if (isLoading) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            
            if (hasMoreResults) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: _loadMoreResults,
                    child: const Text('Load More Results'),
                  ),
                ),
              );
            }

            return const SizedBox.shrink(); // Hide if no more results
          }

          final match = matches[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(match.reference),
              subtitle: Text(match.snippet),
              onTap: () => _launchURL(Uri.parse(match.url)),
            ),
          );
        },
      ),
    );
  }

  Future<void> _launchURL(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }
}