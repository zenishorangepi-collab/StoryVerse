import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:utsav_interview/routes/app_routes.dart';

class AuthOptionsController extends GetxController {
  Future<void> signInAsGuest() async {
    try {
      final userCredential = await FirebaseAuth.instance.signInAnonymously();

      final user = userCredential.user;

      if (user != null) {
        print('Guest UID: ${user.uid}');
        // Navigate to Home
        Get.offAllNamed(AppRoutes.tabBarScreen);
      }
    } catch (e) {
      print('Guest login failed: $e');
    }
  }
}

class AuthService {
  final _googleSignIn = GoogleSignIn.instance;
  bool _isGoogleSignInInitialized = false;

  AuthService() {
    _initializeGoogleSignIn();
  }

  Future<void> _initializeGoogleSignIn() async {
    try {
      await _googleSignIn.initialize();
      _isGoogleSignInInitialized = true;
    } catch (e) {
      print('Failed to initialize Google Sign-In: $e');
    }
  }

  /// Always check Google sign in initialization before use
  Future<void> _ensureGoogleSignInInitialized() async {
    if (!_isGoogleSignInInitialized) {
      await _initializeGoogleSignIn();
    }
  }

  // Future<GoogleSignInAccount> signInWithGoogle() async {
  //   await _ensureGoogleSignInInitialized();
  //
  //   try {
  //     // authenticate() throws exceptions instead of returning null
  //     final GoogleSignInAccount account = await _googleSignIn.authenticate(
  //       scopeHint: ['email'], // Specify required scopes
  //     );
  //     return account;
  //   } on GoogleSignInException catch (e) {
  //     print('Google Sign In error: code: ${e.code.name} description:${e.description} details:${e.details}, error: e');
  //     rethrow;
  //   } catch (error) {
  //     print('Unexpected Google Sign-In error: $error');
  //     rethrow;
  //   }
  // }

  // Future<GoogleSignInAccount?> attemptSilentSignIn() async {
  //   await _ensureGoogleSignInInitialized();
  //
  //   try {
  //     // attemptLightweightAuthentication can return Future or immediate result
  //     final result = _googleSignIn.attemptLightweightAuthentication();
  //
  //     // Handle both sync and async returns
  //     if (result is Future<GoogleSignInAccount?>) {
  //       return await result;
  //     } else {
  //       return result as GoogleSignInAccount?;
  //     }
  //   } catch (error) {
  //     print('Silent sign-in failed: $error');
  //     return null;
  //   }
  // }

  GoogleSignInAuthentication getAuthTokens(GoogleSignInAccount account) {
    // authentication is now synchronous
    return account.authentication;
  }

  Future<String?> getAccessTokenForScopes(List<String> scopes) async {
    await _ensureGoogleSignInInitialized();

    try {
      final authClient = _googleSignIn.authorizationClient;

      // Try to get existing authorization
      var authorization = await authClient.authorizationForScopes(scopes);

      authorization ??= await authClient.authorizeScopes(scopes);

      return authorization.accessToken;
    } catch (error) {
      print('Failed to get access token for scopes: $error');
      return null;
    }
  }

  GoogleSignInAccount? _currentUser;

  GoogleSignInAccount? get currentUser => _currentUser;

  bool get isSignedIn => _currentUser != null;

  // Future<void> signIn() async {
  //   try {
  //     _currentUser = await signInWithGoogle();
  //     // Manually notify listeners or update state
  //   } catch (error) {
  //     _currentUser = null;
  //     rethrow;
  //   }
  // }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _currentUser = null;
  }

  Future<UserCredential> signInWithGoogleFirebase() async {
    await _ensureGoogleSignInInitialized();

    // Authenticate with Google
    final GoogleSignInAccount googleUser = await _googleSignIn.authenticate(scopeHint: ['email']);

    // Get authorization for Firebase scopes if needed
    final authClient = _googleSignIn.authorizationClient;
    final authorization = await authClient.authorizationForScopes(['email']);

    final credential = GoogleAuthProvider.credential(accessToken: authorization?.accessToken, idToken: googleUser.authentication.idToken);

    final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

    // Update local state
    _currentUser = googleUser;

    return userCredential;
  }
}
