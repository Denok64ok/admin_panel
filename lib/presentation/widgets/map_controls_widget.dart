import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class MapControlsWidget extends StatefulWidget {
  final MapController mapController;

  const MapControlsWidget({super.key, required this.mapController});

  @override
  _MapControlsWidgetState createState() => _MapControlsWidgetState();
}

class _MapControlsWidgetState extends State<MapControlsWidget> {
  double _currentZoom = 13.0;
  static const double _minZoom = 8.0;
  static const double _maxZoom = 18.0;
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

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showErrorSnackBar(
          'Сервисы геолокации отключены. Пожалуйста, включите GPS.',
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showErrorSnackBar(
            'Для определения местоположения необходимо разрешение',
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showErrorSnackBar(
          'Разрешение на геолокацию отклонено навсегда. Пожалуйста, предоставьте разрешение в настройках устройства.',
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      widget.mapController.move(
        LatLng(position.latitude, position.longitude),
        _maxZoom,
      );

      _showSuccessSnackBar('Местоположение успешно определено');
    } catch (e) {
      _showErrorSnackBar('Не удалось определить местоположение');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _zoomIn() {
    setState(() {
      _currentZoom = (_currentZoom + 1).clamp(_minZoom, _maxZoom);
      widget.mapController.move(
        widget.mapController.camera.center,
        _currentZoom,
      );
    });
  }

  void _zoomOut() {
    setState(() {
      _currentZoom = (_currentZoom - 1).clamp(_minZoom, _maxZoom);
      widget.mapController.move(
        widget.mapController.camera.center,
        _currentZoom,
      );
    });
  }

  Widget _buildControlButton({
    required IconData icon,
    required Function() onPressed,
    bool isLoading = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              border: Border.all(color: primaryColor, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            child:
                isLoading
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
                    : Icon(icon, color: primaryColor, size: 24),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).size.height / 2 - 100,
      right: 16,
      child: Column(
        children: [
          _buildControlButton(icon: Icons.add, onPressed: _zoomIn),
          const SizedBox(height: 12),
          _buildControlButton(icon: Icons.remove, onPressed: _zoomOut),
          const SizedBox(height: 12),
          _buildControlButton(
            icon: Icons.my_location,
            onPressed: () => _isLoading ? null : _getCurrentLocation(),
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }
}
