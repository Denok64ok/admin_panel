import '../../data/models/parking_place.dart';
import '../../data/repositories/auth_repository.dart';

class GetPlaceUseCase {
  final AuthRepository repository;

  GetPlaceUseCase(this.repository);

  Future<ParkingPlace> execute(int placeId, String token) async {
    return await repository.getPlace(placeId, token);
  }
}
