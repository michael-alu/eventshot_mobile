import 'package:eventshot_mobile/features/attendee/presentation/providers/attendee_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AttendeeSessionNotifier', () {
    test('initial state is default', () {
      final container = ProviderContainer();
      final state = container.read(attendeeSessionProvider);
      
      expect(state.photosTaken, 0);
      expect(state.photoLimit, 50);
      expect(state.flashOn, false);
      expect(state.photosRemaining, 50);
    });

    test('incrementPhotoCount increases photosTaken up to limit', () {
      final container = ProviderContainer();
      final notifier = container.read(attendeeSessionProvider.notifier);
      
      notifier.incrementPhotoCount();
      expect(container.read(attendeeSessionProvider).photosTaken, 1);
      
      // Reach limit
      notifier.setPhotosTaken(49);
      notifier.incrementPhotoCount();
      expect(container.read(attendeeSessionProvider).photosTaken, 50);
      
      // Should not exceed limit
      notifier.incrementPhotoCount();
      expect(container.read(attendeeSessionProvider).photosTaken, 50);
    });

    test('setFlash updates flash state', () {
      final container = ProviderContainer();
      final notifier = container.read(attendeeSessionProvider.notifier);
      
      notifier.setFlash(true);
      expect(container.read(attendeeSessionProvider).flashOn, true);
    });

    test('setEvent updates event data', () {
      final container = ProviderContainer();
      final notifier = container.read(attendeeSessionProvider.notifier);
      
      notifier.setEvent('id123', 'Event Name');
      expect(container.read(attendeeSessionProvider).eventId, 'id123');
      expect(container.read(attendeeSessionProvider).eventName, 'Event Name');
    });

    test('copyWith works correctly', () {
      const session = AttendeeSession(photosTaken: 5);
      final updated = session.copyWith(photoLimit: 100);
      
      expect(updated.photosTaken, 5);
      expect(updated.photoLimit, 100);
    });
  });
}
