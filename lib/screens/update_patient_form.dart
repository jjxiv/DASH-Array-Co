import 'package:dash/components/confirmation_dialog.dart';
import 'package:dash/components/large_button.dart';
import 'package:dash/components/patient_textfield.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:dash/providers/patientApi.dart';
import 'package:dash/models/patient.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class updatePatientForm extends StatefulWidget {
  final Patient patient;
  const updatePatientForm(this.patient, {Key? key}) : super(key: key);

  @override
  State<updatePatientForm> createState() => _updatePatientFormState();
}

const int _contactMaxLength = 11;

class _updatePatientFormState extends State<updatePatientForm> {
  var _patientNameController = TextEditingController();
  var _patientContactController = TextEditingController();
  var _patientEmailController = TextEditingController();
  var _patientShadeController = TextEditingController();
  var _patientImageController = TextEditingController();
  var _patientNoteController = TextEditingController();

  bool _validateName = false;
  bool _validateContact = false;
  bool _validateEmail = false;
  bool _validateImage = false;
  bool _validateNote = false;
  final _numberInputFormatter =
      FilteringTextInputFormatter.allow(RegExp(r'[0-9]'));
  final _maxLengthInputFormatter =
      LengthLimitingTextInputFormatter(_contactMaxLength);

  final List<String> _shadeOptions = ['A1', 'A2', 'A3', 'A3.5', 'A4'];
  String _selectedShade = '';

  @override
  void initState() {
    _patientNameController.text = widget.patient.name;
    _patientContactController.text = widget.patient.contact;
    _patientEmailController.text = widget.patient.email;
    _patientImageController.text = widget.patient.image;
    _patientNoteController.text = widget.patient.note;
    _selectedShade = widget.patient.shade;
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
              onTap: () {
                Get.back();
              },
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
        title: const Text("Update Patient"),
        titleSpacing: 10.0,
      ),
      backgroundColor: const Color.fromARGB(255, 14, 26, 50),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 40.0),
          child: Column(
            children: [
              // Name
              PatientTextField(
                  controller: _patientNameController,
                  hintText: 'Enter Name',
                  obscureText: false,
                  textColor: Colors.white,
                  image: 'assets/icons/user.png',
                  numericalOnly: false,
                  textLength: 40),

              // Contact
              PatientTextField(
                  controller: _patientContactController,
                  hintText: 'Enter Contact',
                  obscureText: false,
                  textColor: Colors.white,
                  image: 'assets/icons/contact.png',
                  numericalOnly: true,
                  textLength: 11),

              // Email
              PatientTextField(
                  controller: _patientEmailController,
                  hintText: 'Enter Email',
                  obscureText: false,
                  textColor: Colors.white,
                  image: 'assets/icons/mail.png',
                  numericalOnly: false,
                  textLength: 40),

              // Shade
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 25),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30.0),
                  child: Container(
                    height: 70,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 16, 35, 65),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: DropdownButtonFormField<String>(
                        value: _selectedShade,
                        onChanged: (newValue) {
                          setState(() {
                            _selectedShade = newValue!;
                          });
                        },
                        items: _shadeOptions.map((shade) {
                          return DropdownMenuItem<String>(
                            value: shade,
                            child: Row(
                              children: [
                                ColorFiltered(
                                  colorFilter: ColorFilter.mode(
                                    Colors.white.withOpacity(0.7),
                                    BlendMode.dstIn,
                                  ),
                                  child: Image.asset('assets/icons/tooth.png',
                                      width: 20.0, height: 20.0),
                                ),
                                const SizedBox(width: 8.0),
                                Text(
                                  shade,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Color.fromARGB(255, 16, 35, 65),
                          border: InputBorder.none,
                          hintText: 'Select Shade',
                        ),
                        dropdownColor: const Color.fromARGB(255, 16, 35, 65),
                      ),
                    ),
                  ),
                ),
              ),

              // Notes Field
              PatientTextField(
                  controller: _patientNoteController,
                  hintText: 'Enter Notes',
                  obscureText: false,
                  textColor: Colors.white,
                  image: 'assets/icons/notes.png',
                  numericalOnly: false,
                  textLength: 40),

              const SizedBox(height: 30),

              Column(
                children: [
                  // Update Button
                  LargeButton(
                    buttonText: 'Update Details',
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
                        _patientImageController.text.isEmpty
                            ? _validateImage = true
                            : _validateImage = false;
                        _patientNoteController.text.isEmpty
                            ? _validateNote = true
                            : _validateNote = false;
                      });
                      if (_validateName == false &&
                          _validateContact == false &&
                          _validateEmail == false &&
                          _validateImage == false &&
                          _validateNote == false) {
                        var result = await PatientApi().updatePatient(
                          _patientNameController.text,
                          _patientContactController.text,
                          _patientEmailController.text,
                          _selectedShade,
                          _patientImageController.text,
                          _patientNoteController.text,
                          widget.patient.id,
                        );

                        showConfirmationDialog(
                          context,
                          'Success!',
                          [Text('$result has been successfully updated.')],
                          Icons.check,
                          () {
                            Get.back();
                          },
                        );
                      }
                    },
                  ),

                  const SizedBox(height: 15),

                  // Cancel Button
                  SizedBox(
                    width: 200,
                    height: 40,
                    child: OutlinedButton(
                      onPressed: () {
                        Get.back();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        side: const BorderSide(
                            color: Color.fromARGB(255, 245, 91, 127)),
                      ),
                      child: const Text(
                        'Cancel',
                        style:
                            TextStyle(color: Color.fromARGB(255, 245, 91, 127)),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
