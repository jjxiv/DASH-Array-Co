import 'package:dash/components/large_button.dart';
import 'package:dash/screens/registration_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../components/userinfo_textfield.dart';
import '../components/error_alert.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Text Controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // User Authentication
  void signUserIn() async {
    // Loading Screen
    showDialog(
        context: context,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        });

    // Sign In Firebase
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      // Destroy Loading Screen
      Navigator.pop(context);

      if (e.code == 'user-not-found') {
        // Invalid Email Message
        ErrorAlert.show(context, "Email not found. Register an account now.");
      } else if (e.code == 'wrong-password') {
        // Invalid Password
        ErrorAlert.show(context, "Incorrect Password");
      } else if (e.code == 'invalid-email') {
        // Invalid Password
        ErrorAlert.show(context, "Please enter a valid email.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 14, 26, 50),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Welcome Back Text
              const Text('Welcome Back',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 60,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -3,
                  )),

              const SizedBox(height: 16.0),

              // Email Field
              UserInfoTextField(
                  controller: emailController,
                  hintText: 'Email',
                  textColor: Colors.white,
                  obscureText: false,
                  image: 'assets/icons/mail.png'),

              // Password Field
              UserInfoTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  textColor: Colors.white,
                  obscureText: true,
                  image: 'assets/icons/padlock.png'),

              const SizedBox(height: 40.0),

              // Login Button
              LargeButton(
                  buttonText: 'Login',
                  onTap: () {
                    // Checks if all text fields are NOT empty
                    if (_formKey.currentState!.validate()) {
                      signUserIn();
                    }

                    if (emailController.text.isEmpty) {
                      ErrorAlert.show(context, "Please enter your email.");
                    } else if (passwordController.text.isEmpty) {
                      ErrorAlert.show(context, "Please enter your password.");
                    }
                  },
                  textcolor: Colors.white,
                  color: const Color.fromARGB(255, 0, 89, 231)),

              const SizedBox(height: 10.0),

              // Register Button
              TextButton(
                  style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all(Colors.white)),
                  onPressed: () {
                    Get.to(() => RegistrationScreen());
                  },
                  child: const Text("I don't have an account"))
            ],
          ),
        ),
      ),
    );
  }
}
