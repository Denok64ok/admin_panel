import 'package:admin_panel/presentation/widgets/header.dart';
import 'package:admin_panel/presentation/widgets/map_controls_widget.dart';
import 'package:admin_panel/presentation/widgets/search_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../data/models/zone_type.dart';
import '../../data/models/parking_zone_create.dart';
import '../../data/models/admin.dart';
import '../../di/injection.dart';
import '../../domain/usecases/get_zone_types_usecase.dart';
import '../../domain/usecases/get_admin_profile_usecase.dart';
import '../../domain/usecases/create_zone_usecase.dart';
import 'package:go_router/go_router.dart';
import 'dart:developer' as developer;

class AddZonePage extends StatefulWidget {
  const AddZonePage({super.key});

  @override
  _AddZonePageState createState() => _AddZonePageState();
}

class _AddZonePageState extends State<AddZonePage> {
  final MapController _mapController = MapController();
  final _storage = const FlutterSecureStorage();
  final _zoneNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _priceController = TextEditingController();
  List<LatLng> _points = [];
  List<ZoneType> _zoneTypes = [];
  ZoneType? _selectedZoneType;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  Admin? _admin;
  bool _isLoading = false;

  static const primaryColor = Color(0xFF447BBA);

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    await Future.wait([_loadZoneTypes(), _loadAdminProfile()]);
    setState(() => _isLoading = false);
  }

  Future<void> _loadZoneTypes() async {
    try {
      final token = await _storage.read(key: 'access_token');
      if (token == null) {
        _showErrorSnackBar('Ошибка авторизации. Пожалуйста, войдите снова.');
        return;
      }
      final zoneTypes = await getIt<GetZoneTypesUseCase>().execute(token);
      setState(() {
        _zoneTypes = zoneTypes;
        _selectedZoneType = zoneTypes.isNotEmpty ? zoneTypes.first : null;
      });
    } catch (e) {
      _showErrorSnackBar('Не удалось загрузить типы зон');
    }
  }

  Future<void> _loadAdminProfile() async {
    try {
      final token = await _storage.read(key: 'access_token');
      if (token == null) {
        _showErrorSnackBar('Ошибка авторизации. Пожалуйста, войдите снова.');
        return;
      }
      final admin = await getIt<GetAdminProfileUseCase>().execute(token);
      setState(() {
        _admin = admin;
      });
    } catch (e) {
      _showErrorSnackBar('Не удалось загрузить профиль администратора');
    }
  }

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

  String _formatTime(TimeOfDay time) {
    final hours = time.hour.toString().padLeft(2, '0');
    final minutes = time.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  bool _validateForm() {
    if (_zoneNameController.text.trim().isEmpty) {
      _showErrorSnackBar('Пожалуйста, введите название зоны');
      return false;
    }
    if (_addressController.text.trim().isEmpty) {
      _showErrorSnackBar('Пожалуйста, введите адрес');
      return false;
    }
    if (_selectedZoneType == null) {
      _showErrorSnackBar('Пожалуйста, выберите тип зоны');
      return false;
    }
    if (_startTime == null || _endTime == null) {
      _showErrorSnackBar('Пожалуйста, укажите время работы');
      return false;
    }
    if (_priceController.text.trim().isEmpty) {
      _showErrorSnackBar('Пожалуйста, укажите цену за минуту');
      return false;
    }
    if (_points.length < 3) {
      _showErrorSnackBar('Пожалуйста, выберите минимум 3 точки на карте');
      return false;
    }
    return true;
  }

  Future<void> _saveZone() async {
    if (!_validateForm()) return;

    setState(() => _isLoading = true);
    try {
      final token = await _storage.read(key: 'access_token');
      if (token == null) {
        _showErrorSnackBar('Ошибка авторизации. Пожалуйста, войдите снова.');
        return;
      }

      int pricePerMinute = int.parse(_priceController.text.trim());

      final zoneData = ParkingZoneCreate(
        adminId: _admin!.id,
        zoneName: _zoneNameController.text.trim(),
        zoneTypeId: _selectedZoneType!.id,
        address: _addressController.text.trim(),
        startTime: _formatTime(_startTime!),
        endTime: _formatTime(_endTime!),
        pricePerMinute: pricePerMinute,
        location: _points.map((p) => [p.latitude, p.longitude]).toList(),
      );

      developer.log('Тело запроса: ${zoneData.toJson()}');

      final createdZone = await getIt<CreateZoneUseCase>().execute(
        zoneData,
        token,
      );

      if (mounted) {
        _showSuccessSnackBar('Зона успешно создана');
        context.go('/manage-zone-details/${createdZone.id}');
      }
    } catch (e) {
      _showErrorSnackBar(
        'Не удалось создать зону. Пожалуйста, проверьте введенные данные.',
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _resetCoordinates() {
    setState(() {
      _points = [];
    });
    _showSuccessSnackBar('Координаты сброшены');
  }

  InputDecoration _getInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      labelStyle: const TextStyle(fontSize: 16, color: primaryColor),
      prefixIcon: Icon(icon, color: primaryColor),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Header(),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(55.441004, 65.341118),
              initialZoom: 18.0,
              minZoom: 8.0,
              maxZoom: 18.0,
              onTap: (tapPosition, point) {
                setState(() {
                  _points.add(point);
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
                userAgentPackageName: 'com.example.admin_panel',
              ),
              if (_points.isNotEmpty)
                PolygonLayer(
                  polygons: [
                    Polygon(
                      points: _points,
                      color: primaryColor.withOpacity(0.3),
                      borderColor: primaryColor,
                      borderStrokeWidth: 2.0,
                      isFilled: true,
                    ),
                  ],
                ),
            ],
          ),
          SearchWidget(mapController: _mapController),
          MapControlsWidget(mapController: _mapController),
          Positioned(
            top: 64,
            left: 0,
            width: MediaQuery.of(context).size.width * 0.25,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child:
                  _isLoading
                      ? const Center(
                        child: CircularProgressIndicator(color: primaryColor),
                      )
                      : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Align(
                            alignment: Alignment.center,
                            child: Text(
                              'Добавление зоны',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 25),
                          TextField(
                            controller: _zoneNameController,
                            style: const TextStyle(fontSize: 16),
                            decoration: _getInputDecoration(
                              'Название зоны',
                              Icons.edit,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _addressController,
                            style: const TextStyle(fontSize: 16),
                            decoration: _getInputDecoration(
                              'Адрес',
                              Icons.location_on,
                            ),
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<ZoneType>(
                            value: _selectedZoneType,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                            decoration: _getInputDecoration(
                              'Тип зоны',
                              Icons.category,
                            ),
                            items:
                                _zoneTypes.map((zoneType) {
                                  return DropdownMenuItem<ZoneType>(
                                    value: zoneType,
                                    child: Text(zoneType.typeName),
                                  );
                                }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedZoneType = value;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: primaryColor),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  color: primaryColor,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextButton(
                                          onPressed: () async {
                                            final time = await showTimePicker(
                                              context: context,
                                              initialTime: TimeOfDay.now(),
                                            );
                                            if (time != null) {
                                              setState(() {
                                                _startTime = time;
                                              });
                                            }
                                          },
                                          style: TextButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                          ),
                                          child: Text(
                                            _startTime == null
                                                ? 'Начало'
                                                : _formatTime(_startTime!),
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: primaryColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                        child: Text(
                                          '-',
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: primaryColor,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: TextButton(
                                          onPressed: () async {
                                            final time = await showTimePicker(
                                              context: context,
                                              initialTime: TimeOfDay.now(),
                                            );
                                            if (time != null) {
                                              setState(() {
                                                _endTime = time;
                                              });
                                            }
                                          },
                                          style: TextButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                          ),
                                          child: Text(
                                            _endTime == null
                                                ? 'Конец'
                                                : _formatTime(_endTime!),
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: primaryColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _priceController,
                            style: const TextStyle(fontSize: 16),
                            decoration: _getInputDecoration(
                              'Цена за минуту',
                              Icons.currency_ruble,
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 24),
                          Center(
                            child: TextButton.icon(
                              onPressed: _resetCoordinates,
                              icon: const Icon(
                                Icons.refresh,
                                color: primaryColor,
                              ),
                              label: const Text(
                                'Сбросить координаты',
                                style: TextStyle(
                                  color: primaryColor,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: SizedBox(
                              width: 220,
                              height: 45,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 2,
                                ),
                                onPressed: _isLoading ? null : _saveZone,
                                child:
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
                                          'Сохранить зону',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                              ),
                            ),
                          ),
                        ],
                      ),
            ),
          ),
        ],
      ),
    );
  }
}
