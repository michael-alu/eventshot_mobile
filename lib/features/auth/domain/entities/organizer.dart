import 'package:equatable/equatable.dart';

/// Organizer user entity.
class Organizer extends Equatable {
  const Organizer({
    required this.id,
    required this.email,
    required this.displayName,
    this.plan,
    this.createdAt,
    this.role,
    this.joinedEvents,
  });

  final String id;
  final String email;
  final String displayName;
  final String? plan;
  final DateTime? createdAt;
  final String? role;
  final List<String>? joinedEvents;

  @override
  List<Object?> get props => [id, email, displayName, plan, createdAt, role, joinedEvents];
}
