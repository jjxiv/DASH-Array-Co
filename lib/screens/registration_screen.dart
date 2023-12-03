import 'package:dash/components/large_button.dart';
import 'package:dash/controllers/registration_controller.dart';
import 'package:dash/models/user_model.dart';
import 'package:dash/repositories/user_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../components/error_alert.dart';
import '../components/userinfo_textfield.dart';
import 'login_screen.dart';

class RegistrationScreen extends StatelessWidget {
  RegistrationScreen({super.key});

  // Controllers
  final controller = Get.put(RegistrationController());
  final _formKey = GlobalKey<FormState>();
  final userRepo = Get.put(UserRepository());

  // Registration Firebase
  Future<void> registerUser(BuildContext context) async {
    try {
      // Loading Screen
      showDialog(
          context: context,
          builder: (context) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          });

      // Sign Up Firebase
      if (controller.password.text == controller.confirmpwd.text) {
        // Passes user information to controller
        final user = UserModel(
          email: controller.email.text.trim(),
          password: controller.password.text.trim(),
          fullName: controller.fullName.text.trim(),
        );

        await userRepo.createUser(user);
      } else {
        // Destroy Loading Screen
        Navigator.pop(context);

        // Error message, password does not match
        ErrorAlert.show(context, "Passwords do not match.");
      }
    } on FirebaseAuthException catch (e) {
      // Destroy Loading Screen
      Navigator.pop(context);

      // Checks if the email is already in use
      if (e.code == 'email-already-in-use') {
        ErrorAlert.show(context,
            'Email is already in use. Try logging in or use a different email.');
      } else if (e.code == 'weak-password') {
        ErrorAlert.show(
            context, 'Password must contain at least 6 characters.');
      } else if (e.code == 'invalid-email') {
        ErrorAlert.show(context, 'Please enter a valid email address.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 14, 26, 50),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 110.0),
                // Welcome Back Text
                const Text('Register Now',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 60,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -3,
                    )),

                const SizedBox(height: 16.0),

                // Full Name
                UserInfoTextField(
                    controller: controller.fullName,
                    hintText: 'Full Name',
                    textColor: Colors.white,
                    obscureText: false,
                    image: 'assets/icons/user.png'),

                const SizedBox(height: 10.0),

                // Email
                UserInfoTextField(
                    controller: controller.email,
                    hintText: 'Email',
                    textColor: Colors.white,
                    obscureText: false,
                    image: 'assets/icons/mail.png'),

                const SizedBox(height: 10.0),

                // Password
                UserInfoTextField(
                    controller: controller.password,
                    hintText: 'Password',
                    textColor: Colors.white,
                    obscureText: true,
                    image: 'assets/icons/padlock.png'),

                const SizedBox(height: 10.0),

                // Confirm Password
                UserInfoTextField(
                    controller: controller.confirmpwd,
                    hintText: 'Confirm Password',
                    textColor: Colors.white,
                    obscureText: true,
                    image: 'assets/icons/padlock.png'),

                const SizedBox(height: 40.0),

                // Sign Up Button
                LargeButton(
                    buttonText: 'Sign Up',
                    textcolor: Colors.white,
                    // Redirects to authentication
                    onTap: () {
                      // Checks if any textfields are empty
                      if (controller.fullName.text.isEmpty) {
                        ErrorAlert.show(
                            context, "Please enter your full name.");
                      } else if (controller.email.text.isEmpty) {
                        ErrorAlert.show(context, "Please enter your email.");
                      } else if (controller.password.text.isEmpty) {
                        ErrorAlert.show(context, "Please enter your password.");
                      } else if (controller.confirmpwd.text.isEmpty) {
                        ErrorAlert.show(
                            context, "Please enter your confirmed password.");
                      } else if (_formKey.currentState!.validate()) {
                        registerUser(context);
                      }
                    },
                    color: const Color.fromARGB(255, 0, 89, 231)),

                const SizedBox(height: 10.0),

                // Login Button
                TextButton(
                    style: ButtonStyle(
                        foregroundColor:
                            MaterialStateProperty.all(Colors.white)),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen()));
                    },
                    child: const Text("I already have an account"))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
