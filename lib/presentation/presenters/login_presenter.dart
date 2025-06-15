import '../../data/models/token.dart';
import '../../domain/usecases/login_usecase.dart';

abstract class LoginView {
  void showLoading();
  void hideLoading();
  void showError(String message);
  void navigateToHome(Token token);
}

class LoginPresenter {
  final LoginUseCase loginUseCase;
  final LoginView view;

  LoginPresenter(this.loginUseCase, this.view);

  Future<void> login(String email, String password) async {
    view.showLoading();
    try {
      final token = await loginUseCase.execute(email, password);
      view.hideLoading();
      view.navigateToHome(token);
    } catch (e) {
      view.hideLoading();
      view.showError(e.toString());
    }
  }
}
