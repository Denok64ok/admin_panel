import '../../data/models/camera_parking_place.dart';
import '../../data/models/camera_parking_place_create.dart';
import '../../data/repositories/auth_repository.dart';

class CreateCameraParkingPlaceUseCase {
  final AuthRepository repository;

  CreateCameraParkingPlaceUseCase(this.repository);

  Future<CameraParkingPlace> execute(
    CameraParkingPlaceCreate data,
    String token,
  ) async {
    return await repository.createCameraParkingPlace(data, token);
  }
}
