import '../../data/models/camera.dart';
import '../../data/models/camera_create.dart';
import '../../data/repositories/auth_repository.dart';

class CreateCameraUseCase {
  final AuthRepository repository;

  CreateCameraUseCase(this.repository);

  Future<Camera> execute(CameraCreate data, String token) async {
    return await repository.createCamera(data, token);
  }
}
