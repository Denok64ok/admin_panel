import 'package:admin_panel/presentation/widgets/header.dart';
import 'package:admin_panel/presentation/widgets/map_controls_widget.dart';
import 'package:admin_panel/presentation/widgets/search_widget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../data/models/zone_type.dart';
import '../../data/models/parking_zone_create.dart';
import '../../data/models/admin.dart';
import '../../data/models/parking_zone_detailed.dart';
import '../../di/injection.dart';
import '../../domain/usecases/get_zone_types_usecase.dart';
import '../../domain/usecases/get_admin_profile_usecase.dart';
import '../../domain/usecases/update_zone_usecase.dart';
import '../../domain/usecases/get_zones_usecase.dart';
import 'package:go_router/go_router.dart';

class EditZonePage extends StatefulWidget {
  final ParkingZoneDetailed zone;

  const EditZonePage({super.key, required this.zone});

  @override
  _EditZonePageState createState() => _EditZonePageState();
}

class _EditZonePageState extends State<EditZonePage> {
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
  late int _zoneId;
  bool _isLoading = false;

  static const primaryColor = Color(0xFF447BBA);

  @override
  void initState() {
    super.initState();
    _zoneId = widget.zone.id;
    _initializeFields();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      await Future.wait([_loadAdminProfile(), _loadZoneTypes()]);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _initializeFields() {
    _zoneNameController.text = widget.zone.zoneName;
    _addressController.text = widget.zone.address;
    _priceController.text = widget.zone.pricePerMinute.toString();
    _startTime = _parseTime(widget.zone.startTime);
    _endTime = _parseTime(widget.zone.endTime);
  }

  TimeOfDay _parseTime(String timeStr) {
    try {
      final parts = timeStr.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (e) {
      return TimeOfDay.now();
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
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
      await _loadZoneCoordinates();
    } catch (e) {
      _showErrorSnackBar('Не удалось загрузить профиль администратора');
    }
  }

  Future<void> _loadZoneCoordinates() async {
    if (_admin == null) {
      _showErrorSnackBar('Профиль администратора не загружен');
      return;
    }
    try {
      final token = await _storage.read(key: 'access_token');
      if (token == null) {
        _showErrorSnackBar('Ошибка авторизации. Пожалуйста, войдите снова.');
        return;
      }
      final zones = await getIt<GetZonesUseCase>().execute(_admin!.id, token);
      final zone = zones.firstWhere(
        (z) => z.id == _zoneId,
        orElse: () => throw Exception('Зона не найдена'),
      );
      if (zone.location.isEmpty) {
        _showErrorSnackBar('Координаты зоны отсутствуют');
        return;
      }
      setState(() {
        _points =
            zone.location.map((coord) => LatLng(coord[0], coord[1])).toList();
      });
    } catch (e) {
      _showErrorSnackBar('Не удалось загрузить координаты зоны');
    }
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
        _selectedZoneType = zoneTypes.firstWhere(
          (type) => type.typeName == widget.zone.typeName,
          orElse: () => zoneTypes.first,
        );
      });
    } catch (e) {
      _showErrorSnackBar('Не удалось загрузить типы зон');
    }
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

  Future<void> _updateZone() async {
    if (!_validateForm()) return;

    setState(() => _isLoading = true);
    try {
      final token = await _storage.read(key: 'access_token');
      if (token == null) {
        _showErrorSnackBar('Ошибка авторизации. Пожалуйста, войдите снова.');
        return;
      }

      final zoneData = ParkingZoneCreate(
        adminId: _admin!.id,
        zoneName: _zoneNameController.text.trim(),
        zoneTypeId: _selectedZoneType!.id,
        address: _addressController.text.trim(),
        startTime: _formatTime(_startTime!),
        endTime: _formatTime(_endTime!),
        pricePerMinute: int.parse(_priceController.text.trim()),
        location: _points.map((p) => [p.latitude, p.longitude]).toList(),
      );

      await getIt<UpdateZoneUseCase>().execute(_zoneId, zoneData, token);
      if (mounted) {
        _showSuccessSnackBar('Зона успешно обновлена');
        context.go('/home');
      }
    } catch (e) {
      String errorMessage = 'Не удалось обновить зону';
      if (e is DioException && e.response != null) {
        errorMessage = e.response!.data['detail'] ?? errorMessage;
      }
      _showErrorSnackBar(errorMessage);
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

  LatLng _calculateZoneCenter(List<List<dynamic>> location) {
    if (location.isEmpty) {
      return LatLng(55.441004, 65.341118);
    }
    if (location.length == 1) {
      return LatLng(location[0][0] as double, location[0][1] as double);
    }
    double avgLat = 0.0;
    double avgLng = 0.0;
    for (var coord in location) {
      avgLat += coord[0] as double;
      avgLng += coord[1] as double;
    }
    avgLat /= location.length;
    avgLng /= location.length;
    return LatLng(avgLat, avgLng);
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
              initialCenter: _calculateZoneCenter(widget.zone.location),
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
                              'Редактирование зоны',
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
                                              initialTime:
                                                  _startTime ?? TimeOfDay.now(),
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
                                              initialTime:
                                                  _endTime ?? TimeOfDay.now(),
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
                                onPressed: _isLoading ? null : _updateZone,
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
                                          'Обновить зону',
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
