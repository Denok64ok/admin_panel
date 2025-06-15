import '../../data/repositories/auth_repository.dart';

class DeleteZoneUseCase {
  final AuthRepository repository;

  DeleteZoneUseCase(this.repository);

  Future<void> execute(int zoneId, String token) async {
    await repository.deleteZone(zoneId, token);
  }
}
