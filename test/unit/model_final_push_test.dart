import 'package:eventshot_mobile/features/event_members/data/models/event_member_model.dart';
import 'package:eventshot_mobile/features/photos/data/models/photo_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('EventMemberModel Coverage', () {
    final now = DateTime.now();
    final m = EventMemberModel(id: '1', eventId: '1', attendeeName: 'A', joinedAt: now, isActive: true);
    expect(EventMemberModel.fromJson(m.toJson()).id, '1');
    expect(m.toEntity().id, '1');
  });

  test('PhotoModel Dense Coverage', () {
    final now = DateTime.now();
    final m = PhotoModel(
      id: '1',
      eventId: '1',
      uploaderId: '1',
      uploaderName: 'U',
      firestoreUrl: 'F',
      storagePath: 'S',
      uploadedAt: now,
    );
    expect(PhotoModel.fromJson(m.toJson()).id, '1');
    expect(m.toEntity().id, '1');
  });
}
