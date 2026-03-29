import 'package:eventshot_mobile/features/auth/data/datasources/firebase_auth_datasource.dart';
import 'package:eventshot_mobile/features/auth/data/datasources/organizer_remote_datasource.dart';
import 'package:eventshot_mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:eventshot_mobile/features/auth/data/models/organizer_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import 'auth_flow_booster_test.mocks.dart';

@GenerateMocks([FirebaseAuthDataSource, UserRemoteDataSource, fb.User, fb.UserCredential])
void main() {
  late MockFirebaseAuthDataSource mockAuthDS;
  late MockUserRemoteDataSource mockUserRemote;
  late AuthRepositoryImpl authRepo;

  setUp(() {
    mockAuthDS = MockFirebaseAuthDataSource();
    mockUserRemote = MockUserRemoteDataSource();
    authRepo = AuthRepositoryImpl(
      authDataSource: mockAuthDS,
      userRemote: mockUserRemote,
    );
  });

  group('AuthRepositoryImpl Dense Logic', () {
    test('watchAuthState merges stream and profile', () async {
      final mockUser = MockUser();
      when(mockUser.uid).thenReturn('u1');
      when(mockAuthDS.authStateChanges).thenAnswer((_) => Stream.value(mockUser));
      
      final profile = OrganizerModel(id: 'u1', email: 'e', displayName: 'd', role: 'r', createdAt: DateTime.now());
      when(mockUserRemote.getUser('u1')).thenAnswer((_) async => profile);

      final result = await authRepo.watchAuthState().first;
      expect(result?.id, 'u1');
    });

    test('signInWithEmail returns entity', () async {
      final mockUser = MockUser();
      when(mockUser.uid).thenReturn('u1');
      when(mockUser.email).thenReturn('e');
      when(mockUser.displayName).thenReturn('d');
      
      when(mockAuthDS.signInWithEmail(email: 'e', password: 'p')).thenAnswer((_) async => MockUserCredential());
      when(mockAuthDS.currentUser).thenReturn(mockUser);
      when(mockUserRemote.getUser('u1')).thenAnswer((_) async => null);

      final result = await authRepo.signInWithEmail(email: 'e', password: 'p');
      expect(result.id, 'u1');
    });
  });
}
