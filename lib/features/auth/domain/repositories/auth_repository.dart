import '../entities/organizer.dart';

/// Abstraction for organizer authentication flows.
/// Handles email/password, social logins, and account verification.
abstract class AuthRepository {
  /// Stream containing the current authenticated [Organizer].
  /// Yields `null` if the user is signed out or their session expires.
  Stream<Organizer?> watchAuthState();

  /// Create a new organizer account using email and password.
  ///
  /// Requires a valid [email], strong [password], and the organizer's [displayName].
  /// This will automatically log the user in if successful.
  Future<Organizer> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
    String role = 'organizer',
  });

  /// Authenticate an existing organizer using email and password.
  ///
  /// Throws exceptions for invalid credentials or disabled accounts.
  Future<Organizer> signInWithEmail({
    required String email,
    required String password,
  });

  /// Launch the Google Sign-In flow.
  ///
  /// Uses a native modal to prompt the user for their Google account.
  /// If the account does not exist in Firestore, an [Organizer] record is created.
  Future<Organizer?> signInWithGoogle({String role = 'organizer'});

  /// Sends a verification email to the currently logged in user.
  ///
  /// They must click the link in the email before `reloadUser()` will
  /// register `isEmailVerified` as true.
  Future<void> sendEmailVerification();

  /// Synchronous boolean flag checking if the current user has verified their email.
  bool get isEmailVerified;

  /// Refreshes the local Firebase Authentication user object.
  /// Must be called after a user verifies their email for the app to detect it.
  Future<void> reloadUser();

  /// Sends a password reset link to the provided [email] address.
  Future<void> sendPasswordResetEmail({required String email});

  /// Signs the user out locally and cleanly invalidates the session.
  Future<void> signOut();
}
