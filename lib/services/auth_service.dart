import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;
  static final _googleSignIn = GoogleSignIn();
  static final _db = FirebaseFirestore.instance;

  static User? get currentUser => _auth.currentUser;
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  static Future<UserCredential> signInWithEmail(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email, password: password);

  static Future<UserCredential> registerWithEmail(String email, String password) =>
      _auth.createUserWithEmailAndPassword(email: email, password: password);

  static Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  static Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email);

  static Future<void> updateDisplayName(String name) =>
      _auth.currentUser!.updateDisplayName(name);

  static Future<void> sendEmailVerification() =>
      _auth.currentUser!.sendEmailVerification();

  static Future<void> reloadUser() => _auth.currentUser!.reload();

  static Future<void> updatePhotoURL(String url) =>
      _auth.currentUser!.updatePhotoURL(url);

  static Future<UserCredential> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) throw Exception('cancelled');
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return _auth.signInWithCredential(credential);
  }

  static bool get isGoogleUser =>
      _auth.currentUser?.providerData.any((p) => p.providerId == 'google.com') ?? false;

  static bool get isAppleUser =>
      _auth.currentUser?.providerData.any((p) => p.providerId == 'apple.com') ?? false;

  static Future<UserCredential> signInWithApple() async {
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );
    final oauthCredential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );
    final result = await _auth.signInWithCredential(oauthCredential);
    // Apple only returns name on first sign-in; persist it if available
    final fullName = [appleCredential.givenName, appleCredential.familyName]
        .where((s) => s != null && s.isNotEmpty)
        .join(' ');
    if (fullName.isNotEmpty && (result.user?.displayName == null || result.user!.displayName!.isEmpty)) {
      await result.user?.updateDisplayName(fullName);
    }
    return result;
  }

  /// 계정 삭제: 재인증 후 Firestore 데이터 및 Firebase Auth 계정 삭제
  /// Google 계정은 [password] 불필요, 이메일 계정은 필수
  static Future<void> deleteAccount({String? password}) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('no-user');

    // 재인증
    if (isAppleUser) {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
      );
      final cred = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );
      await user.reauthenticateWithCredential(cred);
    } else if (isGoogleUser) {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw Exception('cancelled');
      final googleAuth = await googleUser.authentication;
      final cred = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await user.reauthenticateWithCredential(cred);
    } else {
      if (password == null || password.isEmpty) throw Exception('password-required');
      final cred = EmailAuthProvider.credential(email: user.email!, password: password);
      await user.reauthenticateWithCredential(cred);
    }

    final uid = user.uid;

    // Firestore 데이터 삭제 (실패해도 Auth 삭제는 진행)
    try {
      await _deleteSubcollection('users/$uid/bookmarks');
      await _deleteSubcollection('users/$uid/follows');
      await _deleteSubcollection('users/$uid/fcmTokens');
      await _db.collection('users').doc(uid).delete();
    } catch (_) {}

    try {
      final reviews = await _db.collection('reviews').where('userId', isEqualTo: uid).get();
      final batch = _db.batch();
      for (final doc in reviews.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (_) {}

    // Firebase Auth 계정 삭제 (핵심)
    await user.delete();
    await _googleSignIn.signOut();
  }

  static Future<void> _deleteSubcollection(String path) async {
    final parts = path.split('/');
    CollectionReference col;
    if (parts.length == 3) {
      col = _db.collection(parts[0]).doc(parts[1]).collection(parts[2]);
    } else {
      return;
    }
    QuerySnapshot snap;
    do {
      snap = await col.limit(100).get();
      if (snap.docs.isEmpty) break;
      final batch = _db.batch();
      for (final doc in snap.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } while (snap.docs.length == 100);
  }
}
