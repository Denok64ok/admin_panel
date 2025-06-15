import '../../data/models/parking_zone_detailed.dart';
import '../../data/repositories/auth_repository.dart';

class GetZoneDetailedUseCase {
  final AuthRepository repository;

  GetZoneDetailedUseCase(this.repository);

  Future<ParkingZoneDetailed> execute(int zoneId, String token) async {
    return await repository.getZoneDetailed(zoneId, token);
  }
}
