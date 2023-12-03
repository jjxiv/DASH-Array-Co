import 'package:dash/repositories/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegistrationController extends GetxController {
  static RegistrationController get instance => Get.find();

  // TextField Controllers
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmpwd = TextEditingController();
  final fullName = TextEditingController();

  // Registers the user
  void registerUser(String email, String password) {
    AuthenticationRepository.instance
        .createUserWithEmailAndPassword(email, password);
  }
}
