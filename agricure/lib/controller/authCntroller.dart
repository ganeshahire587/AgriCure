import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();

  late Rx<User?> _user;
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Observable loading state
  RxBool isLoading = false.obs;

  @override
  void onReady() {
    super.onReady();
    _user = Rx<User?>(auth.currentUser);
    _user.bindStream(auth.userChanges());
    ever(_user, _initialScreen);
  }

  User? get currentUser => auth.currentUser;
  String get userId => auth.currentUser?.uid ?? '';
  String get userEmail => auth.currentUser?.email ?? '';
  String get userName => auth.currentUser?.displayName ?? '';
  String get userPhotoUrl => auth.currentUser?.photoURL ?? '';

  void _initialScreen(User? user) {
    if (user == null) {
      Get.offAllNamed('/login');
    } else {
      Get.offAllNamed('/garden');
    }
  }

  // ── Email & Password Login ─────────────────────────────────────────────────
  Future<void> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Помилка',
        'Будь ласка, введіть email та пароль',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    try {
      isLoading.value = true;
      await auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
    } on FirebaseAuthException catch (e) {
      String message = _mapAuthError(e.code);
      Get.snackbar(
        'Помилка входу',
        message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Помилка входу',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ── Email & Password Register ──────────────────────────────────────────────
  Future<void> register(String email, String password, String name) async {
    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      Get.snackbar(
        'Помилка',
        'Заповніть усі поля',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    try {
      isLoading.value = true;
      UserCredential cred = await auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      // Update display name
      await cred.user?.updateDisplayName(name.trim());

      // Save user profile to Firestore
      await _saveUserToFirestore(
        uid: cred.user!.uid,
        email: email.trim(),
        name: name.trim(),
        photoUrl: '',
      );
    } on FirebaseAuthException catch (e) {
      String message = _mapAuthError(e.code);
      Get.snackbar(
        'Помилка реєстрації',
        message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Помилка реєстрації',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ── Google Sign In ─────────────────────────────────────────────────────────
  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return; // User cancelled

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential cred = await auth.signInWithCredential(credential);

      // Save to Firestore if new user
      if (cred.additionalUserInfo?.isNewUser == true) {
        await _saveUserToFirestore(
          uid: cred.user!.uid,
          email: cred.user?.email ?? '',
          name: cred.user?.displayName ?? '',
          photoUrl: cred.user?.photoURL ?? '',
        );
      }
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        'Google Auth Error',
        e.message ?? e.code,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Google Auth Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ── Sign Out ───────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    try {
      await GoogleSignIn().signOut();
      await auth.signOut();
    } catch (e) {
      Get.snackbar(
        'Помилка',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ── Delete Account ─────────────────────────────────────────────────────────
  Future<bool> deleteAccount() async {
    try {
      isLoading.value = true;
      final uid = auth.currentUser?.uid;
      if (uid == null) return false;

      // Delete Firestore data
      await firestore.collection('users').doc(uid).delete();
      // Delete all user's plants
      final plants = await firestore
          .collection('plants')
          .where('userId', isEqualTo: uid)
          .get();
      for (var doc in plants.docs) {
        await doc.reference.delete();
      }
      // Delete tasks
      final tasks = await firestore
          .collection('tasks')
          .where('userId', isEqualTo: uid)
          .get();
      for (var doc in tasks.docs) {
        await doc.reference.delete();
      }

      // Delete Firebase Auth account
      await auth.currentUser?.delete();
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        Get.snackbar(
          'Потрібна повторна авторизація',
          'Будь ласка, увійдіть знову перед видаленням',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Помилка',
          e.message ?? e.code,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      return false;
    } catch (e) {
      Get.snackbar(
        'Помилка',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ── Save user profile to Firestore ────────────────────────────────────────
  Future<void> _saveUserToFirestore({
    required String uid,
    required String email,
    required String name,
    required String photoUrl,
  }) async {
    await firestore.collection('users').doc(uid).set({
      'uid': uid,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'accountType': 'Basic',
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // ── Map Firebase error codes to human-readable messages ───────────────────
  String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Користувача з таким email не знайдено';
      case 'wrong-password':
        return 'Невірний пароль';
      case 'email-already-in-use':
        return 'Цей email вже зареєстрований';
      case 'invalid-email':
        return 'Невірний формат email';
      case 'weak-password':
        return 'Пароль має бути не менше 6 символів';
      case 'network-request-failed':
        return 'Помилка мережі. Перевірте підключення';
      case 'too-many-requests':
        return 'Забагато спроб. Спробуйте пізніше';
      default:
        return 'Помилка: $code';
    }
  }
}
