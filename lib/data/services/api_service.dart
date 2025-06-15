import 'package:admin_panel/data/models/camera_parking_place.dart';
import 'package:admin_panel/data/models/camera_parking_place_create.dart';
import 'package:admin_panel/data/models/parking_place.dart';
import 'package:admin_panel/data/models/parking_place_create.dart';
import 'package:admin_panel/data/models/zone_snapshots_response.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/token.dart';
import '../models/admin.dart';
import '../models/parking_zone.dart';
import '../models/zone_type.dart';
import '../models/parking_zone_detailed.dart';
import '../models/parking_zone_create.dart';
import '../models/camera.dart';
import '../models/camera_create.dart';

part 'api_service.g.dart';

@RestApi(baseUrl: 'http://localhost:8000/')
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

  @POST('/auth/token/admin')
  @FormUrlEncoded()
  Future<Token> loginAdmin(
    @Field('username') String username,
    @Field('password') String password,
  );

  @GET('/auth/admin/me')
  Future<Admin> getAdminProfile(@Header('Authorization') String token);

  @POST('/auth/logout')
  Future<void> logout(@Header('Authorization') String token);

  @GET('/zones/admin/{admin_id}')
  Future<List<ParkingZone>> getZonesByAdmin(
    @Path('admin_id') int adminId,
    @Header('Authorization') String token,
  );

  @GET('/zone-types/')
  Future<List<ZoneType>> getZoneTypes(@Header('Authorization') String token);

  @GET('/zones/{zone_id}/detailed')
  Future<ParkingZoneDetailed> getZoneDetailed(
    @Path('zone_id') int zoneId,
    @Header('Authorization') String token,
  );

  @POST('/zones/')
  Future<ParkingZone> createZone(
    @Body() ParkingZoneCreate data,
    @Header('Authorization') String token,
  );

  @DELETE('/zones/{zone_id}')
  Future<void> deleteZone(
    @Path('zone_id') int zoneId,
    @Header('Authorization') String token,
  );

  @PUT('/zones/{zone_id}')
  Future<ParkingZone> updateZone(
    @Path('zone_id') int zoneId,
    @Body() ParkingZoneCreate data,
    @Header('Authorization') String token,
  );

  @POST('/camera/')
  Future<Camera> createCamera(
    @Body() CameraCreate data,
    @Header('Authorization') String token,
  );

  @PUT('/camera/{camera_id}')
  Future<Camera> updateCamera(
    @Path('camera_id') int cameraId,
    @Body() CameraCreate data,
    @Header('Authorization') String token,
  );

  @DELETE('/camera/{camera_id}')
  Future<void> deleteCamera(
    @Path('camera_id') int cameraId,
    @Header('Authorization') String token,
  );

  @GET('/camera/snapshot/{zone_id}')
  Future<ZoneSnapshotsResponse> getZoneSnapshots(
    @Path('zone_id') int zoneId,
    @Header('Authorization') String token,
  );

  @GET('/camera/{camera_id}')
  Future<Camera> getCamera(
    @Path('camera_id') int cameraId,
    @Header('Authorization') String token,
  );

  @GET('/camera/zone/{zone_id}')
  Future<List<Camera>> getCamerasByZone(
    @Path('zone_id') int zoneId,
    @Header('Authorization') String token,
  );

  @POST('/places/')
  Future<ParkingPlace> createPlace(
    @Body() ParkingPlaceCreate data,
    @Header('Authorization') String token,
  );

  @GET('/places/{place_id}')
  Future<ParkingPlace> getPlace(
    @Path('place_id') int placeId,
    @Header('Authorization') String token,
  );

  @PUT('/places/{place_id}')
  Future<ParkingPlace> updatePlace(
    @Path('place_id') int placeId,
    @Body() ParkingPlaceCreate data,
    @Header('Authorization') String token,
  );

  @DELETE('/places/{place_id}')
  Future<void> deletePlace(
    @Path('place_id') int placeId,
    @Header('Authorization') String token,
  );

  @GET('/places/zone/{zone_id}')
  Future<List<ParkingPlace>> getPlacesByZone(
    @Path('zone_id') int zoneId,
    @Header('Authorization') String token,
  );

  @POST('/camera-parking-place/')
  Future<CameraParkingPlace> createCameraParkingPlace(
    @Body() CameraParkingPlaceCreate data,
    @Header('Authorization') String token,
  );

  @PUT('/camera-parking-place/{id}')
  Future<CameraParkingPlace> updateCameraParkingPlace(
    @Path('id') int id,
    @Body() CameraParkingPlaceCreate data,
    @Header('Authorization') String token,
  );

  @DELETE('/camera-parking-place/{id}')
  Future<void> deleteCameraParkingPlace(
    @Path('id') int id,
    @Header('Authorization') String token,
  );

  @GET('/camera-parking-place/camera/{camera_id}')
  Future<List<CameraParkingPlace>> listPlacesForCamera(
    @Path('camera_id') int cameraId,
    @Header('Authorization') String token,
  );
}
