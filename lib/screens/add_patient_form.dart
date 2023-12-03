import 'dart:convert';
import 'package:dash/components/large_button.dart';
import 'package:dash/components/patient_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dash/providers/patientApi.dart';
import 'package:dash/screens/home_screen.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:io';

import '../components/confirmation_dialog.dart';

class AddPatientForm extends StatefulWidget {
  final File imageFile;
  const AddPatientForm({required this.imageFile, Key? key}) : super(key: key);

  @override
  State<AddPatientForm> createState() => _AddPatientFormState();
}

const int _contactMaxLength = 11;

class _AddPatientFormState extends State<AddPatientForm> {
  _AddPatientFormState() {
    DateTime now = DateTime.now();
    String date_time = DateFormat("MMMM d, yyyy HH:mm").format(now);
  }

  String get date_time {
    DateTime now = DateTime.now();
    return DateFormat("MMMM d, yyyy HH:mm").format(now);
  }

  String? email = FirebaseAuth.instance.currentUser?.email.toString();

  // Text Editing Controllers
  final _patientNameController = TextEditingController();
  final _patientContactController = TextEditingController();
  final _patientEmailController = TextEditingController();
  final _patientShadeController = TextEditingController();
  final _patientImageController = TextEditingController();
  final _patientNoteController = TextEditingController();

  // Validation
  bool _validateName = true;
  bool _validateContact = true;
  bool _validateEmail = true;
  bool _validateShade = true;
  bool _validateImage = true;
  bool _validateNote = true;

  @override
  void initState() {
    super.initState();
    _setInitialImageName();
  }

  void _setInitialImageName() {
    final imageName = path.basename(widget.imageFile.path);
    setState(() {
      _patientImageController.text = imageName;
      _patientShadeController.text = " ";
    });
  }

