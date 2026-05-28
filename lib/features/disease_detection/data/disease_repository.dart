import 'package:image_picker/image_picker.dart';
import 'package:krishi_smart/core/database/app_database.dart';
import 'package:krishi_smart/core/errors/app_exception.dart';
import 'package:krishi_smart/core/security/permission_service.dart';
import 'package:uuid/uuid.dart';

class DiseaseResult {
  const DiseaseResult({
    required this.id,
    required this.diseaseLabel,
    required this.confidence,
    required this.remedy,
    required this.cropId,
  });

  final String id;
  final String diseaseLabel;
  final double confidence;
  final String remedy;
  final String cropId;
}

/// On-device TFLite inference will plug in here; MVP uses deterministic stub.
class DiseaseRepository {
  DiseaseRepository({
    required AppDatabase database,
    required PermissionService permissions,
    ImagePicker? picker,
  })  : _database = database,
        _permissions = permissions,
        _picker = picker ?? ImagePicker();

  final AppDatabase _database;
  final PermissionService _permissions;
  final ImagePicker _picker;

  static const _stubLabels = {
    'rice': ('Leaf Blast (suspected)', 'Apply tricyclazole per extension guidance; avoid excess nitrogen.'),
    'maize': ('Fall Armyworm (suspected)', 'Hand-pick egg masses; use recommended biopesticides early morning.'),
    'wheat': ('Rust (suspected)', 'Remove infected leaves; consider propiconazole if spread > threshold.'),
    'potato': ('Late Blight (suspected)', 'Improve drainage; copper-based protectant before rain.'),
  };

  Future<DiseaseResult> scanFromCamera({String cropId = 'rice'}) async {
    await _permissions.ensureCamera();
    final file = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (file == null) {
      throw const OperationCancelledException('Scan cancelled.');
    }
    return _analyze(cropId: cropId, imagePath: file.path);
  }

  Future<DiseaseResult> scanFromGallery({String cropId = 'rice'}) async {
    await _permissions.requestPhotos();
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (file == null) {
      throw const OperationCancelledException('No image selected.');
    }
    return _analyze(cropId: cropId, imagePath: file.path);
  }

  Future<DiseaseResult> _analyze({
    required String cropId,
    required String imagePath,
  }) async {
    // TODO: Run TFLite model from assets/models/plant_disease.tflite
    final stub = _stubLabels[cropId] ?? _stubLabels['rice']!;
    final id = const Uuid().v4();
    const confidence = 0.78;

    final result = DiseaseResult(
      id: id,
      diseaseLabel: stub.$1,
      confidence: confidence,
      remedy: stub.$2,
      cropId: cropId,
    );

    await _database.insertDiseaseScan({
      'id': id,
      'crop_id': cropId,
      'disease_label': result.diseaseLabel,
      'confidence': result.confidence,
      'remedy': result.remedy,
      'image_path': imagePath,
      'scanned_at': DateTime.now().toIso8601String(),
      'synced': 0,
    });

    await _database.enqueueSync({
      'id': '${id}_sync',
      'entity_type': 'disease_scan',
      'entity_id': id,
      'action': 'create',
      'payload': '{"disease":"${result.diseaseLabel}","confidence":$confidence}',
      'created_at': DateTime.now().toIso8601String(),
      'attempts': 0,
    });

    return result;
  }

  Future<List<Map<String, Object?>>> history() => _database.getDiseaseScans();
}
