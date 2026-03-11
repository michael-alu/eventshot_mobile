import 'package:equatable/equatable.dart';

/// Organizer user entity.
class Organizer extends Equatable {
  const Organizer({
    required this.id,
    required this.email,
    required this.displayName,
    this.plan,
    this.createdAt,
  });

  final String id;
  final String email;
  final String displayName;
  final String? plan;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [id, email, displayName, plan, createdAt];
}
