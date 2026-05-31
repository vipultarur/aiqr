import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:aiqr_app/core/utils/app_logger.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// 1. Reactive stream for state management (Listen via GetX / Riverpod)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// 2. Email & Password Registration
  Future<UserCredential?> registerWithEmail(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Optional: send email verification
      await credential.user?.sendEmailVerification();
      return credential;
    } on FirebaseAuthException catch (e) {
      AppLogger.error('Registration failed: ${e.code}', e);
      rethrow;
    }
  }

  /// 3. Email & Password Login
  Future<UserCredential?> loginWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      AppLogger.error('Login failed: ${e.code}', e);
      rethrow;
    }
  }

  /// 4. Google Sign-In (Federated Auth)
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null; // The user canceled the sign-in
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      AppLogger.error('Google Sign-In failed: $e', e);
      rethrow;
    }
  }

  /// 5. Password Reset
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      AppLogger.error('Password reset failed: ${e.code}', e);
      rethrow;
    }
  }

  /// 6. Logout
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      AppLogger.error('SignOut failed: $e', e);
      rethrow;
    }
  }
}
