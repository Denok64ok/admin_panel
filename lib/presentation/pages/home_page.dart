import 'package:admin_panel/domain/usecases/delete_zone_usecase.dart';
import 'package:admin_panel/domain/usecases/get_admin_profile_usecase.dart';
import 'package:admin_panel/domain/usecases/get_zone_detailed_usecase.dart';
import 'package:admin_panel/domain/usecases/get_zone_types_usecase.dart';
import 'package:admin_panel/domain/usecases/get_zones_usecase.dart';
import 'package:admin_panel/domain/usecases/update_zone_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../widgets/header.dart';
import '../widgets/search_widget.dart';
import '../widgets/map_controls_widget.dart';
import '../presenters/map_presenter.dart';
import '../../data/models/parking_zone.dart';
import '../../data/models/zone_type.dart';
import '../../data/models/parking_zone_detailed.dart';
import '../../di/injection.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> implements MapView {
  final MapController _mapController = MapController();
  late MapPresenter _presenter;
  List<ParkingZone> _zones = [];
  ParkingZoneDetailed? _selectedZone;

  @override
  void initState() {
    super.initState();
    _presenter = MapPresenter(
      getIt<GetZonesUseCase>(),
      getIt<GetZoneTypesUseCase>(),
      getIt<GetAdminProfileUseCase>(),
      getIt<GetZoneDetailedUseCase>(),
      getIt<DeleteZoneUseCase>(),
      getIt<UpdateZoneUseCase>(),
      this,
    );
    _presenter.loadZones();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green[700],
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  void showZones(List<ParkingZone> zones, List<ZoneType> zoneTypes) {
    setState(() {
      _zones = zones;
    });
  }

  @override
  void showError(String message) {
    if (message.contains('network') || message.contains('connection')) {
      _showError(
        'Ошибка подключения к серверу. Проверьте интернет-соединение.',
      );
    } else if (message.contains('not found')) {
      _showError('Зона не найдена. Возможно, она была удалена.');
    } else {
      _showError('Произошла ошибка. Пожалуйста, попробуйте позже.');
    }
  }

  @override
  void showZoneDetails(ParkingZoneDetailed zone) {
    setState(() {
      _selectedZone = zone;
    });
  }

  Widget _buildZoneDetailsWidget() {
    if (_selectedZone == null) return const SizedBox.shrink();

    final screenWidth = MediaQuery.of(context).size.width;
    return Positioned(
      top: 64,
      bottom: 80,
      width: screenWidth * 0.25,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(-2, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFF447BBA)),
                  onPressed: () => setState(() => _selectedZone = null),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: Colors.grey[600],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _selectedZone!.zoneName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF447BBA),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _selectedZone!.typeName,
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                _buildInfoRow(
                  Icons.location_on_outlined,
                  _selectedZone!.address,
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                  Icons.access_time_outlined,
                  '${_selectedZone!.startTime} - ${_selectedZone!.endTime}',
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                  Icons.local_parking_outlined,
                  'Количество мест: ${_selectedZone!.totalPlaces}',
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                  Icons.camera_alt_outlined,
                  'Количество камер: ${_selectedZone!.totalCameras}',
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                  Icons.currency_ruble_outlined,
                  '${_selectedZone!.pricePerMinute} руб/мин',
                ),
              ],
            ),
            const Spacer(),
            Column(
              children: [
                _buildActionButton(
                  'Редактировать зону',
                  () => context.push(
                    '/edit-zone/${_selectedZone!.id}',
                    extra: _selectedZone,
                  ),
                ),
                const SizedBox(height: 16),
                _buildActionButton(
                  'Редактировать места',
                  () => context.push(
                    '/manage-zone-details/${_selectedZone!.id}',
                    extra: _selectedZone,
                  ),
                ),
                const SizedBox(height: 16),
                _buildActionButton(
                  'Удалить зону',
                  () => _showDeleteConfirmation(_selectedZone!),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 24, color: const Color(0xFF447BBA)),
        const SizedBox(width: 16),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
      ],
    );
  }

  Widget _buildActionButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: 220,
      height: 40,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF447BBA),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          elevation: 2,
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(ParkingZoneDetailed zone) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Подтверждение удаления',
            style: TextStyle(
              color: Color(0xFF447BBA),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Вы действительно хотите удалить зону "${zone.zoneName}"?\n\n'
            'Это действие также удалит:\n'
            '• Все камеры в этой зоне (${zone.totalCameras})\n'
            '• Все парковочные места (${zone.totalPlaces})\n'
            '• Все разметки мест на камерах',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Отмена',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Удалить',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: Colors.white,
        );
      },
    );

    if (confirmed == true) {
      _presenter.deleteZone(zone.id);
      setState(() => _selectedZone = null);
      _showSuccess('Зона успешно удалена');
    }
  }

  Color _getZoneColor(int zoneTypeId) {
    final colors = {
      1: Colors.blue.withOpacity(0.5),
      2: Colors.green.withOpacity(0.5),
      3: Colors.red.withOpacity(0.5),
    };
    return colors[zoneTypeId] ?? Colors.grey.withOpacity(0.5);
  }

  bool _isPointInPolygon(LatLng point, List<List<double>> vertices) {
    int intersectCount = 0;
    for (int i = 0; i < vertices.length; i++) {
      final j = (i + 1) % vertices.length;
      final vertex1 = LatLng(vertices[i][0], vertices[i][1]);
      final vertex2 = LatLng(vertices[j][0], vertices[j][1]);

      if ((vertex1.latitude > point.latitude) !=
              (vertex2.latitude > point.latitude) &&
          point.longitude <
              (vertex2.longitude - vertex1.longitude) *
                      (point.latitude - vertex1.latitude) /
                      (vertex2.latitude - vertex1.latitude) +
                  vertex1.longitude) {
        intersectCount++;
      }
    }
    return intersectCount % 2 == 1;
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
                for (var zone in _zones) {
                  final location =
                      zone.location
                          .map((innerList) => innerList.cast<double>().toList())
                          .toList();
                  if (_isPointInPolygon(point, location)) {
                    _presenter.loadZoneDetails(zone.id);
                    break;
                  }
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
                userAgentPackageName: 'com.example.admin_panel',
              ),
              PolygonLayer(
                polygons:
                    _zones.map((zone) {
                      return Polygon(
                        points:
                            zone.location
                                .map((coord) => LatLng(coord[0], coord[1]))
                                .toList(),
                        color: _getZoneColor(zone.zoneTypeId),
                        borderColor: Colors.black,
                        borderStrokeWidth: 2.0,
                        isFilled: true,
                      );
                    }).toList(),
              ),
            ],
          ),
          SearchWidget(mapController: _mapController),
          _buildZoneDetailsWidget(),
          MapControlsWidget(mapController: _mapController),
          Positioned(
            bottom: 24,
            right: 24,
            child: SizedBox(
              height: 48,
              child: FloatingActionButton.extended(
                backgroundColor: const Color(0xFF447BBA),
                foregroundColor: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                onPressed: () => context.go('/add-zone'),
                icon: const Icon(Icons.add),
                label: const Text(
                  'Добавить зону',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
