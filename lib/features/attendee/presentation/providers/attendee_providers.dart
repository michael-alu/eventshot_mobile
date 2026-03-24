import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tracks how many photos the attendee has taken in the current session.
class AttendeeSessionNotifier extends Notifier<AttendeeSession> {
  @override
  AttendeeSession build() => const AttendeeSession();

  void incrementPhotoCount() {
    if (state.photosTaken < state.photoLimit) {
      state = state.copyWith(photosTaken: state.photosTaken + 1);
    }
  }

  void setFlash(bool on) {
    state = state.copyWith(flashOn: on);
  }

  void setEvent(String id, String name) {
    state = state.copyWith(eventId: id, eventName: name);
  }

  void setLastPhotoPath(String? path) {
    state = state.copyWith(lastPhotoPath: path);
  }

  void setPhotosTaken(int count) {
    state = state.copyWith(photosTaken: count);
  }
}

class AttendeeSession {
  const AttendeeSession({
    this.photosTaken = 0,
    this.photoLimit = 50,
    this.flashOn = false,
    this.lastPhotoPath,
    this.eventId,
    this.eventName,
  });

  final int photosTaken;
  final int photoLimit;
  final bool flashOn;
  final String? lastPhotoPath;
  final String? eventId;
  final String? eventName;

  int get photosRemaining => photoLimit - photosTaken;

  AttendeeSession copyWith({
    int? photosTaken,
    int? photoLimit,
    bool? flashOn,
    String? lastPhotoPath,
    String? eventId,
    String? eventName,
  }) {
    return AttendeeSession(
      photosTaken: photosTaken ?? this.photosTaken,
      photoLimit: photoLimit ?? this.photoLimit,
      flashOn: flashOn ?? this.flashOn,
      lastPhotoPath: lastPhotoPath ?? this.lastPhotoPath,
      eventId: eventId ?? this.eventId,
      eventName: eventName ?? this.eventName,
    );
  }
}

final attendeeSessionProvider =
    NotifierProvider<AttendeeSessionNotifier, AttendeeSession>(
      AttendeeSessionNotifier.new,
    );
