import 'package:dash/models/user_model.dart';
import 'package:dash/repositories/authentication_repository.dart';
import 'package:dash/repositories/user_repository.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  static ProfileController get instance => Get.find();

  final _authRepo = Get.put(AuthenticationRepository());
  final _userRepo = Get.put(UserRepository());

  // Get User Email and Pass to UserRepository to Fetch Record
  getUserData() {
    final email = _authRepo.firebaseUser.value?.email;
    if (email != null) {
      return _userRepo.getUserDetails(email);
    } else {
      Get.snackbar("Error", "Login to continue");
    }
  }

  // Update record
  updateRecord(UserModel user) async {
    await _userRepo.updateUserRecord(user);
  }

  // Reathenticate
  reauthenticateUser(UserModel user) async {
    await _userRepo.reauthenticateUser(user);
  }
}
