import '../entities/organizer.dart';

/// Abstraction for organizer auth (email, Google, Apple).
abstract class AuthRepository {
  Stream<Organizer?> watchAuthState();

  Future<Organizer> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  });

  Future<Organizer> signInWithEmail({
    required String email,
    required String password,
  });

  Future<Organizer?> signInWithGoogle();

  Future<Organizer?> signInWithApple();

  Future<void> signOut();
}
