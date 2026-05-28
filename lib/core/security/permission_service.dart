import 'package:krishi_smart/core/errors/app_exception.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<bool> requestCamera() => _request(Permission.camera);

  Future<bool> requestPhotos() => _request(Permission.photos);

  Future<bool> requestLocation() => _request(Permission.locationWhenInUse);

  Future<bool> requestMicrophone() => _request(Permission.microphone);

  Future<void> ensureCamera() async {
    if (!await requestCamera()) {
      throw const PermissionDeniedException(
        'Camera access is required for disease detection.',
      );
    }
  }

  Future<void> ensureLocation() async {
    if (!await requestLocation()) {
      throw const PermissionDeniedException(
        'Location access helps provide local weather and alerts.',
      );
    }
  }

  Future<bool> _request(Permission permission) async {
    final status = await permission.status;
    if (status.isGranted) return true;
    if (status.isPermanentlyDenied) return false;
    final result = await permission.request();
    return result.isGranted;
  }
}
