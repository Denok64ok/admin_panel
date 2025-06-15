import '../../data/models/parking_zone.dart';
import '../../data/repositories/auth_repository.dart';

class GetZonesUseCase {
  final AuthRepository repository;

  GetZonesUseCase(this.repository);

  Future<List<ParkingZone>> execute(int adminId, String token) async {
    return await repository.getZonesByAdmin(adminId, token);
  }
}
