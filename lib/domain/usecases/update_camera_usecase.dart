import '../../data/models/camera.dart';
import '../../data/models/camera_create.dart';
import '../../data/repositories/auth_repository.dart';

class UpdateCameraUseCase {
  final AuthRepository repository;

  UpdateCameraUseCase(this.repository);

  Future<Camera> execute(int cameraId, CameraCreate data, String token) async {
    return await repository.updateCamera(cameraId, data, token);
  }
}
