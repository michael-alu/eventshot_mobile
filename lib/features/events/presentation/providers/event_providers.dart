import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/repositories/event_repository_impl.dart';
import '../../domain/entities/event.dart';
import '../../domain/repositories/event_repository.dart';

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return EventRepositoryImpl();
});

final currentEventIdProvider = StateProvider<String?>((ref) => null);

final eventStatsProvider = FutureProvider.family<Event?, String>((ref, eventId) async {
  final repo = ref.watch(eventRepositoryProvider);
  return repo.getEvent(eventId);
});

final watchEventProvider = StreamProvider.family<Event?, String>((ref, eventId) {
  final repo = ref.watch(eventRepositoryProvider);
  return repo.watchEvent(eventId);
});

/// Streams all events for the currently authenticated organizer.
final organizerEventsProvider = StreamProvider<List<Event>>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return const Stream.empty();
  final repo = ref.watch(eventRepositoryProvider);
  return repo.getOrganizerEvents(user.id);
});

