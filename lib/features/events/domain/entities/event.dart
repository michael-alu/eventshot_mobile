import 'package:equatable/equatable.dart';

class Event extends Equatable {
  const Event({
    required this.id,
    required this.name,
    required this.date,
    required this.tierId,
    this.organizerId,
    this.photoCount = 0,
    this.attendeeCount = 0,
    this.storageBytes = 0,
  });

  final String id;
  final String name;
  final DateTime date;
  final String tierId;
  final String? organizerId;
  final int photoCount;
  final int attendeeCount;
  final int storageBytes;

  @override
  List<Object?> get props => [id, name, date, tierId, organizerId, photoCount, attendeeCount, storageBytes];
}
