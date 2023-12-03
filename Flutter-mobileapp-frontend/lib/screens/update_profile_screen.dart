import 'dart:async';
import 'package:dash/components/error_alert.dart';
import 'package:dash/controllers/profile_controller.dart';
import 'package:dash/models/user_model.dart';
import 'package:dash/screens/home_screen.dart';
import 'package:dash/screens/settings_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../components/large_button.dart';
import '../components/login_dialog.dart';
import '../components/userinfo_textfield.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({Key? key}) : super(key: key);

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  // Text Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmpwdController = TextEditingController();
  final controller = Get.put(ProfileController());
  final _formKey = GlobalKey<FormState>();
  bool isEditingName = false;
  String updatedName = '';
  String updatedPassword = '';

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
              onTap: () => Get.to(() => const SettingScreen(),
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
      backgroundColor: const Color.fromARGB(255, 14, 26, 50),
      body: SingleChildScrollView(
        child: FutureBuilder(
            future: controller.getUserData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                UserModel user = snapshot.data as UserModel;
                if (snapshot.hasData) {
                  if (updatedName.isEmpty) {
                    updatedName = user.fullName;
                  }

                  return Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 30.0),

                        // Profile Image
                        Stack(
                          children: [
                            SizedBox(
                              width: 150,
                              height: 150,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: const Image(
                                  image: AssetImage(
                                      'assets/images/profile_image.jpg'),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                  width: 35,
                                  height: 35,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    color:
                                        const Color.fromRGBO(62, 171, 244, 1),
                                  ),
                                  child: const Icon(
                                    Icons.edit,
                                    size: 20,
                                    color: Colors.white,
                                  )),
                            )
                          ],
                        ),

                        const SizedBox(height: 30.0),

                        // Full Name Text Field
                        Row(
                          children: [
                            Expanded(
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Visibility(
                                    visible: isEditingName,
                                    child: UserInfoTextField(
                                        controller: nameController,
                                        hintText: updatedName,
                                        textColor: Colors.white,
                                        obscureText: false,
                                        image: 'assets/icons/user.png'),
                                  ),
                                  Visibility(
                                    visible: !isEditingName,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0, vertical: 20.0),
                                      child: Container(
                                        alignment: Alignment.centerLeft,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 25.0),
                                          child: Text(
                                            "Displayed Name: $updatedName",
                                            textAlign: TextAlign.start,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Button on the right to edit
                            Padding(
                              padding: const EdgeInsets.only(right: 18.0),
                              child: IconButton(
                                onPressed: () {
                                  setState(() {
                                    if (isEditingName) {
                                      // Update updatedName if in edit mode
                                      updatedName = nameController.text.trim();
                                    }
                                    isEditingName = !isEditingName;
                                  });
                                },
                                icon: Icon(
                                    isEditingName ? Icons.check : Icons.edit,
                                    color:
                                        const Color.fromRGBO(62, 171, 244, 1)),
                              ),
                            ),
                          ],
                        ),

                        // Password
                        UserInfoTextField(
                            controller: passwordController,
                            hintText: 'New Password',
                            textColor: Colors.white,
                            obscureText: true,
                            image: 'assets/icons/padlock.png'),

                        // Confirm Password
                        UserInfoTextField(
                            controller: confirmpwdController,
                            hintText: 'Confirm New Password',
                            textColor: Colors.white,
                            obscureText: true,
                            image: 'assets/icons/padlock.png'),

                        const SizedBox(height: 40.0),

                        // Update Profile Button
                        LargeButton(
                          buttonText: 'Update User Information',
                          textcolor: Colors.white,
                          onTap: () async {
                            try {
                              if (_formKey.currentState!.validate()) {
                                if (passwordController.text.isEmpty) {
                                  // Show confirmation dialog for not updating password
                                  bool confirmed = await showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Confirmation'),
                                      content: const Text(
                                          'Do you want to update without changing the password?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            // User declined to update without changing password
                                            Navigator.of(context).pop(false);
                                          },
                                          child: const Text(
                                            'No',
                                            style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 0, 89, 231)),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            // User confirmed to update without changing password
                                            Navigator.of(context).pop(true);
                                            updatedPassword = user.password;
                                          },
                                          child: const Text(
                                            'Yes',
                                            style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 0, 89, 231)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (!confirmed) {
                                    return; // User declined to update without changing password
                                  }
                                } else {
                                  updatedPassword =
                                      passwordController.text.trim();
                                }

                                // Continue with the update process
                                final userData = UserModel(
                                  email: user.email,
                                  password: updatedPassword,
                                  fullName: updatedName,
                                );

                                if (updatedPassword.length < 6) {
                                  ErrorAlert.show(context,
                                      "Password must be at least 6 characters");
                                } else if (confirmpwdController.text ==
                                    passwordController.text) {
                                  // Login Dialog pops up after press, authentication
                                  Completer<bool> completer = Completer<bool>();
                                  showDialog(
                                    context: context,
                                    builder: (context) =>
                                        LoginDialog(completer: completer),
                                  );

                                  bool isConfirmed = await completer.future;
                                  if (isConfirmed) {
                                    await controller.updateRecord(userData);
                                  } else {
                                    ErrorAlert.show(
                                        context, "Incorrect login details.");
                                  }
                                } else {
                                  ErrorAlert.show(
                                      context, 'Passwords do not match.');
                                }
                              } else {
                                if (nameController.text.isEmpty) {
                                  ErrorAlert.show(
                                      context, "Full name cannot be empty.");
                                }
                              }
                            } on FirebaseAuthException catch (e) {
                              if (e.code == 'weak-password') {
                                ErrorAlert.show(context,
                                    'New password must contain at least 6 characters.');
                              } else if (e.code == 'requires-recent-login') {
                                controller.reauthenticateUser(user);
                              } else {
                                ErrorAlert.show(context, e.code);
                              }
                            }
                          },
                          color: const Color.fromARGB(255, 0, 89, 231),
                        ),
                      ],
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
            }),
      ),
    );
  }
}
