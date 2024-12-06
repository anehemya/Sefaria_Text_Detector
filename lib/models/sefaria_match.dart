class SefariaMatch {
  final String reference;
  final String url;
  final String snippet;

  SefariaMatch({
    required this.reference,
    required this.url,
    required this.snippet,
  });

  @override
  String toString() {
    return 'SefariaMatch(reference: $reference, url: $url, snippet: $snippet)';
  }
} 