import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi_smart/core/l10n/locale_provider.dart';
import 'package:krishi_smart/core/providers/app_providers.dart';
import 'package:krishi_smart/features/crop_advisor/data/crop_advisor_repository.dart';
import 'package:krishi_smart/features/home/data/product_models.dart';

final _advisorGuidesProvider = FutureProvider<List<AdvisorGuide>>((ref) {
  return ref.watch(cropAdvisorRepositoryProvider).getGuides();
});

class CropAdvisorScreen extends ConsumerStatefulWidget {
  const CropAdvisorScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  ConsumerState<CropAdvisorScreen> createState() => _CropAdvisorScreenState();
}

class _CropAdvisorScreenState extends ConsumerState<CropAdvisorScreen> {
  ProductCategory? _filter;

  @override
  Widget build(BuildContext context) {
    final guidesAsync = ref.watch(_advisorGuidesProvider);
    final s = ref.watch(stringsProvider);

    final body = guidesAsync.when(
        loading: () => Center(child: Text(s.loading)),
        error: (e, _) => Center(child: Text('${s.error}: $e')),
        data: (guides) {
          final filtered = _filter == null
              ? guides
              : guides.where((g) => g.category == _filter).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Text(s.advisorSubtitle, style: Theme.of(context).textTheme.bodyLarge),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    FilterChip(
                      label: Text(s.all),
                      selected: _filter == null,
                      onSelected: (_) => setState(() => _filter = null),
                    ),
                    const SizedBox(width: 8),
                    ...ProductCategory.values.map(
                      (cat) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(s.categoryLabel(cat.dbValue)),
                          selected: _filter == cat,
                          onSelected: (_) => setState(() => _filter = cat),
                          avatar: Icon(cat.icon, size: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final guide = filtered[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: guide.category.color.withValues(alpha: 0.15),
                          child: Icon(guide.category.icon, color: guide.category.color),
                        ),
                        title: Text(guide.nameEn),
                        subtitle: Text(
                          '${guide.nameNe}\n${guide.summary}',
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        isThreeLine: true,
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _openGuide(context, guide),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      );

    if (widget.embedded) return body;
    return Scaffold(appBar: AppBar(title: Text(s.advisorTitle)), body: body);
  }

  void _openGuide(BuildContext context, AdvisorGuide guide) {
    final s = ref.read(stringsProvider);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.65,
        maxChildSize: 0.92,
        minChildSize: 0.4,
        builder: (_, controller) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: ListView(
            controller: controller,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(guide.nameEn, style: Theme.of(context).textTheme.headlineSmall),
              Text(guide.nameNe, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Chip(
                avatar: Icon(guide.category.icon, size: 16),
                label: Text(s.categoryLabel(guide.category.dbValue)),
              ),
              const SizedBox(height: 12),
              Text(guide.summary, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 20),
              Text(s.stepByStep, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              ...guide.guides.map(
                (step) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      child: Text(
                        step.stage.substring(0, 1).toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(step.title),
                    subtitle: Text(step.stage, style: Theme.of(context).textTheme.labelMedium),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Text(step.body, style: Theme.of(context).textTheme.bodyLarge),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
