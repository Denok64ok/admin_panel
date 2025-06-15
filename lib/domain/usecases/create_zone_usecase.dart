import '../../data/models/parking_zone.dart';
import '../../data/models/parking_zone_create.dart';
import '../../data/repositories/auth_repository.dart';

class CreateZoneUseCase {
  final AuthRepository repository;

  CreateZoneUseCase(this.repository);

  Future<ParkingZone> execute(ParkingZoneCreate data, String token) async {
    return await repository.createZone(data, token);
  }
}
