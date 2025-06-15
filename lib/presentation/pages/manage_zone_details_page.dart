import 'dart:convert';
import 'dart:ui' as ui;
import 'package:admin_panel/presentation/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../data/models/camera.dart';
import '../../data/models/camera_create.dart';
import '../../data/models/camera_snapshot.dart';
import '../../data/models/parking_place.dart';
import '../../data/models/parking_place_create.dart';
import '../../data/models/camera_parking_place.dart';
import '../../data/models/camera_parking_place_create.dart';
import '../../di/injection.dart';
import '../../domain/usecases/create_camera_usecase.dart';
import '../../domain/usecases/update_camera_usecase.dart';
import '../../domain/usecases/delete_camera_usecase.dart';
import '../../domain/usecases/get_zone_snapshots_usecase.dart';
import '../../domain/usecases/get_camera_usecase.dart';
import '../../domain/usecases/get_cameras_by_zone_usecase.dart';
import '../../domain/usecases/create_place_usecase.dart';
import '../../domain/usecases/get_place_usecase.dart';
import '../../domain/usecases/update_place_usecase.dart';
import '../../domain/usecases/delete_place_usecase.dart';
import '../../domain/usecases/get_places_by_zone_usecase.dart';
import '../../domain/usecases/create_camera_parking_place_usecase.dart';
import '../../domain/usecases/update_camera_parking_place_usecase.dart';
import '../../domain/usecases/delete_camera_parking_place_usecase.dart';
import '../../domain/usecases/list_places_for_camera_usecase.dart';

class ManageZoneDetailsPage extends StatefulWidget {
  final int zoneId;

  const ManageZoneDetailsPage({super.key, required this.zoneId});

  @override
  _ManageZoneDetailsPageState createState() => _ManageZoneDetailsPageState();
}

class _ManageZoneDetailsPageState extends State<ManageZoneDetailsPage> {
  final _storage = const FlutterSecureStorage();
  final _cameraNameController = TextEditingController();
  final _cameraUrlController = TextEditingController();
  final _placeNumberController = TextEditingController();
  int? _selectedCameraId;
  int? _selectedPlaceId;
  String? _errorMessage;
  List<CameraSnapshot> _snapshots = [];
  CameraSnapshot? _selectedSnapshot;
  List<Camera> _cameras = [];
  List<ParkingPlace> _places = [];
  List<CameraParkingPlace> _cameraPlaces = [];
  List<Offset> _currentPoints = [];
  bool _isMarking = false;
  bool _showAllPlaces = false;
  int? _editingCameraPlaceId;
  Size? _imageSize;

