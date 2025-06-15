import 'package:admin_panel/di/injection.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../data/models/parking_zone.dart';
import '../../data/models/zone_type.dart';
import '../../data/models/parking_zone_detailed.dart';
import '../../domain/usecases/get_zones_usecase.dart';
import '../../domain/usecases/get_zone_types_usecase.dart';
import '../../domain/usecases/get_admin_profile_usecase.dart';
import '../../domain/usecases/get_zone_detailed_usecase.dart';
import '../../domain/usecases/delete_zone_usecase.dart';
import '../../domain/usecases/update_zone_usecase.dart';

abstract class MapView {
  void showZones(List<ParkingZone> zones, List<ZoneType> zoneTypes);
  void showError(String message);
  void showZoneDetails(ParkingZoneDetailed zone);
}

class MapPresenter {
  final GetZonesUseCase getZonesUseCase;
  final GetZoneTypesUseCase getZoneTypesUseCase;
  final GetAdminProfileUseCase getAdminProfileUseCase;
  final GetZoneDetailedUseCase getZoneDetailedUseCase;
  final DeleteZoneUseCase deleteZoneUseCase;
  final UpdateZoneUseCase updateZoneUseCase;
  final MapView view;

  MapPresenter(
    this.getZonesUseCase,
    this.getZoneTypesUseCase,
    this.getAdminProfileUseCase,
    this.getZoneDetailedUseCase,
    this.deleteZoneUseCase,
    this.updateZoneUseCase,
    this.view,
  );

  Future<void> loadZones() async {
    try {
      final token = await getIt<FlutterSecureStorage>().read(
        key: 'access_token',
      );
      if (token == null) {
        view.showError('No token found');
        return;
      }

      final admin = await getAdminProfileUseCase.execute(token);
      final zones = await getZonesUseCase.execute(admin.id, token);
      final zoneTypes = await getZoneTypesUseCase.execute(token);
      view.showZones(zones, zoneTypes);
    } catch (e) {
      view.showError('Failed to load zones: $e');
    }
  }

  Future<void> loadZoneDetails(int zoneId) async {
    try {
      final token = await getIt<FlutterSecureStorage>().read(
        key: 'access_token',
      );
      if (token == null) {
        view.showError('No token found');
        return;
      }

      final zoneDetails = await getZoneDetailedUseCase.execute(zoneId, token);
      view.showZoneDetails(zoneDetails);
    } catch (e) {
      view.showError('Failed to load zone details: $e');
    }
  }

  Future<void> deleteZone(int zoneId) async {
    try {
      final token = await getIt<FlutterSecureStorage>().read(
        key: 'access_token',
      );
      if (token == null) {
        view.showError('No token found');
        return;
      }

      await deleteZoneUseCase.execute(zoneId, token);
      await loadZones();
    } catch (e) {
      view.showError('Failed to delete zone: $e');
    }
  }
}
