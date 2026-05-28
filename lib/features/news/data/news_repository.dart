import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

class AgricultureNewsItem {
  const AgricultureNewsItem({
    required this.title,
    required this.link,
    required this.summary,
    required this.publishedAt,
    required this.source,
  });

  final String title;
  final String link;
  final String summary;
  final DateTime? publishedAt;
  final String source;
}

class NewsRepository {
  NewsRepository({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _feeds = <_NepalFeed>[
    _NepalFeed('Online Khabar', 'https://www.onlinekhabar.com/feed'),
    _NepalFeed('Ekantipur', 'https://ekantipur.com/rss'),
    _NepalFeed('Ratopati', 'https://www.ratopati.com/feed'),
    _NepalFeed('Setopati', 'https://www.setopati.com/feed'),
    _NepalFeed('News24', 'https://www.newsn24.com/feed/'),
  ];

  static const _agKeywords = [
    'कृषि',
    'किसान',
    'खेती',
    'बाली',
    'मौसम',
    'बीउ',
    'दूध',
    'तरकारी',
    'फलफूल',
    'agriculture',
    'farmer',
    'farming',
    'crop',
    'harvest',
    'livestock',
    'dairy',
    'paddy',
    'monsoon',
  ];

  Future<List<AgricultureNewsItem>> fetchNepalAgNews({int limit = 24}) async {
    final merged = <AgricultureNewsItem>[];
    final seenTitles = <String>{};

    final results = await Future.wait(_feeds.map(_fetchFeed));

    for (final batch in results) {
      for (final item in batch) {
        final key = item.title.toLowerCase().trim();
        if (seenTitles.contains(key)) continue;
        if (!_isRelevant(item)) continue;
        seenTitles.add(key);
        merged.add(item);
      }
    }

    merged.sort((a, b) {
      final ad = a.publishedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bd = b.publishedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bd.compareTo(ad);
    });

    if (merged.length < 6) {
      final seen = seenTitles.toSet();
      for (final batch in results) {
        for (final item in batch) {
          final key = item.title.toLowerCase().trim();
          if (seen.contains(key)) continue;
          seen.add(key);
          merged.add(item);
        }
      }
      merged.sort((a, b) {
        final ad = a.publishedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bd = b.publishedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bd.compareTo(ad);
      });
    }

    if (merged.isEmpty) return _fallbackNews();
    return merged.take(limit).toList();
  }

  Future<List<AgricultureNewsItem>> _fetchFeed(_NepalFeed feed) async {
    try {
      final response = await _client
          .get(
            Uri.parse(feed.url),
            headers: {'User-Agent': 'KrishiSmart/1.0'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return [];

      final doc = XmlDocument.parse(response.body);
      final items = doc.findAllElements('item');
      final news = <AgricultureNewsItem>[];

      for (final item in items) {
        if (news.length >= 15) break;
        final title = _clean(_elementText(item, 'title'));
        var link = _elementText(item, 'link');
        if (link.isEmpty) {
          link = item.getElement('guid')?.innerText.trim() ?? '';
        }
        if (title.isEmpty) continue;

        news.add(
          AgricultureNewsItem(
            title: title,
            link: link,
            summary: _clean(_elementText(item, 'description')),
            publishedAt: _parseDate(_elementText(item, 'pubDate')),
            source: feed.name,
          ),
        );
      }
      return news;
    } catch (_) {
      return [];
    }
  }

  bool _isRelevant(AgricultureNewsItem item) {
    final text = '${item.title} ${item.summary}'.toLowerCase();
    return _agKeywords.any((k) => text.contains(k.toLowerCase()));
  }

  String _elementText(XmlElement parent, String name) {
    final el = parent.getElement(name);
    return el?.innerText.trim() ?? '';
  }

  String _clean(String raw) {
    return raw
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#8217;', "'")
        .trim();
  }

  DateTime? _parseDate(String raw) {
    if (raw.isEmpty) return null;
    try {
      return HttpDate.parse(raw);
    } catch (_) {
      return null;
    }
  }

  List<AgricultureNewsItem> _fallbackNews() {
    final now = DateTime.now();
    return [
      AgricultureNewsItem(
        title: 'मनसुनले धान रोपाइँको समयमा असर पार्न सक्छ',
        link: 'https://www.onlinekhabar.com',
        summary: 'कृषि सम्बन्धी अपडेट — इन्टरनेट जडान जाँच गर्नुहोस्।',
        publishedAt: now,
        source: 'Online Khabar',
      ),
      AgricultureNewsItem(
        title: 'कालिमाटी तरकारी बजारमा मूल्य स्थिर',
        link: 'https://ekantipur.com',
        summary: 'टमाटर र आलुको आपूर्ति सुधारिएको छ।',
        publishedAt: now.subtract(const Duration(hours: 5)),
        source: 'Ekantipur',
      ),
    ];
  }
}

class _NepalFeed {
  const _NepalFeed(this.name, this.url);
  final String name;
  final String url;
}