  // Добавляем индикаторы загрузки
  bool _isLoadingCameras = false;
  bool _isLoadingPlaces = false;
  bool _isLoadingSnapshots = false;
  bool _isSavingCamera = false;
  bool _isSavingPlace = false;
  bool _isSavingCoordinates = false;

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green[700],
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadCameras();
    _loadSnapshots();
    _loadPlaces();
  }

  Future<void> _loadCameras() async {
    if (_isLoadingCameras) return;

    setState(() {
      _isLoadingCameras = true;
      _errorMessage = null;
    });

    try {
      final token = await _storage.read(key: 'access_token');
      if (token == null) {
        _showError('Ошибка авторизации. Пожалуйста, войдите в систему заново.');
        return;
      }

      final cameras = await getIt<GetCamerasByZoneUseCase>().execute(
        widget.zoneId,
        token,
      );

      if (!mounted) return;

      setState(() {
        _cameras = cameras;
        _selectedCameraId = cameras.isNotEmpty ? cameras.first.id : null;
        if (_selectedCameraId != null) {
          _loadCameraDetails(_selectedCameraId!);
          _loadCameraPlaces(_selectedCameraId!);
          _updateSelectedSnapshot();
        }
      });
    } catch (e) {
      if (mounted) {
        _showError(
          'Не удалось загрузить список камер. Проверьте подключение к сети.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingCameras = false;
        });
      }
    }
  }

  Future<void> _loadCameraDetails(int cameraId) async {
    try {
      final token = await _storage.read(key: 'access_token');
      if (token == null) {
        _showError('Ошибка авторизации. Пожалуйста, войдите в систему заново.');
        return;
      }

      final camera = await getIt<GetCameraUseCase>().execute(cameraId, token);
      setState(() {
        _cameraNameController.text = camera.cameraName;
        _cameraUrlController.text = camera.url;
      });
    } catch (e) {
      _showError(
        'Не удалось загрузить данные камеры. Попробуйте выбрать камеру снова.',
      );
    }
  }

  Future<void> _loadPlaces() async {
    if (_isLoadingPlaces) return;

    setState(() {
      _isLoadingPlaces = true;
      _errorMessage = null;
    });

    try {
      final token = await _storage.read(key: 'access_token');
      if (token == null) {
        _showError('Ошибка авторизации. Пожалуйста, войдите в систему заново.');
        return;
      }

      final places = await getIt<GetPlacesByZoneUseCase>().execute(
        widget.zoneId,
        token,
      );

      if (!mounted) return;

      setState(() {
        _places = places;
        _selectedPlaceId = places.isNotEmpty ? places.first.id : null;
        if (_selectedPlaceId != null) {
          _loadPlaceDetails(_selectedPlaceId!);
        }
      });
    } catch (e) {
      if (mounted) {
        _showError(
          'Не удалось загрузить список парковочных мест. Проверьте подключение к сети.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingPlaces = false;
        });
      }
    }
  }

  Future<void> _loadPlaceDetails(int placeId) async {
    try {
      final token = await _storage.read(key: 'access_token');
      if (token == null) {
        _showError('Ошибка авторизации. Пожалуйста, войдите в систему заново.');
        return;
      }

      final place = await getIt<GetPlaceUseCase>().execute(placeId, token);
      setState(() {
        _placeNumberController.text = place.placeNumber.toString();
      });
    } catch (e) {
      _showError(
        'Не удалось загрузить данные парковочного места. Попробуйте выбрать место снова.',
      );
    }
  }

  Future<void> _loadSnapshots() async {
    if (_isLoadingSnapshots) return;

    setState(() {
      _isLoadingSnapshots = true;
      _errorMessage = null;
    });

    try {
      final token = await _storage.read(key: 'access_token');
      if (token == null) {
        _showError('Ошибка авторизации. Пожалуйста, войдите в систему заново.');
        return;
      }

      final snapshotsResponse = await getIt<GetZoneSnapshotsUseCase>().execute(
        widget.zoneId,
        token,
      );

      if (!mounted) return;

      setState(() {
        _snapshots = snapshotsResponse.snapshots;
        _updateSelectedSnapshot();
        if (_selectedSnapshot != null) {
          _loadImageSize();
        }
      });
    } catch (e) {
      if (mounted) {
        _showError(
          'Не удалось загрузить снимки с камер. Проверьте подключение к сети.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingSnapshots = false;
        });
      }
    }
  }

  void _updateSelectedSnapshot() {
    if (_selectedCameraId == null || _snapshots.isEmpty) {
      _selectedSnapshot = null;
      return;
    }
    final matchingSnapshot = _snapshots.firstWhere(
      (s) => s.cameraId == _selectedCameraId,
      orElse: () => _snapshots.first,
    );
    if (matchingSnapshot.cameraId == _selectedCameraId) {
      _selectedSnapshot = matchingSnapshot;
    } else {
      _selectedSnapshot = null;
    }
  }

  Future<void> _loadImageSize() async {
    if (_selectedSnapshot == null) return;
    try {
      final bytes = base64Decode(_selectedSnapshot!.imageBase64);
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      setState(() {
        _imageSize = Size(
          frame.image.width.toDouble(),
          frame.image.height.toDouble(),
        );
      });
    } catch (e) {
      _showError(
        'Не удалось загрузить размер изображения. Попробуйте обновить снимок.',
      );
    }
  }

  Future<void> _loadCameraPlaces(int cameraId) async {
    try {
      final token = await _storage.read(key: 'access_token');
      if (token == null) {
        _showError('Токен не найден');
        return;
      }

      final cameraPlaces = await getIt<ListPlacesForCameraUseCase>().execute(
        cameraId,
        token,
      );

      if (!mounted) return;

      setState(() {
        _cameraPlaces = cameraPlaces;
        _errorMessage = null;

        // Сбрасываем текущее состояние
        _editingCameraPlaceId = null;
        _currentPoints = [];

        // Если выбрано парковочное место, проверяем его наличие на камере
        if (_selectedPlaceId != null) {
          // Ищем существующую разметку для выбранного места на текущей камере
          final existingPlace = _cameraPlaces.firstWhere(
            (cp) =>
                cp.parkingPlaceId == _selectedPlaceId &&
                cp.cameraId == cameraId,
            orElse:
                () => CameraParkingPlace(
                  id: 0,
                  cameraId: 0,
                  parkingPlaceId: 0,
                  location: [],
                ),
          );

          // Если место уже размечено на этой камере
          if (existingPlace.id != 0) {
            _editingCameraPlaceId = existingPlace.id;
            // Берем только первые 4 точки для редактирования (без дублирующей последней точки)
            if (existingPlace.location.isNotEmpty) {
              _currentPoints =
                  existingPlace.location
                      .take(4)
                      .map((p) => Offset(p[0].toDouble(), p[1].toDouble()))
                      .toList();
            }
          }
        }
      });
    } catch (e) {
      _showError(
        'Не удалось загрузить парковочные места для камеры. Попробуйте выбрать камеру снова.',
      );
    }
  }

  Future<void> _addCamera() async {
    if (_isSavingCamera) return;

    if (_cameraNameController.text.isEmpty ||
        _cameraUrlController.text.isEmpty) {
      _showError('Пожалуйста, заполните название и URL камеры.');
      return;
    }

    setState(() {
      _isSavingCamera = true;
      _errorMessage = null;
    });

    try {
      final token = await _storage.read(key: 'access_token');
      if (token == null) {
        _showError('Ошибка авторизации. Пожалуйста, войдите в систему заново.');
        return;
      }

      final cameraData = CameraCreate(
        cameraName: _cameraNameController.text,
        url: _cameraUrlController.text,
        parkingZoneId: widget.zoneId,
      );

      await getIt<CreateCameraUseCase>().execute(cameraData, token);
      await _loadCameras();
      await _loadSnapshots();

      if (!mounted) return;

      setState(() {
        _cameraNameController.clear();
        _cameraUrlController.clear();
      });
      _showSuccess('Камера успешно добавлена');
    } catch (e) {
      if (mounted) {
        _showError(
          'Не удалось добавить камеру. Проверьте правильность введенных данных.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSavingCamera = false;
        });
      }
    }
  }

  Future<void> _updateCamera() async {
    if (_selectedCameraId == null ||
        _cameraNameController.text.isEmpty ||
        _cameraUrlController.text.isEmpty) {
      _showError('Пожалуйста, выберите камеру и заполните все поля.');
      return;
    }

    try {
      final token = await _storage.read(key: 'access_token');
      if (token == null) {
        _showError('Ошибка авторизации. Пожалуйста, войдите в систему заново.');
        return;
      }

      final cameraData = CameraCreate(
        cameraName: _cameraNameController.text,
        url: _cameraUrlController.text,
        parkingZoneId: widget.zoneId,
      );

      await getIt<UpdateCameraUseCase>().execute(
        _selectedCameraId!,
        cameraData,
        token,
      );
      await _loadCameras();
      await _loadSnapshots();
      setState(() {
        _cameraNameController.clear();
        _cameraUrlController.clear();
        _selectedCameraId = _cameras.isNotEmpty ? _cameras.first.id : null;
        if (_selectedCameraId != null) {
          _loadCameraDetails(_selectedCameraId!);
        }
      });
      _showSuccess('Данные камеры успешно обновлены');
    } catch (e) {
      _showError(
        'Не удалось обновить данные камеры. Проверьте правильность введенных данных.',
      );
    }
  }

  Future<void> _deleteCamera() async {
    if (_selectedCameraId == null) {
      _showError('Пожалуйста, выберите камеру для удаления');
      return;
    }

    try {
      final token = await _storage.read(key: 'access_token');
      if (token == null) {
        _showError('Ошибка авторизации. Пожалуйста, войдите в систему заново.');
        return;
      }

      // Находим информацию о камере для отображения в диалоге
      final camera = _cameras.firstWhere(
        (c) => c.id == _selectedCameraId,
        orElse: () => Camera(id: 0, cameraName: '', url: '', parkingZoneId: 0),
      );

      if (camera.id == 0) {
        _showError('Камера не найдена');
        return;
      }

      // Показываем диалог подтверждения
      if (!mounted) return;

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
              'Вы действительно хотите удалить камеру "${camera.cameraName}"?\n\n'
              'Это действие также удалит все разметки мест, связанные с этой камерой.',
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            backgroundColor: Colors.white,
          );
        },
      );

      if (confirmed != true) return;

      await getIt<DeleteCameraUseCase>().execute(_selectedCameraId!, token);
      await _loadCameras();
      await _loadSnapshots();

      if (!mounted) return;

      setState(() {
        _cameraNameController.clear();
        _cameraUrlController.clear();
        _selectedCameraId = _cameras.isNotEmpty ? _cameras.first.id : null;
        if (_selectedCameraId != null) {
          _loadCameraDetails(_selectedCameraId!);
          _loadCameraPlaces(_selectedCameraId!);
        }
      });
      _showSuccess('Камера успешно удалена');
    } catch (e) {
      _showError(
        'Не удалось удалить камеру. Возможно, она используется в системе.',
      );
    }
  }

  Future<void> _savePlace() async {
    if (_isSavingPlace) return;

    if (_placeNumberController.text.isEmpty) {
      _showError('Пожалуйста, введите номер парковочного места.');
      return;
    }

    setState(() {
      _isSavingPlace = true;
      _errorMessage = null;
    });

    try {
      final token = await _storage.read(key: 'access_token');
      if (token == null) {
        _showError('Ошибка авторизации. Пожалуйста, войдите в систему заново.');
        return;
      }

      final placeData = ParkingPlaceCreate(
        placeNumber: int.parse(_placeNumberController.text),
        parkingZoneId: widget.zoneId,
      );

      await getIt<CreatePlaceUseCase>().execute(placeData, token);
      await _loadPlaces();

      if (!mounted) return;

      setState(() {
        _placeNumberController.clear();
      });
      _showSuccess('Парковочное место успешно добавлено');
    } catch (e) {
      if (mounted) {
        _showError(
          'Не удалось создать парковочное место. Проверьте правильность номера.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSavingPlace = false;
        });
      }
    }
  }

  Future<void> _updatePlace() async {
    if (_selectedPlaceId == null || _placeNumberController.text.isEmpty) {
      _showError('Пожалуйста, выберите парковочное место и введите его номер.');
      return;
    }

    try {
      final token = await _storage.read(key: 'access_token');
      if (token == null) {
        _showError('Ошибка авторизации. Пожалуйста, войдите в систему заново.');
        return;
      }

      final placeData = ParkingPlaceCreate(
        placeNumber: int.parse(_placeNumberController.text),
        parkingZoneId: widget.zoneId,
      );

      await getIt<UpdatePlaceUseCase>().execute(
        _selectedPlaceId!,
        placeData,
        token,
      );
      await _loadPlaces();
      setState(() {
        _placeNumberController.clear();
        _selectedPlaceId = _places.isNotEmpty ? _places.first.id : null;
        if (_selectedPlaceId != null) {
          _loadPlaceDetails(_selectedPlaceId!);
        }
      });
      _showSuccess('Данные парковочного места успешно обновлены');
    } catch (e) {
      _showError(
        'Не удалось обновить парковочное место. Проверьте правильность номера.',
      );
    }
  }

  Future<void> _deletePlace() async {
    if (_selectedPlaceId == null) {
      _showError('Пожалуйста, выберите место для удаления');
      return;
    }

    try {
      final token = await _storage.read(key: 'access_token');
      if (token == null) {
        _showError('Ошибка авторизации. Пожалуйста, войдите в систему заново.');
        return;
      }

      // Находим информацию о месте для отображения в диалоге
      final place = _places.firstWhere(
        (p) => p.id == _selectedPlaceId,
        orElse: () => ParkingPlace(id: 0, placeNumber: 0, parkingZoneId: 0),
      );

      if (place.id == 0) {
        _showError('Место не найдено');
        return;
      }

      // Показываем диалог подтверждения
      if (!mounted) return;

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
              'Вы действительно хотите удалить парковочное место №${place.placeNumber}?\n\n'
              'Это действие также удалит все разметки этого места на камерах.',
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            backgroundColor: Colors.white,
          );
        },
      );

      if (confirmed != true) return;

      await getIt<DeletePlaceUseCase>().execute(_selectedPlaceId!, token);
      await _loadPlaces();

      if (!mounted) return;

      setState(() {
        _placeNumberController.clear();
        _selectedPlaceId = _places.isNotEmpty ? _places.first.id : null;
        if (_selectedPlaceId != null) {
          _loadPlaceDetails(_selectedPlaceId!);
        }
      });
      _showSuccess('Парковочное место успешно удалено');
    } catch (e) {
      _showError(
        'Не удалось удалить парковочное место. Возможно, оно используется в системе.',
      );
    }
  }

  void _startMarking() {
    setState(() {
      _isMarking = true;
      _currentPoints = [];
      _showAllPlaces = false;
    });
  }

  void _finishMarking() {
    setState(() {
      _isMarking = false;
      _currentPoints = [];
    });
  }

  Future<void> _saveCoordinates() async {
    if (_isSavingCoordinates) return;

    if (_selectedCameraId == null ||
        _selectedPlaceId == null ||
        _currentPoints.length != 4) {
      _showError(
        'Пожалуйста, выберите камеру, парковочное место и отметьте ровно 4 точки.',
      );
      return;
    }

    setState(() {
      _isSavingCoordinates = true;
      _errorMessage = null;
    });

    try {
      final token = await _storage.read(key: 'access_token');
      if (token == null) {
        _showError('Ошибка авторизации. Пожалуйста, войдите в систему заново.');
        return;
      }

      // Проверяем, существует ли уже разметка для этого места на этой камере
      final existingPlace = _cameraPlaces.firstWhere(
        (cp) =>
            cp.parkingPlaceId == _selectedPlaceId &&
            cp.cameraId == _selectedCameraId,
        orElse:
            () => CameraParkingPlace(
              id: 0,
              cameraId: 0,
              parkingPlaceId: 0,
              location: [],
            ),
      );

      final points =
          _currentPoints.map((p) => [p.dx.round(), p.dy.round()]).toList();
      // Добавляем первую точку в конец для замыкания полигона
      points.add(points.first);

      final data = CameraParkingPlaceCreate(
        cameraId: _selectedCameraId!,
        parkingPlaceId: _selectedPlaceId!,
        location: points,
      );

      // Если место уже размечено, обновляем его
      if (existingPlace.id != 0) {
        await getIt<UpdateCameraParkingPlaceUseCase>().execute(
          existingPlace.id,
          data,
          token,
        );
      } else {
        // Если это новое место, создаем новую разметку
        await getIt<CreateCameraParkingPlaceUseCase>().execute(data, token);
      }

      await _loadCameraPlaces(_selectedCameraId!);

      if (!mounted) return;

      setState(() {
        _currentPoints = [];
        _editingCameraPlaceId = null;
      });
      _showSuccess('Координаты успешно сохранены');
    } catch (e) {
      if (mounted) {
        _showError(
          'Не удалось сохранить координаты. Попробуйте отметить точки снова.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSavingCoordinates = false;
        });
      }
    }
  }

  Future<void> _deleteCoordinates() async {
    if (_selectedCameraId == null || _selectedPlaceId == null) {
      _showError('Пожалуйста, выберите камеру и парковочное место');
      return;
    }

    try {
      final token = await _storage.read(key: 'access_token');
      if (token == null) {
        _showError('Ошибка авторизации. Пожалуйста, войдите в систему заново.');
        return;
      }

      // Проверяем существование разметки для выбранного места на текущей камере
      final existingPlace = _cameraPlaces.firstWhere(
        (cp) =>
            cp.parkingPlaceId == _selectedPlaceId &&
            cp.cameraId == _selectedCameraId,
        orElse:
            () => CameraParkingPlace(
              id: 0,
              cameraId: 0,
              parkingPlaceId: 0,
              location: [],
            ),
      );

      if (existingPlace.id == 0) {
        _showError('Для выбранного места нет разметки на текущей камере');
        return;
      }

      // Показываем диалог подтверждения
      if (!mounted) return;

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
              'Вы действительно хотите удалить разметку для места №${_places.firstWhere((p) => p.id == _selectedPlaceId, orElse: () => ParkingPlace(id: 0, placeNumber: 0, parkingZoneId: 0)).placeNumber}?',
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            backgroundColor: Colors.white,
          );
        },
      );

      if (confirmed != true) return;

      await getIt<DeleteCameraParkingPlaceUseCase>().execute(
        existingPlace.id,
        token,
      );

      await _loadCameraPlaces(_selectedCameraId!);

      if (!mounted) return;

      setState(() {
        _currentPoints = [];
        _editingCameraPlaceId = null;
      });

      _showSuccess('Координаты успешно удалены');
    } catch (e) {
      if (mounted) {
        _showError('Не удалось удалить координаты. Попробуйте еще раз.');
      }
    }
  }

  void _resetCoordinates() {
    setState(() {
      _currentPoints = [];
    });
  }

  void _showAllPlacesToggle() {
    setState(() {
      _showAllPlaces = !_showAllPlaces;
      _currentPoints = [];
    });
  }

  void _onTap(TapUpDetails details, Size widgetSize) {
    if (!_isMarking || _currentPoints.length >= 4 || _imageSize == null) return;

    final imageAspectRatio = _imageSize!.width / _imageSize!.height;
    final widgetAspectRatio = widgetSize.width / widgetSize.height;
    double scaleX, scaleY, offsetX, offsetY;

    if (imageAspectRatio > widgetAspectRatio) {
      scaleX = widgetSize.width / _imageSize!.width;
      scaleY = scaleX;
      offsetX = 0;
      offsetY = (widgetSize.height - _imageSize!.height * scaleY) / 2;
    } else {
      scaleY = widgetSize.height / _imageSize!.height;
      scaleX = scaleY;
      offsetX = (widgetSize.width - _imageSize!.width * scaleX) / 2;
      offsetY = 0;
    }

    final tapX = (details.localPosition.dx - offsetX) / scaleX;
    final tapY = (details.localPosition.dy - offsetY) / scaleY;

    if (tapX >= 0 &&
        tapX <= _imageSize!.width &&
        tapY >= 0 &&
        tapY <= _imageSize!.height) {
      setState(() {
        _currentPoints = [..._currentPoints, Offset(tapX, tapY)];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final placeNumberMap = {
      for (var place in _places) place.id: place.placeNumber.toString(),
    };
    return Scaffold(
      appBar: const Header(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 600),
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
                  margin: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(24.0),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Управление камерами',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF447BBA),
                                ),
                              ),
                              const SizedBox(height: 24),
                              TextField(
                                controller: _cameraNameController,
                                decoration: InputDecoration(
                                  labelText: 'Название камеры',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                  prefixIcon: const Icon(
                                    Icons.camera_alt,
                                    color: Color(0xFF447BBA),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF447BBA),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _cameraUrlController,
                                decoration: InputDecoration(
                                  labelText: 'URL камеры',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                  prefixIcon: const Icon(
                                    Icons.link,
                                    color: Color(0xFF447BBA),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF447BBA),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  ElevatedButton.icon(
                                    icon:
                                        _isSavingCamera
                                            ? SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(Colors.white),
                                              ),
                                            )
                                            : const Icon(Icons.add),
                                    label: Text(
                                      _isSavingCamera
                                          ? 'Добавление...'
                                          : 'Добавить камеру',
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF447BBA),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                    ),
                                    onPressed:
                                        _isSavingCamera ? null : _addCamera,
                                  ),
                                  const SizedBox(width: 12),
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.edit),
                                    label: const Text('Обновить'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF447BBA),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                    ),
                                    onPressed: _updateCamera,
                                  ),
                                  const SizedBox(width: 12),
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.delete),
                                    label: const Text('Удалить'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red[600],
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                    ),
                                    onPressed: _deleteCamera,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Управление парковочными местами',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF447BBA),
                                ),
                              ),
                              const SizedBox(height: 24),
                              TextField(
                                controller: _placeNumberController,
                                decoration: InputDecoration(
                                  labelText: 'Номер парковочного места',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                  prefixIcon: const Icon(
                                    Icons.local_parking,
                                    color: Color(0xFF447BBA),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF447BBA),
                                    ),
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  color: Colors.grey[50],
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<int>(
                                    value: _selectedPlaceId,
                                    hint: const Text(
                                      'Выберите парковочное место',
                                    ),
                                    isExpanded: true,
                                    icon: const Icon(
                                      Icons.arrow_drop_down,
                                      color: Color(0xFF447BBA),
                                    ),
                                    items:
                                        _places.map((place) {
                                          return DropdownMenuItem<int>(
                                            value: place.id,
                                            child: Text(
                                              'Место ${place.placeNumber}',
                                              style: const TextStyle(
                                                color: Color(0xFF447BBA),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedPlaceId = value;
                                        if (value != null) {
                                          _loadPlaceDetails(value);
                                          if (_selectedCameraId != null) {
                                            final cameraPlace = _cameraPlaces
                                                .firstWhere(
                                                  (cp) =>
                                                      cp.parkingPlaceId ==
                                                          value &&
                                                      cp.cameraId ==
                                                          _selectedCameraId,
                                                  orElse:
                                                      () => CameraParkingPlace(
                                                        id: 0,
                                                        cameraId: 0,
                                                        parkingPlaceId: 0,
                                                        location: [],
                                                      ),
                                                );
                                            _editingCameraPlaceId =
                                                cameraPlace.id != 0
                                                    ? cameraPlace.id
                                                    : null;
                                            _currentPoints =
                                                cameraPlace.id != 0
                                                    ? cameraPlace.location
                                                        .take(4)
                                                        .map(
                                                          (p) => Offset(
                                                            p[0].toDouble(),
                                                            p[1].toDouble(),
                                                          ),
                                                        )
                                                        .toList()
                                                    : [];
                                          } else {
                                            _editingCameraPlaceId = null;
                                            _currentPoints = [];
                                          }
                                        }
                                      });
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  ElevatedButton.icon(
                                    icon:
                                        _isSavingPlace
                                            ? SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(Colors.white),
                                              ),
                                            )
                                            : const Icon(Icons.add),
                                    label: Text(
                                      _isSavingPlace
                                          ? 'Сохранение...'
                                          : 'Сохранить место',
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF447BBA),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                    ),
                                    onPressed:
                                        _isSavingPlace ? null : _savePlace,
                                  ),
                                  const SizedBox(width: 12),
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.edit),
                                    label: const Text('Обновить'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF447BBA),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                    ),
                                    onPressed: _updatePlace,
                                  ),
                                  const SizedBox(width: 12),
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.delete),
                                    label: const Text('Удалить'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red[600],
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                    ),
                                    onPressed: _deletePlace,
                                  ),
                                ],
                              ),
                              if (_errorMessage != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 16),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.red[50],
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.red.shade200,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.error_outline,
                                          color: Colors.red[700],
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            _errorMessage!,
                                            style: TextStyle(
                                              color: Colors.red[700],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 4,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 800),
                  margin: const EdgeInsets.only(top: 16, right: 16, bottom: 16),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                                color: Colors.grey[50],
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  value: _selectedCameraId,
                                  hint: const Text('Выберите камеру'),
                                  isExpanded: true,
                                  icon: const Icon(
                                    Icons.arrow_drop_down,
                                    color: Color(0xFF447BBA),
                                  ),
                                  items:
                                      _cameras.map((camera) {
                                        return DropdownMenuItem<int>(
                                          value: camera.id,
                                          child: Text(
                                            camera.cameraName,
                                            style: const TextStyle(
                                              color: Color(0xFF447BBA),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                  onChanged: (value) async {
                                    if (value == null) return;
                                    setState(() {
                                      _selectedCameraId = value;
                                      _currentPoints = [];
                                      _editingCameraPlaceId = null;
                                      _showAllPlaces = false;
                                      _imageSize = null;
                                    });
                                    await _loadCameraDetails(value);
                                    await _loadCameraPlaces(value);
                                    await _loadSnapshots();
                                    setState(() {
                                      _updateSelectedSnapshot();
                                      if (_selectedSnapshot != null) {
                                        _loadImageSize();
                                      }
                                    });
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                ElevatedButton.icon(
                                  icon:
                                      _isLoadingSnapshots
                                          ? SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
                                            ),
                                          )
                                          : const Icon(Icons.refresh),
                                  label: Text(
                                    _isLoadingSnapshots
                                        ? 'Обновление...'
                                        : 'Обновить снимок',
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF447BBA),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                  ),
                                  onPressed:
                                      _isLoadingSnapshots
                                          ? null
                                          : _loadSnapshots,
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.edit_location),
                                  label: const Text('Начать разметку'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF447BBA),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                  ),
                                  onPressed: _startMarking,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.done),
                                  label: const Text('Завершить разметку'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF447BBA),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                  ),
                                  onPressed: _finishMarking,
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton.icon(
                                  icon: Icon(
                                    _showAllPlaces
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  label: Text(
                                    _showAllPlaces
                                        ? 'Скрыть все места'
                                        : 'Показать все места',
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF447BBA),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                  ),
                                  onPressed: _showAllPlacesToggle,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          child:
                              _selectedSnapshot != null && _imageSize != null
                                  ? LayoutBuilder(
                                    builder: (context, constraints) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                            width: 1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.1,
                                              ),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: GestureDetector(
                                            onTapUp:
                                                (details) => _onTap(
                                                  details,
                                                  Size(
                                                    constraints.maxWidth,
                                                    constraints.maxHeight,
                                                  ),
                                                ),
                                            child: Stack(
                                              children: [
                                                Positioned.fill(
                                                  child: Image.memory(
                                                    base64Decode(
                                                      _selectedSnapshot!
                                                          .imageBase64,
                                                    ),
                                                    fit: BoxFit.contain,
                                                    errorBuilder:
                                                        (
                                                          context,
                                                          error,
                                                          stackTrace,
                                                        ) => Center(
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Icon(
                                                                Icons
                                                                    .error_outline,
                                                                color:
                                                                    Colors
                                                                        .red[400],
                                                                size: 48,
                                                              ),
                                                              const SizedBox(
                                                                height: 16,
                                                              ),
                                                              const Text(
                                                                'Не удалось загрузить изображение',
                                                                style: TextStyle(
                                                                  color:
                                                                      Colors
                                                                          .grey,
                                                                  fontSize: 16,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                  ),
                                                ),
                                                CustomPaint(
                                                  size: Size(
                                                    constraints.maxWidth,
                                                    constraints.maxHeight,
                                                  ),
                                                  painter: CoordinatePainter(
                                                    points: _currentPoints,
                                                    cameraPlaces:
                                                        _showAllPlaces
                                                            ? _cameraPlaces
                                                            : (_selectedPlaceId !=
                                                                        null &&
                                                                    _editingCameraPlaceId !=
                                                                        null
                                                                ? _cameraPlaces
                                                                    .where(
                                                                      (cp) =>
                                                                          cp.parkingPlaceId ==
                                                                          _selectedPlaceId,
                                                                    )
                                                                    .toList()
                                                                : []),
                                                    imageSize: _imageSize!,
                                                    widgetSize: Size(
                                                      constraints.maxWidth,
                                                      constraints.maxHeight,
                                                    ),
                                                    selectedPlaceId:
                                                        _selectedPlaceId,
                                                    placeNumberMap:
                                                        placeNumberMap,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                  : Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.image_not_supported,
                                          color: Colors.grey[400],
                                          size: 48,
                                        ),
                                        const SizedBox(height: 16),
                                        const Text(
                                          'Снимок недоступен',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Выберите камеру и обновите снимок',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: Colors.grey.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    icon:
                                        _isSavingCoordinates
                                            ? SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(Colors.white),
                                              ),
                                            )
                                            : const Icon(Icons.save),
                                    label: Text(
                                      _editingCameraPlaceId != null
                                          ? 'Обновить координаты'
                                          : 'Сохранить координаты',
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF447BBA),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                    ),
                                    onPressed:
                                        _isMarking && !_isSavingCoordinates
                                            ? _saveCoordinates
                                            : null,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.delete),
                                    label: const Text('Удалить координаты'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red[600],
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                    ),
                                    onPressed:
                                        _isMarking ? _deleteCoordinates : null,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('Сбросить координаты'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF447BBA),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                    ),
                                    onPressed:
                                        _isMarking ? _resetCoordinates : null,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CoordinatePainter extends CustomPainter {
  final List<Offset> points;
  final List<CameraParkingPlace> cameraPlaces;
  final Size imageSize;
  final Size widgetSize;
  final int? selectedPlaceId;
  final Map<int, String> placeNumberMap;

  CoordinatePainter({
    required this.points,
    required this.cameraPlaces,
    required this.imageSize,
    required this.widgetSize,
    this.selectedPlaceId,
    required this.placeNumberMap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final defaultPaint =
        Paint()
          ..color = Colors.blue
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    final selectedPaint =
        Paint()
          ..color = Colors.green
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    final otherPlacesPaint =
        Paint()
          ..color = Colors.red
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    final pointPaint =
        Paint()
          ..color = Colors.blue
          ..style = PaintingStyle.fill;

    final circlePaintSelected =
        Paint()
          ..color = Colors.green
          ..style = PaintingStyle.fill;

    final circlePaintOther =
        Paint()
          ..color = Colors.red
          ..style = PaintingStyle.fill;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    final imageAspectRatio = imageSize.width / imageSize.height;
    final widgetAspectRatio = widgetSize.width / widgetSize.height;
    double scaleX, scaleY, offsetX, offsetY;

    if (imageAspectRatio > widgetAspectRatio) {
      scaleX = widgetSize.width / imageSize.width;
      scaleY = scaleX;
      offsetX = 0;
      offsetY = (widgetSize.height - imageSize.height * scaleY) / 2;
    } else {
      scaleY = widgetSize.height / imageSize.height;
      scaleX = scaleY;
      offsetX = (widgetSize.width - imageSize.width * scaleX) / 2;
      offsetY = 0;
    }

    if (points.isNotEmpty) {
      final path = Path();
      path.moveTo(
        points[0].dx * scaleX + offsetX,
        points[0].dy * scaleY + offsetY,
      );
      for (var point in points.skip(1)) {
        path.lineTo(point.dx * scaleX + offsetX, point.dy * scaleY + offsetY);
      }
      if (points.length == 4) {
        path.close();
      }
      canvas.drawPath(path, defaultPaint);

      for (var point in points) {
        canvas.drawCircle(
          Offset(point.dx * scaleX + offsetX, point.dy * scaleY + offsetY),
          4,
          pointPaint,
        );
      }
    }

    for (var cameraPlace in cameraPlaces) {
      final points =
          cameraPlace.location
              .take(4)
              .map(
                (p) => Offset(
                  p[0].toDouble() * scaleX + offsetX,
                  p[1].toDouble() * scaleY + offsetY,
                ),
              )
              .toList();
      if (points.isNotEmpty) {
        final path = Path();
        path.moveTo(points[0].dx, points[0].dy);
        for (var point in points.skip(1)) {
          path.lineTo(point.dx, point.dy);
        }
        path.close();
        canvas.drawPath(
          path,
          cameraPlace.parkingPlaceId == selectedPlaceId
              ? selectedPaint
              : otherPlacesPaint,
        );
        if (placeNumberMap.containsKey(cameraPlace.parkingPlaceId)) {
          double sumX = 0;
          double sumY = 0;
          for (var point in points) {
            sumX += point.dx;
            sumY += point.dy;
          }
          final centroid = Offset(sumX / 4, sumY / 4);
          canvas.drawCircle(
            centroid,
            18,
            cameraPlace.parkingPlaceId == selectedPlaceId
                ? circlePaintSelected
                : circlePaintOther,
          );

          textPainter.text = TextSpan(
            text: placeNumberMap[cameraPlace.parkingPlaceId],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          );
          textPainter.layout();
          textPainter.paint(
            canvas,
            Offset(
              centroid.dx - textPainter.width / 2,
              centroid.dy - textPainter.height / 2,
            ),
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CoordinatePainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.cameraPlaces != cameraPlaces ||
        oldDelegate.imageSize != imageSize ||
        oldDelegate.widgetSize != widgetSize ||
        oldDelegate.selectedPlaceId != selectedPlaceId;
  }
}
