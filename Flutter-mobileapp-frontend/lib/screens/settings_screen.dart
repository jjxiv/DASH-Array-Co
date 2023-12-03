import 'package:dash/components/large_button.dart';
import 'package:dash/screens/home_screen.dart';
import 'package:dash/screens/update_profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../repositories/authentication_repository.dart';
import '../repositories/user_repository.dart';
import '../components/navigation_bar.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final user = FirebaseAuth.instance.currentUser;
  String? email = FirebaseAuth.instance.currentUser?.email.toString();
  final _userRepo = Get.put(UserRepository());
  String name = '';

  // Runs getUserData() function at the start of the program
  @override
  void initState() {
    super.initState();
    getUserData();
  }

  // Gets the name of the user
  Future<void> getUserData() async {
    return _userRepo.getUserDetails(email!).then((userData) {
      setState(() {
        name = userData.fullName;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color.fromARGB(255, 16, 35, 65),
            ),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => Get.to(() => const HomeScreen(),
                  transition: Transition.leftToRight),
              child: const Center(
                child: Icon(
                  Icons.arrow_back_ios_rounded,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        centerTitle: false,
        backgroundColor: const Color.fromARGB(255, 14, 26, 50),
        elevation: 0,
        title: const Text("Settings"),
        titleSpacing: 10.0,
      ),
      body: Scaffold(
        backgroundColor: const Color.fromARGB(255, 14, 26, 50),
        body: SingleChildScrollView(
          child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 30.0),

                  // Profile Image
                  Stack(
                    children: [
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: const Image(
                            image:
                                AssetImage('assets/images/profile_image.jpg'),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Display Name
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  // Display Email
                  Text(
                    email.toString(),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                      width: 300,
                      child: LargeButton(
                          buttonText: 'Change User Settings',
                          onTap: () {
                            Get.to(() => const UpdateProfileScreen(),
                                transition: Transition.rightToLeft);
                          },
                          color: const Color.fromARGB(255, 0, 89, 231),
                          textcolor: Colors.white)),

                  const SizedBox(height: 30),

                  const Divider(),

                  const SizedBox(height: 10),

                  // Logout
                  SettingMenuWidget(
                    title: 'Logout',
                    icon: Icons.logout,
                    textColor: const Color.fromARGB(255, 245, 91, 127),
                    endIcon: false,
                    onPress: () {
                      AuthenticationRepository.instance.logout();
                    },
                  ),
                ],
              )),
        ),
      ),
      bottomNavigationBar: BottomNavigationBarWidget(
        initialTab: TabItem.Settings,
        onTabSelected: (tabItem) {
          // Handle the tab selection
          // You can update the state of your app or navigate to a different screen based on the selected tab
        },
      ),
    );
  }
}

class SettingMenuWidget extends StatelessWidget {
  const SettingMenuWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.onPress,
    required this.endIcon,
    required this.textColor,
  });

  final String title;
  final IconData icon;
  final VoidCallback onPress;
  final bool endIcon;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onPress,
      leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: const Color.fromARGB(255, 16, 35, 65),
          ),
          child: Icon(icon, color: const Color.fromARGB(255, 245, 91, 127))),
      title: Text(title,
          style:
              Theme.of(context).textTheme.bodyMedium?.apply(color: textColor)),
      trailing: endIcon
          ? Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: Colors.grey.withOpacity(0.1),
              ),
              child: const Icon(
                Icons.arrow_forward,
                size: 18,
                color: Colors.grey,
              ))
          : null,
    );
  }
}
