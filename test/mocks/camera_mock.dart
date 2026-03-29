import 'dart:async';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockCameraPlatform extends Mock 
    with MockPlatformInterfaceMixin 
    implements CameraPlatform {
  
  final _onCameraInitializedController = StreamController<CameraInitializedEvent>.broadcast();

  void triggerCameraInitialized(int cameraId) {
    _onCameraInitializedController.add(CameraInitializedEvent(
      cameraId,
      1280.0,
      720.0,
      ExposureMode.auto,
      true,
      FocusMode.auto,
      true,
    ));
  }
  @override
  Future<List<CameraDescription>> availableCameras() async {
    return [
      const CameraDescription(
        name: 'back',
        lensDirection: CameraLensDirection.back,
        sensorOrientation: 0,
      ),
    ];
  }

  @override
  Future<int> createCamera(
    CameraDescription description,
    ResolutionPreset? resolutionPreset, {
    bool enableAudio = false,
  }) async {
    return 1;
  }

  @override
  Future<int> createCameraWithSettings(
    CameraDescription description,
    MediaSettings? mediaSettings,
  ) async {
    return 1;
  }

  @override
  Future<void> initializeCamera(
    int cameraId, {
    ImageFormatGroup imageFormatGroup = ImageFormatGroup.unknown,
  }) async {
    triggerCameraInitialized(cameraId);
  }

  @override
  Future<void> dispose(int cameraId) async {}

  @override
  Stream<CameraInitializedEvent> onCameraInitialized(int cameraId) {
    return _onCameraInitializedController.stream;
  }

  @override
  Stream<CameraResolutionChangedEvent> onCameraResolutionChanged(int cameraId) {
    return const Stream.empty();
  }

  @override
  Stream<CameraClosingEvent> onCameraClosing(int cameraId) {
    return const Stream.empty();
  }

  @override
  Stream<CameraErrorEvent> onCameraError(int cameraId) {
    return const Stream.empty();
  }

  @override
  Stream<VideoRecordedEvent> onVideoRecordedEvent(int cameraId) {
    return const Stream.empty();
  }

  @override
  Stream<DeviceOrientationChangedEvent> onDeviceOrientationChanged() {
    return const Stream.empty();
  }

  @override
  Stream<CameraImageData> onStreamedFrameAvailable(
    int cameraId, {
    CameraImageStreamOptions? options,
  }) {
    return const Stream.empty();
  }

  @override
  Future<void> setFlashMode(int cameraId, FlashMode mode) async {}
  
  @override
  Future<XFile> takePicture(int cameraId) async {
    return XFile('test_photo.jpg');
  }
}
