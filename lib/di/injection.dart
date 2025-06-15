import 'package:admin_panel/domain/usecases/create_camera_parking_place_usecase.dart';
import 'package:admin_panel/domain/usecases/create_place_usecase.dart';
import 'package:admin_panel/domain/usecases/delete_camera_parking_place_usecase.dart';
import 'package:admin_panel/domain/usecases/delete_place_usecase.dart';
import 'package:admin_panel/domain/usecases/get_camera_usecase.dart';
import 'package:admin_panel/domain/usecases/get_cameras_by_zone_usecase.dart';
import 'package:admin_panel/domain/usecases/get_place_usecase.dart';
import 'package:admin_panel/domain/usecases/get_places_by_zone_usecase.dart';
import 'package:admin_panel/domain/usecases/list_places_for_camera_usecase.dart';
import 'package:admin_panel/domain/usecases/update_camera_parking_place_usecase.dart';
import 'package:admin_panel/domain/usecases/update_place_usecase.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../data/repositories/auth_repository.dart';
import '../data/services/api_service.dart';
import '../domain/usecases/login_usecase.dart';
import '../domain/usecases/get_admin_profile_usecase.dart';
import '../domain/usecases/logout_usecase.dart';
import '../domain/usecases/get_zones_usecase.dart';
import '../domain/usecases/get_zone_types_usecase.dart';
import '../domain/usecases/get_zone_detailed_usecase.dart';
import '../domain/usecases/create_zone_usecase.dart';
import '../domain/usecases/delete_zone_usecase.dart';
import '../domain/usecases/update_zone_usecase.dart';
import '../domain/usecases/create_camera_usecase.dart';
import '../domain/usecases/update_camera_usecase.dart';
import '../domain/usecases/delete_camera_usecase.dart';
import '../domain/usecases/get_zone_snapshots_usecase.dart';

final getIt = GetIt.instance;

void setupDi() {
  getIt.registerSingleton<Dio>(Dio());
  getIt.registerSingleton<FlutterSecureStorage>(const FlutterSecureStorage());
  getIt.registerSingleton<ApiService>(ApiService(getIt<Dio>()));
  getIt.registerSingleton<AuthRepository>(
    AuthRepositoryImpl(getIt<ApiService>()),
  );
  getIt.registerSingleton<LoginUseCase>(LoginUseCase(getIt<AuthRepository>()));
  getIt.registerSingleton<GetAdminProfileUseCase>(
    GetAdminProfileUseCase(getIt<AuthRepository>()),
  );
  getIt.registerSingleton<LogoutUseCase>(
    LogoutUseCase(getIt<AuthRepository>()),
  );
  getIt.registerSingleton<GetZonesUseCase>(
    GetZonesUseCase(getIt<AuthRepository>()),
  );
  getIt.registerSingleton<GetZoneTypesUseCase>(
    GetZoneTypesUseCase(getIt<AuthRepository>()),
  );
  getIt.registerSingleton<GetZoneDetailedUseCase>(
    GetZoneDetailedUseCase(getIt<AuthRepository>()),
  );
  getIt.registerSingleton<CreateZoneUseCase>(
    CreateZoneUseCase(getIt<AuthRepository>()),
  );
  getIt.registerSingleton<DeleteZoneUseCase>(
    DeleteZoneUseCase(getIt<AuthRepository>()),
  );
  getIt.registerSingleton<UpdateZoneUseCase>(
    UpdateZoneUseCase(getIt<AuthRepository>()),
  );
  getIt.registerSingleton<CreateCameraUseCase>(
    CreateCameraUseCase(getIt<AuthRepository>()),
  );
  getIt.registerSingleton<UpdateCameraUseCase>(
    UpdateCameraUseCase(getIt<AuthRepository>()),
  );
  getIt.registerSingleton<DeleteCameraUseCase>(
    DeleteCameraUseCase(getIt<AuthRepository>()),
  );
  getIt.registerSingleton<GetZoneSnapshotsUseCase>(
    GetZoneSnapshotsUseCase(getIt<AuthRepository>()),
  );
  getIt.registerSingleton<GetCameraUseCase>(
    GetCameraUseCase(getIt<AuthRepository>()),
  );
  getIt.registerSingleton<GetCamerasByZoneUseCase>(
    GetCamerasByZoneUseCase(getIt<AuthRepository>()),
  );
  getIt.registerSingleton<CreatePlaceUseCase>(
    CreatePlaceUseCase(getIt<AuthRepository>()),
  );
  getIt.registerSingleton<GetPlaceUseCase>(
    GetPlaceUseCase(getIt<AuthRepository>()),
  );
  getIt.registerSingleton<UpdatePlaceUseCase>(
    UpdatePlaceUseCase(getIt<AuthRepository>()),
  );
  getIt.registerSingleton<DeletePlaceUseCase>(
    DeletePlaceUseCase(getIt<AuthRepository>()),
  );
  getIt.registerSingleton<GetPlacesByZoneUseCase>(
    GetPlacesByZoneUseCase(getIt<AuthRepository>()),
  );
  getIt.registerSingleton<CreateCameraParkingPlaceUseCase>(
    CreateCameraParkingPlaceUseCase(getIt<AuthRepository>()),
  );
  getIt.registerSingleton<UpdateCameraParkingPlaceUseCase>(
    UpdateCameraParkingPlaceUseCase(getIt<AuthRepository>()),
  );
  getIt.registerSingleton<DeleteCameraParkingPlaceUseCase>(
    DeleteCameraParkingPlaceUseCase(getIt<AuthRepository>()),
  );
  getIt.registerSingleton<ListPlacesForCameraUseCase>(
    ListPlacesForCameraUseCase(getIt<AuthRepository>()),
  );
}
