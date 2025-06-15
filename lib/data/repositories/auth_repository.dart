import 'package:admin_panel/data/models/camera_parking_place.dart';
import 'package:admin_panel/data/models/camera_parking_place_create.dart';
import 'package:admin_panel/data/models/parking_place.dart';
import 'package:admin_panel/data/models/parking_place_create.dart';
import 'package:admin_panel/data/models/zone_snapshots_response.dart';

import '../models/token.dart';
import '../models/admin.dart';
import '../models/parking_zone.dart';
import '../models/zone_type.dart';
import '../models/parking_zone_detailed.dart';
import '../models/parking_zone_create.dart';
import '../models/camera.dart';
import '../models/camera_create.dart';
import '../services/api_service.dart';

abstract class AuthRepository {
  Future<Token> login(String email, String password);
  Future<Admin> getAdminProfile(String token);
  Future<void> logout(String token);
  Future<List<ParkingZone>> getZonesByAdmin(int adminId, String token);
  Future<List<ZoneType>> getZoneTypes(String token);
  Future<ParkingZoneDetailed> getZoneDetailed(int zoneId, String token);
  Future<ParkingZone> createZone(ParkingZoneCreate data, String token);
  Future<void> deleteZone(int zoneId, String token);
  Future<ParkingZone> updateZone(
    int zoneId,
    ParkingZoneCreate data,
    String token,
  );
  Future<Camera> createCamera(CameraCreate data, String token);
  Future<Camera> updateCamera(int cameraId, CameraCreate data, String token);
  Future<void> deleteCamera(int cameraId, String token);
  Future<ZoneSnapshotsResponse> getZoneSnapshots(int zoneId, String token);
  Future<Camera> getCamera(int cameraId, String token);
  Future<List<Camera>> getCamerasByZone(int zoneId, String token);
  Future<ParkingPlace> createPlace(ParkingPlaceCreate data, String token);
  Future<ParkingPlace> getPlace(int placeId, String token);
  Future<ParkingPlace> updatePlace(
    int placeId,
    ParkingPlaceCreate data,
    String token,
  );
  Future<void> deletePlace(int placeId, String token);
  Future<List<ParkingPlace>> getPlacesByZone(int zoneId, String token);
  Future<CameraParkingPlace> createCameraParkingPlace(
    CameraParkingPlaceCreate data,
    String token,
  );
  Future<CameraParkingPlace> updateCameraParkingPlace(
    int id,
    CameraParkingPlaceCreate data,
    String token,
  );
  Future<void> deleteCameraParkingPlace(int id, String token);
  Future<List<CameraParkingPlace>> listPlacesForCamera(
    int cameraId,
    String token,
  );
}

class AuthRepositoryImpl implements AuthRepository {
  final ApiService apiService;

  AuthRepositoryImpl(this.apiService);

  @override
  Future<Token> login(String email, String password) async {
    try {
      return await apiService.loginAdmin(email, password);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Admin> getAdminProfile(String token) async {
    try {
      return await apiService.getAdminProfile('Bearer $token');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> logout(String token) async {
    try {
      await apiService.logout('Bearer $token');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<ParkingZone>> getZonesByAdmin(int adminId, String token) async {
    try {
      return await apiService.getZonesByAdmin(adminId, 'Bearer $token');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<ZoneType>> getZoneTypes(String token) async {
    try {
      return await apiService.getZoneTypes('Bearer $token');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ParkingZoneDetailed> getZoneDetailed(int zoneId, String token) async {
    try {
      return await apiService.getZoneDetailed(zoneId, 'Bearer $token');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ParkingZone> createZone(ParkingZoneCreate data, String token) async {
    try {
      return await apiService.createZone(data, 'Bearer $token');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteZone(int zoneId, String token) async {
    try {
      await apiService.deleteZone(zoneId, 'Bearer $token');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ParkingZone> updateZone(
    int zoneId,
    ParkingZoneCreate data,
    String token,
  ) async {
    try {
      return await apiService.updateZone(zoneId, data, 'Bearer $token');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Camera> createCamera(CameraCreate data, String token) async {
    try {
      return await apiService.createCamera(data, 'Bearer $token');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Camera> updateCamera(
    int cameraId,
    CameraCreate data,
    String token,
  ) async {
    try {
      return await apiService.updateCamera(cameraId, data, 'Bearer $token');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteCamera(int cameraId, String token) async {
    try {
      await apiService.deleteCamera(cameraId, 'Bearer $token');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ZoneSnapshotsResponse> getZoneSnapshots(
    int zoneId,
    String token,
  ) async {
    try {
      return await apiService.getZoneSnapshots(zoneId, 'Bearer $token');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Camera> getCamera(int cameraId, String token) async {
    try {
      return await apiService.getCamera(cameraId, 'Bearer $token');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Camera>> getCamerasByZone(int zoneId, String token) async {
    try {
      return await apiService.getCamerasByZone(zoneId, 'Bearer $token');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ParkingPlace> createPlace(
    ParkingPlaceCreate data,
    String token,
  ) async {
    try {
      return await apiService.createPlace(data, 'Bearer $token');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ParkingPlace> getPlace(int placeId, String token) async {
    try {
      return await apiService.getPlace(placeId, 'Bearer $token');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ParkingPlace> updatePlace(
    int placeId,
    ParkingPlaceCreate data,
    String token,
  ) async {
    try {
      return await apiService.updatePlace(placeId, data, 'Bearer $token');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deletePlace(int placeId, String token) async {
    try {
      return await apiService.deletePlace(placeId, 'Bearer $token');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<ParkingPlace>> getPlacesByZone(int zoneId, String token) async {
    try {
      return await apiService.getPlacesByZone(zoneId, 'Bearer $token');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<CameraParkingPlace> createCameraParkingPlace(
    CameraParkingPlaceCreate data,
    String token,
  ) async {
    try {
      return await apiService.createCameraParkingPlace(data, 'Bearer $token');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<CameraParkingPlace> updateCameraParkingPlace(
    int id,
    CameraParkingPlaceCreate data,
    String token,
  ) async {
    try {
      return await apiService.updateCameraParkingPlace(
        id,
        data,
        'Bearer $token',
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteCameraParkingPlace(int id, String token) async {
    try {
      await apiService.deleteCameraParkingPlace(id, 'Bearer $token');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<CameraParkingPlace>> listPlacesForCamera(
    int cameraId,
    String token,
  ) async {
    try {
      return await apiService.listPlacesForCamera(cameraId, 'Bearer $token');
    } catch (e) {
      rethrow;
    }
  }
}
