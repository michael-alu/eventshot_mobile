import 'package:eventshot_mobile/features/auth/data/datasources/firebase_auth_datasource.dart';
import 'package:eventshot_mobile/features/auth/data/datasources/organizer_remote_datasource.dart';
import 'package:eventshot_mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:eventshot_mobile/features/auth/data/models/organizer_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../mocks/firebase_mock.dart';

import 'auth_repository_impl_test.mocks.dart';

class FakeUserCredential extends Fake implements UserCredential {
  final User? _user;
  FakeUserCredential({User? user}) : _user = user;
  @override
  User? get user => _user;
}

@GenerateMocks([FirebaseAuthDataSource, UserRemoteDataSource])
void main() {
  late MockFirebaseAuthDataSource mockAuthDataSource;
  late MockUserRemoteDataSource mockUserRemote;
  late AuthRepositoryImpl authRepo;

  setUp(() async {
    setupFirebaseMocks();
    await Firebase.initializeApp();
    mockAuthDataSource = MockFirebaseAuthDataSource();
    mockUserRemote = MockUserRemoteDataSource();
    authRepo = AuthRepositoryImpl(
      authDataSource: mockAuthDataSource,
      userRemote: mockUserRemote,
    );
    SharedPreferences.setMockInitialValues({});
  });

  group('AuthRepositoryImpl', () {
    test('watchAuthState streams Organizer when logged in', () async {
      final mockUser = MockUser(uid: '123', email: 'test@test.com');
      when(mockAuthDataSource.authStateChanges).thenAnswer((_) => Stream.value(mockUser));
      when(mockUserRemote.getUser('123')).thenAnswer((_) async => OrganizerModel(
        id: '123',
        email: 'test@test.com',
        displayName: 'Test User',
        role: 'organizer',
        createdAt: DateTime.now(),
      ));

      final result = await authRepo.watchAuthState().first;
      expect(result?.id, '123');
    });

    test('signInWithEmail calls data source and returns organizer', () async {
       final mockUser = MockUser(uid: '123', email: 'test@test.com');
       when(mockAuthDataSource.signInWithEmail(email: 'test@test.com', password: 'password'))
           .thenAnswer((_) async => FakeUserCredential(user: mockUser));
       when(mockAuthDataSource.currentUser).thenReturn(mockUser);
       when(mockUserRemote.getUser('123')).thenAnswer((_) async => OrganizerModel(
        id: '123',
        email: 'test@test.com',
        displayName: 'Test User',
        role: 'organizer',
        createdAt: DateTime.now(),
      ));

      final result = await authRepo.signInWithEmail(email: 'test@test.com', password: 'password');
      expect(result.id, '123');
    });

    test('signUpWithEmail calls data source and returns user', () async {
       final mockUser = MockUser(uid: '456', email: 'signup@test.com');
       when(mockAuthDataSource.signUpWithEmail(email: 'signup@test.com', password: 'password'))
           .thenAnswer((_) async => FakeUserCredential(user: mockUser));
       when(mockAuthDataSource.currentUser).thenReturn(mockUser);
       when(mockUserRemote.getUser('456')).thenAnswer((_) async => OrganizerModel(
        id: '456',
        email: 'signup@test.com',
        displayName: 'New User',
        role: 'organizer',
        createdAt: DateTime.now(),
      ));

      final result = await authRepo.signUpWithEmail(email: 'signup@test.com', password: 'password', displayName: 'New User');
      expect(result.id, '456');
    });

    test('watchAuthState returns null if no user', () async {
      when(mockAuthDataSource.authStateChanges).thenAnswer((_) => Stream.value(null));
      final result = await authRepo.watchAuthState().first;
      expect(result, isNull);
    });

    test('signOut coverage', () async {
      when(mockAuthDataSource.signOut()).thenAnswer((_) async => {});
      await authRepo.signOut();
      verify(mockAuthDataSource.signOut()).called(1);
    });
  });
}
