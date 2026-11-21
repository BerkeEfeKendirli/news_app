import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_ui/material_ui.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:news_app/screens/main_screen.dart';

class AuthService {
  static final Future<void> _googleInitialized = GoogleSignIn.instance
      .initialize();

  static Future<void> signOutGoogle() async {
    await _googleInitialized;
    await GoogleSignIn.instance.signOut();
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      await _googleInitialized;
      final GoogleSignInAccount googleUser = await GoogleSignIn.instance
          .authenticate();

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      if (!context.mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const NewsScreen()),
        (route) => false,
      );
    } catch (e) {
      // Handle error appropriately
      if (!context.mounted) return;
      if (e is GoogleSignInException &&
          e.code == GoogleSignInExceptionCode.canceled) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Google sign-in failed. Please try again.'),
        ),
      );
    }
  }
}
