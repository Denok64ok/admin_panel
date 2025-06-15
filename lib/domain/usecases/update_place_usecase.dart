import '../../data/models/parking_place.dart';
import '../../data/models/parking_place_create.dart';
import '../../data/repositories/auth_repository.dart';

class UpdatePlaceUseCase {
  final AuthRepository repository;

  UpdatePlaceUseCase(this.repository);

  Future<ParkingPlace> execute(
    int placeId,
    ParkingPlaceCreate data,
    String token,
  ) async {
    return await repository.updatePlace(placeId, data, token);
  }
}
