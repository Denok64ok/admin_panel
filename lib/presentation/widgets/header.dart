import 'package:flutter/material.dart';
import '../../data/models/admin.dart';
import '../../di/injection.dart';
import '../../domain/usecases/get_admin_profile_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

class Header extends StatefulWidget implements PreferredSizeWidget {
  const Header({super.key});

  @override
  _HeaderState createState() => _HeaderState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _HeaderState extends State<Header> {
  final _storage = const FlutterSecureStorage();
  Admin? _admin;
  bool _isLoading = false;

  static const primaryColor = Color(0xFF447BBA);

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _fetchAdminProfile() async {
    setState(() => _isLoading = true);
    try {
      final token = await _storage.read(key: 'access_token');
      if (token == null) {
        _showErrorSnackBar('Ошибка авторизации. Пожалуйста, войдите снова.');
        if (mounted) {
          context.go('/');
        }
        return;
      }

      final useCase = getIt<GetAdminProfileUseCase>();
      final admin = await useCase.execute(token);
      setState(() {
        _admin = admin;
      });
    } catch (e) {
      _showErrorSnackBar('Не удалось загрузить профиль администратора');
      context.go('/');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    setState(() => _isLoading = true);
    try {
      final token = await _storage.read(key: 'access_token');
      if (token == null) {
        _showErrorSnackBar('Ошибка авторизации. Пожалуйста, войдите снова.');
        if (mounted) {
          context.go('/');
        }
        return;
      }

      final useCase = getIt<LogoutUseCase>();
      await useCase.execute(token);
      await _storage.delete(key: 'access_token');

      if (mounted) {
        _showSuccessSnackBar('Вы успешно вышли из системы');
        context.go('/');
      }
    } catch (e) {
      _showErrorSnackBar('Не удалось выйти из системы');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showProfileDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 8,
            backgroundColor: Colors.white,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Профиль пользователя',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: primaryColor),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  iconSize: 24,
                  splashRadius: 20,
                ),
              ],
            ),
            content: Container(
              width: 320,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child:
                  _isLoading
                      ? const Center(
                        child: CircularProgressIndicator(color: primaryColor),
                      )
                      : Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.person, color: primaryColor),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Имя: ${_admin?.adminName}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Icon(Icons.email, color: primaryColor),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Почта: ${_admin?.email}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
            ),
            actions: [
              Center(
                child: SizedBox(
                  width: 220,
                  height: 45,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ),
                    onPressed: _isLoading ? null : _logout,
                    icon: const Icon(Icons.logout),
                    label:
                        _isLoading
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : const Text(
                              'Выйти из аккаунта',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchAdminProfile();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 0,
      title: Row(
        children: [
          GestureDetector(
            onTap: () => context.go('/home'),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'favicon.png',
                  height: 40,
                  width: 40,
                  errorBuilder:
                      (_, __, ___) => Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.local_parking,
                          color: Colors.white,
                        ),
                      ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'Онлайн парковки',
            style: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child:
              _isLoading
                  ? const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: primaryColor,
                        strokeWidth: 2,
                      ),
                    ),
                  )
                  : IconButton(
                    icon: const Icon(
                      Icons.person_outline,
                      color: primaryColor,
                      size: 28,
                    ),
                    onPressed: _showProfileDialog,
                    tooltip: 'Профиль',
                    splashRadius: 24,
                  ),
        ),
      ],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(3),
        child: Divider(height: 3, thickness: 3, color: primaryColor),
      ),
    );
  }
}