  Future<bool> checkPatientExists(String name) async {
    String? owner = FirebaseAuth.instance.currentUser?.email.toString();
    final url = 'http://192.168.0.18:5000/patient_exists/$name/$owner';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse['exists'];
    } else {
      throw Exception('Failed to fetch data');
    }
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
        title: const Text("Save Patient Details"),
        titleSpacing: 10.0,
      ),
      backgroundColor: const Color.fromARGB(255, 14, 26, 50),
      body: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: SingleChildScrollView(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Name
            PatientTextField(
              controller: _patientNameController,
              hintText: 'Enter Name',
              obscureText: false,
              textColor: Colors.white,
              image: 'assets/icons/user.png',
              numericalOnly: false,
              textLength: 40,
            ),

            // Contact Number
            PatientTextField(
              controller: _patientContactController,
              hintText: 'Enter Contact',
              obscureText: false,
              textColor: Colors.white,
              image: 'assets/icons/contact.png',
              numericalOnly: true,
              textLength: 11,
            ),

            // Email
            PatientTextField(
                controller: _patientEmailController,
                hintText: 'Enter Email',
                obscureText: false,
                textColor: Colors.white,
                image: 'assets/icons/mail.png',
                numericalOnly: false,
                textLength: 40),

            // Note
            PatientTextField(
                controller: _patientNoteController,
                hintText: 'Enter Note',
                obscureText: false,
                textColor: Colors.white,
                image: 'assets/icons/notes.png',
                numericalOnly: false,
                textLength: 40),

            const SizedBox(height: 24),

            // Save Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0),
              child: Row(
                children: [
                  Expanded(
                    child: LargeButton(
                      buttonText: 'Save Details',
                      color: const Color.fromARGB(255, 0, 89, 231),
                      textcolor: Colors.white,
                      onTap: () async {
                        setState(() {
                          _patientNameController.text.isEmpty
                              ? _validateName = true
                              : _validateName = false;
                          _patientContactController.text.isEmpty
                              ? _validateContact = true
                              : _validateContact = false;
                          _patientEmailController.text.isEmpty
                              ? _validateEmail = true
                              : _validateEmail = false;
                          _patientShadeController.text.isEmpty
                              ? _validateShade = true
                              : _validateShade = false;
                          _patientImageController.text.isEmpty
                              ? _validateImage = true
                              : _validateImage = false;
                          _patientNoteController.text.isEmpty
                              ? _validateNote = true
                              : _validateNote = false;
                        });

                        if (!_validateName &&
                            !_validateContact &&
                            !_validateEmail &&
                            !_validateShade &&
                            !_validateImage &&
                            !_validateNote) {
                          // Checks whether patient name already exists
                          if (await checkPatientExists(
                              _patientNameController.text)) {
                            // Shows warning that the patient name exists
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("Patient already exists!"),
                                  content: const Text(
                                      "Would you still like to save the new record?"),
                                  actions: <Widget>[
                                    // Save Button
                                    TextButton(
                                      child: const Text('Save',
                                          style: TextStyle(
                                              color: const Color.fromRGBO(
                                                  78, 44, 112, 1))),
                                      onPressed: () async {
                                        // Gets the result
                                        var result = await PatientApi()
                                            .addPatient(
                                                email!,
                                                _patientNameController.text,
                                                _patientContactController.text,
                                                _patientEmailController.text,
                                                _patientShadeController.text,
                                                _patientImageController.text,
                                                _patientNoteController.text,
                                                _AddPatientFormState()
                                                    .date_time);

                                        if (result != null) {
                                          await showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                scrollable:
                                                    false, // Set scrollable to false
                                                title: const Text("Success"),
                                                content: SingleChildScrollView(
                                                  child: Column(
                                                    children: [
                                                      // Success Image
                                                      Container(
                                                        height: 100,
                                                        child: Image.asset(
                                                            'assets/images/add_success.png'),
                                                      ),
                                                      const SizedBox(
                                                          height: 20),
                                                      Text(
                                                          "$result has been added successfully"),
                                                    ],
                                                  ),
                                                ),
                                                actions: <Widget>[
                                                  Center(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              10.0),
                                                      child: Container(
                                                        width: 200,
                                                        decoration:
                                                            BoxDecoration(
                                                          boxShadow: const [
                                                            BoxShadow(
                                                              color: Color
                                                                  .fromRGBO(
                                                                      78,
                                                                      44,
                                                                      112,
                                                                      0.5),
                                                              spreadRadius: 5,
                                                              blurRadius: 10,
                                                              offset:
                                                                  Offset(0, 3),
                                                            ),
                                                          ],
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(20),
                                                        ),
                                                        child:
                                                            GlowingOverscrollIndicator(
                                                          axisDirection:
                                                              AxisDirection
                                                                  .right,
                                                          color: const Color
                                                                  .fromRGBO(
                                                              78, 44, 112, 0.5),
                                                          child: ElevatedButton(
                                                            onPressed: () {
                                                              Get.to(() =>
                                                                  const HomeScreen());
                                                            },
                                                            style:
                                                                ElevatedButton
                                                                    .styleFrom(
                                                              backgroundColor:
                                                                  const Color
                                                                          .fromRGBO(
                                                                      78,
                                                                      44,
                                                                      112,
                                                                      1),
                                                              padding:
                                                                  const EdgeInsets
                                                                          .symmetric(
                                                                      vertical:
                                                                          16),
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20),
                                                              ),
                                                            ),
                                                            child: const Text(
                                                                'Go Back to Dashboard'),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        }

                                        Get.to(() => const HomeScreen());
                                      },
                                    ),

                                    // Cancel Button
                                    TextButton(
                                      child: const Text('Cancel',
                                          style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 245, 91, 127))),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            // Adds the patient if the name does not exist
                            var result = await PatientApi().addPatient(
                                email!,
                                _patientNameController.text,
                                _patientContactController.text,
                                _patientEmailController.text,
                                _patientShadeController.text,
                                _patientImageController.text,
                                _patientNoteController.text,
                                _AddPatientFormState().date_time);

                            if (result != null) {
                              await showConfirmationDialog(
                                  context,
                                  'Success!',
                                  [
                                    const Text(
                                        'The patient has been successfully added to your records.'),
                                  ],
                                  Icons.check, () {
                                Get.to(HomeScreen());
                              });
                            }
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Cancel Button
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 200,
                  child: OutlinedButton(
                    onPressed: () {
                      Get.to(() => const HomeScreen());
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      side: const BorderSide(
                          color: Color.fromARGB(255, 245, 91, 127)),
                    ),
                    child: const Text('Cancel',
                        style: TextStyle(
                            color: Color.fromARGB(255, 245, 91, 127))),
                  ),
                ),
              ],
            ),
          ],
        )),
      ),
    );
  }
}
