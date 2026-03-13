import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/event_member.dart';
import '../../domain/repositories/event_member_repository.dart';
import '../../data/repositories/event_member_repository_impl.dart';

final eventMemberRepositoryProvider = Provider<EventMemberRepository>((ref) {
  return EventMemberRepositoryImpl();
});

final watchEventMembersProvider =
    StreamProvider.family<List<EventMember>, String>((ref, eventId) {
  final repo = ref.watch(eventMemberRepositoryProvider);
  return repo.watchEventMembers(eventId);
});
