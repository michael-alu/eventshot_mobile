import 'package:eventshot_mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:eventshot_mobile/features/auth/data/models/organizer_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
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

void main() {
  late MockFirebaseAuthDataSource mockAuthDS;
  late MockUserRemoteDataSource mockUserRemote;
  late AuthRepositoryImpl authRepo;

  setUp(() async {
    setupFirebaseMocks();
    try {
      await Firebase.initializeApp();
    } catch (_) {
      // Already initialized in another test — safe to continue.
    }
    SharedPreferences.setMockInitialValues({});
    mockAuthDS = MockFirebaseAuthDataSource();
    mockUserRemote = MockUserRemoteDataSource();
    authRepo = AuthRepositoryImpl(
      authDataSource: mockAuthDS,
      userRemote: mockUserRemote,
    );
  });

  group('AuthRepositoryImpl - extra coverage', () {
    test('sendEmailVerification delegates to data source', () async {
      when(mockAuthDS.sendEmailVerification()).thenAnswer((_) async {});
      await authRepo.sendEmailVerification();
      verify(mockAuthDS.sendEmailVerification()).called(1);
    });

    test('isEmailVerified returns value from data source', () {
      when(mockAuthDS.isEmailVerified).thenReturn(true);
      expect(authRepo.isEmailVerified, isTrue);

      when(mockAuthDS.isEmailVerified).thenReturn(false);
      expect(authRepo.isEmailVerified, isFalse);
    });

    test('reloadUser delegates to data source', () async {
      when(mockAuthDS.reloadUser()).thenAnswer((_) async {});
      await authRepo.reloadUser();
      verify(mockAuthDS.reloadUser()).called(1);
    });

    test('sendPasswordResetEmail delegates to data source', () async {
      when(mockAuthDS.sendPasswordResetEmail(email: 'a@b.com')).thenAnswer((_) async {});
      await authRepo.sendPasswordResetEmail(email: 'a@b.com');
      verify(mockAuthDS.sendPasswordResetEmail(email: 'a@b.com')).called(1);
    });

    test('watchAuthState yields anonymous Organizer when profile not found', () async {
      final mockUser = MockUser(uid: 'anon123', email: 'anon@test.com', displayName: 'Anon');
      when(mockAuthDS.authStateChanges).thenAnswer((_) => Stream.value(mockUser));
      when(mockUserRemote.getUser('anon123')).thenAnswer((_) async => null);

      final result = await authRepo.watchAuthState().first;
      expect(result?.id, 'anon123');
      expect(result?.email, 'anon@test.com');
    });

    test('signInWithEmail returns anonymous Organizer when profile not found', () async {
      final mockUser = MockUser(uid: 'u99', email: 'noProfile@test.com');
      when(mockAuthDS.signInWithEmail(email: 'noProfile@test.com', password: 'pass'))
          .thenAnswer((_) async => FakeUserCredential(user: mockUser));
      when(mockAuthDS.currentUser).thenReturn(mockUser);
      when(mockUserRemote.getUser('u99')).thenAnswer((_) async => null);

      final result = await authRepo.signInWithEmail(
        email: 'noProfile@test.com',
        password: 'pass',
      );
      expect(result.id, 'u99');
    });

    test('signOut delegates to data source', () async {
      when(mockAuthDS.signOut()).thenAnswer((_) async {});
      await authRepo.signOut();
      verify(mockAuthDS.signOut()).called(1);
    });

    test('watchAuthState handles multiple stream events', () async {
      final mockUser1 = MockUser(uid: 'u1', email: 'one@test.com');
      final mockUser2 = MockUser(uid: 'u2', email: 'two@test.com');
      when(mockAuthDS.authStateChanges)
          .thenAnswer((_) => Stream.fromIterable([mockUser1, null, mockUser2]));
      when(mockUserRemote.getUser('u1')).thenAnswer((_) async => null);
      when(mockUserRemote.getUser('u2')).thenAnswer((_) async => null);

      final results = await authRepo.watchAuthState().take(3).toList();
      expect(results[0]?.id, 'u1');
      expect(results[1], isNull);
      expect(results[2]?.id, 'u2');
    });

    test('watchAuthState yields null when no user', () async {
      when(mockAuthDS.authStateChanges).thenAnswer((_) => Stream.value(null));
      final result = await authRepo.watchAuthState().first;
      expect(result, isNull);
    });

    test('watchAuthState yields Organizer from profile', () async {
      final mockUser = MockUser(uid: 'p1', email: 'profile@test.com');
      when(mockAuthDS.authStateChanges).thenAnswer((_) => Stream.value(mockUser));
      when(mockUserRemote.getUser('p1')).thenAnswer((_) async => OrganizerModel(
            id: 'p1',
            email: 'profile@test.com',
            displayName: 'Profile User',
            role: 'organizer',
            createdAt: DateTime.now(),
          ));

      final result = await authRepo.watchAuthState().first;
      expect(result?.displayName, 'Profile User');
    });
  });
}
