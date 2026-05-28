import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:krishi_smart/core/l10n/locale_provider.dart';
import 'package:krishi_smart/core/providers/app_providers.dart';
import 'package:krishi_smart/features/news/data/news_repository.dart';
import 'package:url_launcher/url_launcher.dart';

final _newsListProvider = FutureProvider<List<AgricultureNewsItem>>((ref) {
  return ref.watch(newsRepositoryProvider).fetchNepalAgNews(limit: 30);
});

class NewsScreen extends ConsumerWidget {
  const NewsScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final news = ref.watch(_newsListProvider);
    final s = ref.watch(stringsProvider);
    final theme = Theme.of(context);

    final body = news.when(
        loading: () => Center(child: Text(s.loadingNews)),
        error: (e, _) => Center(child: Text('${s.error}: $e')),
        data: (items) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(_newsListProvider),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = items[index];
              final date = item.publishedAt != null
                  ? DateFormat('d MMM yyyy').format(item.publishedAt!)
                  : '';

              return Card(
                child: InkWell(
                  onTap: () => _openArticle(context, item.link, s.couldNotOpen),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Chip(
                              label: Text(
                                item.source,
                                style: theme.textTheme.labelSmall,
                              ),
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                            ),
                            const Spacer(),
                            if (date.isNotEmpty)
                              Text(date, style: theme.textTheme.bodySmall),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(item.title, style: theme.textTheme.titleMedium),
                        if (item.summary.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            item.summary,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          s.readMore,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );

    if (embedded) return body;
    return Scaffold(appBar: AppBar(title: Text(s.newsTitle)), body: body);
  }

  Future<void> _openArticle(
    BuildContext context,
    String link,
    String errorMsg,
  ) async {
    final uri = Uri.tryParse(link);
    if (uri == null) return;
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMsg)));
      }
    }
  }
}
