import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash/components/error_alert.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../models/user_model.dart';

class UserRepository extends GetxController {
  static UserRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;

  // Stores user in Firestore
  createUser(UserModel user) async {
    UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: user.email,
      password: user.password,
    );

    // Retrieve UID
    String uid = userCredential.user!.uid;

    await _db
        .collection("Users")
        .doc(uid)
        .set(user.toJson())
        .whenComplete(() => const ErrorAlert(errorMessage: 'Success!'))
        .catchError((error, stackTrace) {
      () => const ErrorAlert(errorMessage: 'Error!');
      print(error.toString());
    });
  }

  // Fetches Firestore data
  Future<UserModel> getUserDetails(String email) async {
    final snapshot =
        await _db.collection("Users").where("Email", isEqualTo: email).get();

    if (snapshot.docs.isEmpty) {
      // Display loading screen while waiting for data
      await Future.delayed(const Duration(seconds: 5));
      return Future.error(
          'No user found'); // Return an error to indicate no user found
    }

    final userData = snapshot.docs.map((e) => UserModel.fromSnapshot(e)).single;
    return userData;
  }

  // Updates Firebase data
  Future<void> updateUserRecord(UserModel user) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      // Update user data in Firebase Authentication
      await currentUser.updateEmail(user.email);
      await currentUser.updatePassword(user.password);
    } else {
      throw Exception('User not logged in.');
    }

    await _db.collection("Users").doc(currentUser.uid).update(user.toJson());
  }

  // Reauthentication method
// Reauthentication method
  Future<void> reauthenticateUser(UserModel user) async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email,
        password: user.password,
      );

      await currentUser.reauthenticateWithCredential(credential);
    } else {
      // User is not logged in or does not exist
      print('User is not logged in or does not exist');
    }
  }
}
