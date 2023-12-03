import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart';
import 'registration_screen.dart';

// Components
import '../components/large_button.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 14, 26, 50),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Image
            Image.asset(
              'assets/images/logo.png',
              height: 250,
              fit: BoxFit.cover,
              alignment: Alignment.centerLeft,
            ),

            // Logo Text
            Text(
              'DASH',
              style: GoogleFonts.oswald(
                  textStyle: const TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              )),
            ),

            // Dash Expanded
            const Text('Dental Assistance in Shade Matching',
                style: TextStyle(
                  color: Colors.white,
                )),

            const SizedBox(height: 16.0),

            // Get Started (Registration)
            LargeButton(
              textcolor: Colors.white,
              onTap: () {
                Get.to(() => RegistrationScreen());
              },
              buttonText: 'Get Started',
              color: const Color.fromARGB(255, 0, 89, 231),
            ),

            // Login
            TextButton(
                style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all(Colors.black)),
                onPressed: () {
                  Get.to(() => const LoginScreen());
                },
                child: const Text("I already have an account",
                    style: TextStyle(color: Colors.white)))
          ],
        ),
      ),
    );
  }
}
