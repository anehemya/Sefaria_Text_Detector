import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/sefaria_match.dart';
import '../models/ocr_result.dart';
import '../services/ocr_service.dart';
import '../services/sefaria_service.dart';
import '../services/dicta_service.dart'; 
import 'package:flutter/services.dart';

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
    // If you want to hide the status bar, you can uncomment the following:
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    // Reset to default when leaving the screen
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
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
        appBar: AppBar(
          title: const Text('Search Results'),
          elevation: 0,
          backgroundColor: Theme.of(context).colorScheme.surface,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 64,
                color: Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(height: 16),
              Text(
                'No matches found in Sefaria',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Found in Sefaria'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: matches.length + 1,
        itemBuilder: (context, index) {
          if (index == matches.length) {
            if (isLoading) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            
            if (hasMoreResults) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: OutlinedButton.icon(
                    onPressed: _loadMoreResults,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Load More Results'),
                  ),
                ),
              );
            }

            return const SizedBox.shrink();
          }

          final match = matches[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _launchURL(Uri.parse(match.url)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            match.reference,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.open_in_new),
                          onPressed: () => _launchURL(Uri.parse(match.url)),
                          tooltip: 'Open in Sefaria',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      match.snippet,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
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