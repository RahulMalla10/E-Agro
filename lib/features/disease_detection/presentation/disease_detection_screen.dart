import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi_smart/core/providers/app_providers.dart';
import 'package:krishi_smart/features/disease_detection/data/disease_repository.dart';

class DiseaseDetectionScreen extends ConsumerStatefulWidget {
  const DiseaseDetectionScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  ConsumerState<DiseaseDetectionScreen> createState() =>
      _DiseaseDetectionScreenState();
}

class _DiseaseDetectionScreenState extends ConsumerState<DiseaseDetectionScreen> {
  String _cropId = 'rice';
  DiseaseResult? _lastResult;
  bool _loading = false;
  String? _error;

  Future<void> _scan({required bool fromCamera}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = ref.read(diseaseRepositoryProvider);
      final result = fromCamera
          ? await repo.scanFromCamera(cropId: _cropId)
          : await repo.scanFromGallery(cropId: _cropId);
      setState(() => _lastResult = result);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              value: _cropId,
              decoration: const InputDecoration(labelText: 'Crop'),
              items: const [
                DropdownMenuItem(value: 'rice', child: Text('Rice')),
                DropdownMenuItem(value: 'maize', child: Text('Maize')),
                DropdownMenuItem(value: 'wheat', child: Text('Wheat')),
                DropdownMenuItem(value: 'potato', child: Text('Potato')),
              ],
              onChanged: _loading ? null : (v) => setState(() => _cropId = v!),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _loading ? null : () => _scan(fromCamera: true),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Take photo'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _loading ? null : () => _scan(fromCamera: false),
              icon: const Icon(Icons.photo_library),
              label: const Text('Choose from gallery'),
            ),
            if (_loading) const LinearProgressIndicator(),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ),
            const SizedBox(height: 16),
            if (_lastResult != null) _ResultCard(result: _lastResult!),
            const SizedBox(height: 8),
            const Expanded(child: _ScanHistory()),
          ],
        ),
      );

    if (widget.embedded) return content;
    return Scaffold(appBar: AppBar(title: const Text('Disease Detection')), body: content);
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result});

  final DiseaseResult result;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(result.diseaseLabel, style: Theme.of(context).textTheme.titleLarge),
            Text('Confidence: ${(result.confidence * 100).toStringAsFixed(0)}%'),
            const SizedBox(height: 8),
            Text(result.remedy),
            const SizedBox(height: 8),
            Text(
              'On-device AI model pending — results are advisory only.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _ScanHistory extends ConsumerWidget {
  const _ScanHistory();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: ref.read(diseaseRepositoryProvider).history(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = snapshot.data!;
        if (items.isEmpty) {
          return const Center(child: Text('No scans yet'));
        }
        return ListView(
          children: items
              .map(
                (row) => ListTile(
                  leading: const Icon(Icons.history),
                  title: Text(row['disease_label'] as String? ?? ''),
                  subtitle: Text(row['scanned_at'] as String? ?? ''),
                ),
              )
              .toList(),
        );
      },
    );
  }
}
