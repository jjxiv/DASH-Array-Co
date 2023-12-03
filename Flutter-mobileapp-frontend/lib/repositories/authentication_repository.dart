import 'package:dash/screens/home_screen.dart';
import 'package:dash/screens/splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:dash/components/error_alert.dart';
import 'package:dash/repositories/exceptions/authentication_exceptions.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();

  // Variables
  final _auth = FirebaseAuth.instance;
  late final Rx<User?> firebaseUser;

  @override
  void onReady() async {
    firebaseUser = Rx<User?>(_auth.currentUser);

    // Listens to any changes in terms of account
    firebaseUser.bindStream(_auth.userChanges());
    ever(firebaseUser, _setInitialScreen);
  }

  // Sets the screen depending if user is logged in
  _setInitialScreen(User? user) {
    user == null
        ? Get.offAll(() => const SplashScreen())
        : Get.offAll(() => const HomeScreen());
  }

  // Creates new user in Firebase
  Future<void> createUserWithEmailAndPassword(
      String email, String password) async {
    await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  // Logs In Firebase
  Future<void> loginUserWithEmailAndPassword(
      String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      // Checks whether the user has successfully signed in
      firebaseUser.value != null
          ? Get.offAll(() => const HomeScreen())
          : Get.to(() => const SplashScreen());
    } on FirebaseAuthException catch (e) {
      final ex = SignUpWithEmailandPasswordFailure.code(e.code);
      ErrorAlert.show(context as BuildContext, ex as String);
      throw ex;
    }
  }

  // Logs Out Firebase
  Future<void> logout() async => await _auth.signOut();
}
