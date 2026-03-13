import '../../domain/entities/organizer.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_datasource.dart';
import '../datasources/organizer_remote_datasource.dart'; // file keeps original name
import '../models/organizer_model.dart';

/// Firebase-backed implementation of [AuthRepository].
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    FirebaseAuthDataSource? authDataSource,
    UserRemoteDataSource? userRemote,
  })  : _auth = authDataSource ?? FirebaseAuthDataSource(),
        _userRemote = userRemote ?? UserRemoteDataSource();

  final FirebaseAuthDataSource _auth;
  final UserRemoteDataSource _userRemote;

  @override
  Stream<Organizer?> watchAuthState() async* {
    await for (final user in _auth.authStateChanges) {
      if (user == null) {
        yield null;
        continue;
      }
      final profile = await _userRemote.getUser(user.uid);
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
    await _userRemote.setUser(model);
    // send verification email right after signup
    await _auth.sendEmailVerification();
    return model.toEntity();
  }

  @override
  Future<Organizer> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmail(email: email, password: password);
    final user = _auth.currentUser!;
    final profile = await _userRemote.getUser(user.uid);
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
  Future<void> sendEmailVerification() => _auth.sendEmailVerification();

  @override
  bool get isEmailVerified => _auth.isEmailVerified;

  @override
  Future<void> reloadUser() => _auth.reloadUser();

  @override
  Future<void> signOut() => _auth.signOut();
}
