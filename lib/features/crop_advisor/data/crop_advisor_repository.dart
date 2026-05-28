import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:krishi_smart/features/home/data/product_models.dart';

class AdvisorGuide {
  const AdvisorGuide({
    required this.id,
    required this.category,
    required this.nameEn,
    required this.nameNe,
    required this.summary,
    required this.stages,
    required this.guides,
  });

  final String id;
  final ProductCategory category;
  final String nameEn;
  final String nameNe;
  final String summary;
  final List<String> stages;
  final List<AdvisorStageGuide> guides;
}

class AdvisorStageGuide {
  const AdvisorStageGuide({
    required this.stage,
    required this.title,
    required this.body,
  });

  final String stage;
  final String title;
  final String body;
}

class CropAdvisorRepository {
  Future<List<AdvisorGuide>> getGuides({ProductCategory? category}) async {
    final raw = await rootBundle.loadString('assets/data/advisor_guides.json');
    final list = jsonDecode(raw) as List;
    final guides = list.map((e) {
      final json = e as Map<String, dynamic>;
      final guideList = (json['guides'] as List).map((g) {
        final m = g as Map<String, dynamic>;
        return AdvisorStageGuide(
          stage: m['stage'] as String,
          title: m['title'] as String,
          body: m['body'] as String,
        );
      }).toList();

      return AdvisorGuide(
        id: json['id'] as String,
        category: ProductCategory.fromString(json['category'] as String),
        nameEn: json['name_en'] as String,
        nameNe: json['name_ne'] as String,
        summary: json['summary'] as String,
        stages: (json['stages'] as List).cast<String>(),
        guides: guideList,
      );
    }).toList();

    if (category == null) return guides;
    return guides.where((g) => g.category == category).toList();
  }
}
