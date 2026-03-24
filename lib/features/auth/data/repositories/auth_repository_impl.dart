import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../domain/entities/organizer.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_datasource.dart';
import '../datasources/organizer_remote_datasource.dart';
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
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return null; // user cancelled

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final cred =
        await FirebaseAuth.instance.signInWithCredential(credential);
    final user = cred.user;
    if (user == null) return null;
    var profile = await _userRemote.getUser(user.uid);
    if (profile == null) {
      profile = OrganizerModel(
        id: user.uid,
        email: user.email ?? '',
        displayName: user.displayName ?? '',
        createdAt: DateTime.now(),
      );
      await _userRemote.setUser(profile);
    }
    return profile.toEntity();
  }

  @override
  Future<void> sendEmailVerification() => _auth.sendEmailVerification();

  @override
  bool get isEmailVerified => _auth.isEmailVerified;

  @override
  Future<void> reloadUser() => _auth.reloadUser();

  @override
  Future<void> sendPasswordResetEmail({required String email}) =>
      _auth.sendPasswordResetEmail(email: email);

  @override
  Future<void> signOut() => _auth.signOut();
}
