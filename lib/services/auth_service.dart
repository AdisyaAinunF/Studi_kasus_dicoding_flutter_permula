import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
// import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<UserCredential> registerEmail(String email, String password) {
    return _auth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  Future<UserCredential> signInEmail(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      // 1️⃣ Trigger Google Sign-In dialog
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        // User menutup dialog
        return null;
      }

      // 2️⃣ Ambil detail auth dari akun Google
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 3️⃣ Buat credential untuk Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4️⃣ Login ke Firebase dengan credential Google
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print("Google sign-in error: $e");
      rethrow;
    }
  }
}
