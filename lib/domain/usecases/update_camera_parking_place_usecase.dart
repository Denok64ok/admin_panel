import '../../data/models/camera_parking_place.dart';
import '../../data/models/camera_parking_place_create.dart';
import '../../data/repositories/auth_repository.dart';

class UpdateCameraParkingPlaceUseCase {
  final AuthRepository repository;

  UpdateCameraParkingPlaceUseCase(this.repository);

  Future<CameraParkingPlace> execute(
    int id,
    CameraParkingPlaceCreate data,
    String token,
  ) async {
    return await repository.updateCameraParkingPlace(id, data, token);
  }
}
