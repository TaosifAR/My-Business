import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  var isLoading = false.obs;
  late Rx<User?> firebaseUser;

  // Observable variables to store user data for the UI (Drawer)
  var userName = "".obs;
  var userEmail = "".obs;

  // 1. Add a flag to track the registration state and prevent auto-routing
  bool _isRegistering = false;

  @override
  void onReady() {
    super.onReady();
    firebaseUser = Rx<User?>(_auth.currentUser);
    firebaseUser.bindStream(_auth.authStateChanges());

    // Listen for auth state changes to route user and fetch data
    ever(firebaseUser, _setInitialScreen);
  }

  /// Routes the user based on login status and fetches data if logged in
  _setInitialScreen(User? user) {
    // 2. If the registration process is ongoing, this logic will not run.
    // This prevents the app from jumping to the Home screen during registration.
    if (_isRegistering) return;

    if (user == null) {
      userName.value = "";
      userEmail.value = "";
      Get.offAllNamed('/login');
    } else {
      // Fetch data from Firestore when user is detected
      fetchUserData(user.uid);
      Get.offAllNamed("/home");
    }
  }

  /// Fetches additional user details from Firestore collection 'users'
  Future<void> fetchUserData(String uid) async {
    try {
      DocumentSnapshot userDoc = await _db.collection('users').doc(uid).get();
      if (userDoc.exists) {
        userName.value = userDoc['name'] ?? "No Name";
        userEmail.value = userDoc['email'] ?? "No Email";
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  Future<void> register(String name, String email, String password) async {
    try {
      isLoading.value = true;

      // 3. Set the flag to true before starting the registration
      _isRegistering = true;

      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Save user data to Firestore
      await _db.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'name': name,
        'email': email,
        'createdAt': DateTime.now(),
      });

      Get.snackbar("Success", "User registered successfully");

      // 4. Sign out first, then reset the flag to false.
      // This ensures the listener doesn't see a "logged in" state for the Home screen.
      await _auth.signOut();
      _isRegistering = false;

      // 5. Manually navigate to the login screen
      Get.offAllNamed('/login');
    } catch (e) {
      // Reset the flag even if an error occurs to allow future login attempts
      _isRegistering = false;
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      Get.snackbar("Success", "Logged in successfully");
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } catch (e) {
      Get.snackbar("Error", "An unexpected error occurred");
    } finally {
      isLoading.value = false;
    }
  }

  void _handleAuthError(FirebaseAuthException e) {
    String message;
    switch (e.code) {
      case 'user-not-found':
        message = "No user found for that email.";
        break;
      case 'wrong-password':
        message = "Wrong password provided.";
        break;
      case 'email-already-in-use':
        message = "The email address is already in use.";
        break;
      case 'weak-password':
        message = "The password provided is too weak.";
        break;
      default:
        message = e.message ?? "Authentication failed.";
    }
    Get.snackbar("Error", message, snackPosition: SnackPosition.BOTTOM);
  }

  /// Sign out the user and clear observable data
  Future<void> logout() async {
    await _auth.signOut();
  }
}
