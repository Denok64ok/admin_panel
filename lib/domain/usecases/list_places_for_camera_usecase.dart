import '../../data/models/camera_parking_place.dart';
import '../../data/repositories/auth_repository.dart';

class ListPlacesForCameraUseCase {
  final AuthRepository repository;

  ListPlacesForCameraUseCase(this.repository);

  Future<List<CameraParkingPlace>> execute(int cameraId, String token) async {
    return await repository.listPlacesForCamera(cameraId, token);
  }
}
