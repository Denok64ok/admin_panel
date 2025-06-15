import '../../data/models/camera.dart';
import '../../data/repositories/auth_repository.dart';

class GetCamerasByZoneUseCase {
  final AuthRepository repository;

  GetCamerasByZoneUseCase(this.repository);

  Future<List<Camera>> execute(int zoneId, String token) async {
    return await repository.getCamerasByZone(zoneId, token);
  }
}
