import '../../data/models/camera.dart';
import '../../data/repositories/auth_repository.dart';

class GetCameraUseCase {
  final AuthRepository repository;

  GetCameraUseCase(this.repository);

  Future<Camera> execute(int cameraId, String token) async {
    return await repository.getCamera(cameraId, token);
  }
}
