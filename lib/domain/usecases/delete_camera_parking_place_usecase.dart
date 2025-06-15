import '../../data/repositories/auth_repository.dart';

class DeleteCameraParkingPlaceUseCase {
  final AuthRepository repository;

  DeleteCameraParkingPlaceUseCase(this.repository);

  Future<void> execute(int id, String token) async {
    await repository.deleteCameraParkingPlace(id, token);
  }
}
