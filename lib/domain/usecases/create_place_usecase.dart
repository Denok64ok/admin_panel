import '../../data/models/parking_place.dart';
import '../../data/models/parking_place_create.dart';
import '../../data/repositories/auth_repository.dart';

class CreatePlaceUseCase {
  final AuthRepository repository;

  CreatePlaceUseCase(this.repository);

  Future<ParkingPlace> execute(ParkingPlaceCreate data, String token) async {
    return await repository.createPlace(data, token);
  }
}
