import '../../domain/entities/organizer.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_datasource.dart';
import '../datasources/organizer_remote_datasource.dart';
import '../models/organizer_model.dart';

/// Firebase-backed implementation of [AuthRepository].
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    FirebaseAuthDataSource? authDataSource,
    OrganizerRemoteDataSource? organizerRemote,
  })  : _auth = authDataSource ?? FirebaseAuthDataSource(),
        _organizerRemote = organizerRemote ?? OrganizerRemoteDataSource();

  final FirebaseAuthDataSource _auth;
  final OrganizerRemoteDataSource _organizerRemote;

  @override
  Stream<Organizer?> watchAuthState() async* {
    await for (final user in _auth.authStateChanges) {
      if (user == null) {
        yield null;
        continue;
      }
      final profile = await _organizerRemote.getOrganizer(user.uid);
      if (profile != null) {
        yield profile.toEntity();
      } else {
        yield Organizer(
          id: user.uid,
          email: user.email ?? '',
          displayName: user.displayName ?? '',
        );
      }
    }
  }

  @override
  Future<Organizer> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final cred = await _auth.signUpWithEmail(email: email, password: password);
    final user = cred.user!;
    await user.updateDisplayName(displayName);
    final model = OrganizerModel(
      id: user.uid,
      email: email,
      displayName: displayName,
      createdAt: DateTime.now(),
    );
    await _organizerRemote.setOrganizer(model);
    return model.toEntity();
  }

  @override
  Future<Organizer> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmail(email: email, password: password);
    final user = _auth.currentUser!;
    final profile = await _organizerRemote.getOrganizer(user.uid);
    if (profile != null) return profile.toEntity();
    return Organizer(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? '',
    );
  }

  @override
  Future<Organizer?> signInWithGoogle() async {
    // TODO: implement with google_sign_in + Firebase signInWithCredential
    return null;
  }

  @override
  Future<Organizer?> signInWithApple() async {
    // TODO: implement with sign_in_with_apple + Firebase signInWithCredential
    return null;
  }

  @override
  Future<void> signOut() => _auth.signOut();
}
