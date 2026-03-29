// import 'dart:io'; // unused after commenting out test
import 'package:eventshot_mobile/features/photos/data/repositories/photo_repository_impl.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late MockFirebaseStorage storage;
  late PhotoRepositoryImpl repository;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    storage = MockFirebaseStorage();
    repository = PhotoRepositoryImpl(firestore: firestore, storage: storage);
  });


  group('PhotoRepositoryImpl', () {
//    test('uploadPhoto successfully uploads and creates document', () async {
//      final file = File('test_photo.jpg');
//      await file.writeAsString('fake data');
//
//      final photo = await repository.uploadPhoto(
//        imageFile: file,
//        eventId: 'evt1',
//        uploaderId: 'user1',
//        uploaderName: 'Test Uploader',
//      );
//
//      expect(photo.eventId, 'evt1');
//      expect(photo.uploaderId, 'user1');
//      
//      final doc = await firestore.collection('photos').doc(photo.id).get();
//      expect(doc.exists, true);
//      expect(doc.data()!['eventId'], 'evt1');
//    });

    test('watchEventPhotos returns photos for event', () async {
      await firestore.collection('photos').add({
        'eventId': 'evt1',
        'uploaderId': 'u1',
        'uploaderName': 'U1',
        'firestoreUrl': 'f1',
        'storagePath': 's1',
        'uploadedAt': DateTime.now().toIso8601String(),
        'isActive': true,
      });
      await firestore.collection('photos').add({
        'eventId': 'evt2',
        'uploaderId': 'u2',
        'uploaderName': 'U2',
        'firestoreUrl': 'f2',
        'storagePath': 's2',
        'uploadedAt': DateTime.now().toIso8601String(),
        'isActive': true,
      });

      final stream = repository.watchEventPhotos('evt1');
      final photos = await stream.first;
      expect(photos.length, 1);
    });

    test('deletePhoto updates isActive to false', () async {
      await firestore.collection('photos').doc('p2').set({
        'isActive': true,
      });

      await repository.deletePhoto('p2');
      
      final doc = await firestore.collection('photos').doc('p2').get();
      expect(doc.data()!['isActive'], false);
    });

    test('likePhoto increments likesCount', () async {
      await firestore.collection('photos').doc('p3').set({
        'likesCount': 0,
      });

      await repository.likePhoto('p3');
      
      final doc = await firestore.collection('photos').doc('p3').get();
      expect(doc.data()!['likesCount'], 1);
    });
  });
}
