import 'package:dash/components/home_card.dart';
import 'package:dash/screens/database_screen.dart';
import 'package:dash/screens/image_acquisition.dart';
import 'package:dash/screens/database_note_screen.dart';
import 'package:dash/screens/settings_screen.dart';
import 'package:dash/screens/test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import '../models/user_model.dart';
import '../components/navigation_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final controller = Get.put(ProfileController());
  final user = FirebaseAuth.instance.currentUser;
  String? email = FirebaseAuth.instance.currentUser?.email.toString();
  String name = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: controller.getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            UserModel user = snapshot.data as UserModel;
            name = user.fullName;
            if (snapshot.hasData) {
              return Scaffold(
                backgroundColor: const Color.fromARGB(255, 14, 26, 50),
                body: ListView(
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      // Header
                      Center(
                        child: Container(
                          height: 200,
                          width: MediaQuery.of(context).size.width,
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 0, 89, 231),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(50.0),
                              bottomRight: Radius.circular(50.0),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment
                                  .center, // Center elements vertically
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Welcome Back
                                const Text(
                                  "Welcome Back,",
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),

                                // Name
                                Text(
                                  "$name!",
                                  style: const TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 12.0),
                        child: Row(
                          children: [
                            // Take Picture
                            HomeCard(
                              buttonText: 'Shade Match',
                              imagePath: 'assets/images/dashboard_camera.png',
                              onPressed: () {
                                Get.to(() => const Test(),
                                    transition: Transition.rightToLeft);
                              },
                            ),

                            const SizedBox(width: 15),

                            // View Records
                            HomeCard(
                              buttonText: 'Patient Records',
                              imagePath: 'assets/images/dashboard_records.png',
                              onPressed: () {
                                Get.to(() => const DatabaseScreen(),
                                    transition: Transition.rightToLeft);
                              },
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 12.0),
                        child: Row(
                          children: [
                            // Notes
                            HomeCard(
                              buttonText: 'Notes',
                              imagePath: 'assets/images/dashboard_notes.png',
                              onPressed: () {
                                Get.to(() => const DatabaseNoteScreen(),
                                    transition: Transition.rightToLeft);
                              },
                            ),

                            const SizedBox(width: 15),

                            // Settings
                            HomeCard(
                              buttonText: 'Settings',
                              imagePath: 'assets/images/dashboard_settings.png',
                              onPressed: () {
                                Get.to(() => const SettingScreen(),
                                    transition: Transition.rightToLeft);
                              },
                            ),
                          ],
                        ),
                      ),
                    ]),

                // Bottom Navigation Bar
                bottomNavigationBar: BottomNavigationBarWidget(
                  initialTab: TabItem.Home,
                  onTabSelected: (tabItem) {
                    // Handle the tab selection
                    // You can update the state of your app or navigate to a different screen based on the selected tab
                  },
                ),
              );
            } else if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            } else {
              return const Center(child: Text("Something went wrong."));
            }
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
