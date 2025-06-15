import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SearchWidget extends StatefulWidget {
  final MapController mapController;

  const SearchWidget({super.key, required this.mapController});

  @override
  _SearchWidgetState createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  final _searchController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : const Color(0xFF447BBA),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) {
      _showSnackBar('Пожалуйста, введите адрес для поиска', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse(
          'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=1',
        ),
        headers: {'User-Agent': 'FlutterAdminPanel/1.0'},
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          final lat = double.parse(data[0]['lat']);
          final lon = double.parse(data[0]['lon']);
          widget.mapController.move(LatLng(lat, lon), 15.0);
          _showSnackBar('Местоположение найдено');
        } else {
          _showSnackBar('Местоположение не найдено', isError: true);
        }
      } else {
        _showSnackBar(
          'Не удалось выполнить поиск. Попробуйте позже',
          isError: true,
        );
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(
          'Произошла ошибка при поиске. Проверьте подключение к интернету',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Positioned(
      width: screenWidth * 0.25,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Введите адрес для поиска',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: InputBorder.none,
                  errorText: _errorMessage,
                  prefixIcon: Icon(
                    Icons.location_on_outlined,
                    color: const Color(0xFF447BBA),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                style: const TextStyle(fontSize: 14),
                onSubmitted: _searchLocation,
              ),
            ),
            const SizedBox(width: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child:
                  _isLoading
                      ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            const Color(0xFF447BBA),
                          ),
                        ),
                      )
                      : IconButton(
                        icon: const Icon(
                          Icons.search,
                          color: Color(0xFF447BBA),
                        ),
                        onPressed:
                            () => _searchLocation(_searchController.text),
                        splashRadius: 24,
                        tooltip: 'Поиск',
                      ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
