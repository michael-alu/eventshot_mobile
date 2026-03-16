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

  void setLastPhotoPath(String? path) {
    state = state.copyWith(lastPhotoPath: path);
  }
}

class AttendeeSession {
  const AttendeeSession({
    this.photosTaken = 16,
    this.photoLimit = 100,
    this.flashOn = false,
    this.lastPhotoPath,
  });

  final int photosTaken;
  final int photoLimit;
  final bool flashOn;
  final String? lastPhotoPath;

  int get photosRemaining => photoLimit - photosTaken;

  AttendeeSession copyWith({
    int? photosTaken,
    int? photoLimit,
    bool? flashOn,
    String? lastPhotoPath,
  }) {
    return AttendeeSession(
      photosTaken: photosTaken ?? this.photosTaken,
      photoLimit: photoLimit ?? this.photoLimit,
      flashOn: flashOn ?? this.flashOn,
      lastPhotoPath: lastPhotoPath ?? this.lastPhotoPath,
    );
  }
}

final attendeeSessionProvider =
    NotifierProvider<AttendeeSessionNotifier, AttendeeSession>(
      AttendeeSessionNotifier.new,
    );
