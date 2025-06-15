import '../../data/repositories/auth_repository.dart';

class DeletePlaceUseCase {
  final AuthRepository repository;

  DeletePlaceUseCase(this.repository);

  Future<void> execute(int placeId, String token) async {
    await repository.deletePlace(placeId, token);
  }
}
