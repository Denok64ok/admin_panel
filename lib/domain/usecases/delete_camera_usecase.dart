import '../../data/repositories/auth_repository.dart';

class DeleteCameraUseCase {
  final AuthRepository repository;

  DeleteCameraUseCase(this.repository);

  Future<void> execute(int cameraId, String token) async {
    await repository.deleteCamera(cameraId, token);
  }
}
