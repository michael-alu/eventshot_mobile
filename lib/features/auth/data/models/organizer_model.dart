import '../../domain/entities/organizer.dart';

/// Firestore DTO for Organizer.
class OrganizerModel {
  const OrganizerModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.role = 'organizer',
    this.plan,
    this.createdAt,
  });

  final String id;
  final String email;
  final String displayName;
  final String role;
  final String? plan;
  final DateTime? createdAt;

  factory OrganizerModel.fromJson(Map<String, dynamic> json) {
    return OrganizerModel(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: (json['name'] ?? json['displayName'] ?? '') as String,
      role: (json['role'] ?? 'organizer') as String,
      plan: json['plan'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': displayName,
      'role': role,
      if (plan != null) 'plan': plan,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }

  Organizer toEntity() {
    return Organizer(
      id: id,
      email: email,
      displayName: displayName,
      plan: plan,
      createdAt: createdAt,
    );
  }

  static OrganizerModel fromEntity(Organizer e) {
    return OrganizerModel(
      id: e.id,
      email: e.email,
      displayName: e.displayName,
      plan: e.plan,
      createdAt: e.createdAt,
    );
  }
}
