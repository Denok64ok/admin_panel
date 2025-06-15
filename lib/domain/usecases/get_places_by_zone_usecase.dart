import '../../data/models/parking_place.dart';
import '../../data/repositories/auth_repository.dart';

class GetPlacesByZoneUseCase {
  final AuthRepository repository;

  GetPlacesByZoneUseCase(this.repository);

  Future<List<ParkingPlace>> execute(int zoneId, String token) async {
    return await repository.getPlacesByZone(zoneId, token);
  }
}
