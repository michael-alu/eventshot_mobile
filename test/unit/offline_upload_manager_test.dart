import 'dart:io';
import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';
import 'package:eventshot_mobile/core/services/offline_upload_manager.dart';
import 'package:eventshot_mobile/features/attendee/data/repositories/attendee_repository.dart';
import 'package:eventshot_mobile/core/providers/preferences_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'offline_upload_manager_test.mocks.dart';

@GenerateMocks([AttendeeRepository])
class FakeConnectivity extends ConnectivityPlatform {
  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => [ConnectivityResult.wifi];
  
  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged => Stream.value([ConnectivityResult.wifi]);
}

class FakePathProvider extends PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async => '.';
}

void main() {
  late MockAttendeeRepository mockRepo;
  late FakeConnectivity fakeConnectivity;
  late FakePathProvider fakePath;

  setUp(() async {
    mockRepo = MockAttendeeRepository();
    fakeConnectivity = FakeConnectivity();
    fakePath = FakePathProvider();

    ConnectivityPlatform.instance = fakeConnectivity;
    PathProviderPlatform.instance = fakePath;
    SharedPreferences.setMockInitialValues({});
  });

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        attendeeRepositoryProvider.overrideWithValue(mockRepo),
        wifiSyncModeProvider.overrideWith((ref) => false),
      ],
    );
  }

  test('Enqueue adds job to state and triggers sync', () async {
    final container = createContainer();
    final manager = container.read(offlineUploadManagerProvider.notifier);

    final file = File('test_upload.jpg');
    await file.writeAsString('test content');

    when(mockRepo.executeOfflineUpload(any, any)).thenAnswer((_) async => {});

    await manager.enqueue('event123', file);
    
    // Wait for the async _syncQueue (which is not awaited in enqueue)
    await untilCalled(mockRepo.executeOfflineUpload('event123', any));
    
    verify(mockRepo.executeOfflineUpload('event123', any)).called(1);
    expect(container.read(offlineUploadManagerProvider), isEmpty);
    if (await file.exists()) await file.delete();
  });
}
