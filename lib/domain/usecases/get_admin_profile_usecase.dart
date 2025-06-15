import '../../data/models/admin.dart';
import '../../data/repositories/auth_repository.dart';

class GetAdminProfileUseCase {
  final AuthRepository repository;

  GetAdminProfileUseCase(this.repository);

  Future<Admin> execute(String token) async {
    return await repository.getAdminProfile(token);
  }
}
