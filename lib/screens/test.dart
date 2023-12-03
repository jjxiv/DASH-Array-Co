import 'dart:io';
import 'dart:convert';
import 'package:dash/components/large_button.dart';
import 'package:dash/components/medium_button.dart';
import 'package:dash/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'add_patient_form.dart';

class Test extends StatefulWidget {
  const Test({Key? key}) : super(key: key);

  @override
  _TestState createState() => _TestState();
}

class _TestState extends State<Test> {
  final List<String> instructions = [
    'Provide good lighting, natural lighting is preferred',
    'Make sure that the whole face is visible',
    'The height of the mouth must be greater than the width',
    'Make sure the surface of the teeth is visible',
  ];

  File? _imageFile, selectedImage;
  var resJson;
  bool _teethDetectionSuccess = false;
  bool _isLoading = false;
  String _newImageName = '';
  int currentStep = 0;
  String messageOut = "";
  bool teethDetected = false;

  // Opens instructions dialog at the beginning
  @override
  void initState() {
    super.initState();
  }

  // Chooses image to upload (existing or new)
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: source);

    // Checks if there is an image to be uploaded
    if (pickedImage != null) {
      setState(() {
        _imageFile = File(pickedImage.path);
      });
    }
  }

  // Checks if there is an image
  Future<void> _detectAndUploadImage() async {
    if (_imageFile == null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Please select an image.'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
      return;
    }

    setState(() {
      _teethDetectionSuccess = false;
      _isLoading = true;
    });

    var request = http.MultipartRequest(
      'POST',
      Uri.parse(
          'http://192.168.0.18:5000/detect_smiles'), // Replace with your Flask server URL for teeth detection
    );

    request.files
        .add(await http.MultipartFile.fromPath('image', _imageFile!.path));

    try {
      var response = await request.send();
      String message;
      // Checks server response
      if (response.statusCode == 200) {
        var responseData = await http.Response.fromStream(response);
        var jsonResponse = await json.decode(responseData.body);
        String result = jsonResponse['result'];

        if (result == 'Success') {
          message = jsonResponse['image'];
          // Displays the shade that has been found
          setState(() {
            _teethDetectionSuccess = true;
            _isLoading = false;
            messageOut = message;
          });

          teethDetected = true;

          // Upload the image to the Flask server
          _uploadImageToServer();
        } else if (result == 'Retake') {
          // Displays the retake message
          message = jsonResponse['msg'];
          setState(() {
            _teethDetectionSuccess = false;
            _isLoading = false;
            messageOut = message;
          });
        } else if (result == 'Failure') {
          // Teeth was not found
          message = jsonResponse['message'];
          setState(() {
            _teethDetectionSuccess = false;
            _isLoading = false;
            messageOut = message;
          });
        } else {
          // Unknown response error
          message = 'Unknown response from the server';
          setState(() {
            _teethDetectionSuccess = false;
            _isLoading = false;
            messageOut = message;
          });
        }
      } else {
        // Error message
        setState(() {
          _teethDetectionSuccess = false;
          _isLoading = false;
          messageOut = "Error";
        });
        message = "Error";
      }
    } catch (e) {
      setState(() {
        _teethDetectionSuccess = false;
      });
      messageOut = "Error";
    }
  }

  // Uploads the image to the Flask server
  Future<String?> _uploadImageToServer() async {
    if (_imageFile == null) return null;

    var stream = new http.ByteStream(_imageFile!.openRead());
    var length = await _imageFile!.length();

    var uri = Uri.parse(
        'http://192.168.0.18:5000/upload'); // Replace with your Flask server URL for image upload
    var request = new http.MultipartRequest("POST", uri);

    var multipartFile = new http.MultipartFile('image', stream, length,
        filename: _newImageName + ".jpg");

    request.files.add(multipartFile);

    var response = await request.send();
    if (response.statusCode == 200) {
      // Image uploaded successfully
      return response.reasonPhrase;
    } else {
      // Error uploading image
      return response.reasonPhrase;
    }
  }

  // If detection failed
  void _showDetectionResultDialogFailure(bool success, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Detection Failed'),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  // If detection success
  void _showDetectionResultDialogSuccess(bool success, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("$message"),
          content: const Text(
              "Teeth Detection Success. Would you like to save this image?"),
          actions: [
            // Saves to database
            TextButton(
              onPressed: _continueToNextScreen,
              child: const Text('Yes'),
            ),

            // Exits Dialog
            TextButton(
              child: const Text('No'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _continueToNextScreen() async {
    if (_imageFile != null) {
      String imageName = path.basename(_imageFile!.path);
      String newPath = path.join(path.dirname(_imageFile!.path), imageName);
      File newImageFile = await _imageFile!.copy(newPath);
      _newImageName = imageName;

      // Upload the image to the Flask server
      String? uploadResult = await _uploadImageToServer();

      // Checks if upload has been completed
      if (uploadResult == 'OK') {
        Get.to(() => AddPatientForm(imageFile: newImageFile));
      } else {
        // Shows error image upload
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text('Failed to upload image: $uploadResult'),
              actions: [
                TextButton(
                  child: const Text('OK'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            );
          },
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Please select an image.'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
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
                color: Color.fromARGB(25, 255, 255, 255),
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
          backgroundColor: const Color.fromARGB(255, 0, 89, 231),
          elevation: 0,
          title: const Text("Shade Match"),
          titleSpacing: 10.0,
        ),
        backgroundColor: const Color.fromARGB(255, 14, 26, 50),
        body: Stack(children: [
          // Background
          Container(
            height: 350,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 0, 89, 231),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(80.0),
                bottomRight: Radius.circular(80.0),
              ),
            ),
          ),

          // Stepper
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Stepper(
              type: StepperType.horizontal,
              steps: getSteps(),
              currentStep: currentStep,
              onStepContinue: () {
                final isLastStep = (currentStep == getSteps().length - 1);
                if (!isLastStep) {
                  setState(() => currentStep += 1);
                } else {
                  print('Completed');
                }
              },
              onStepCancel: currentStep == 0
                  ? null
                  : () => setState(() => currentStep -= 1),
              controlsBuilder:
                  (BuildContext context, ControlsDetails controlsDetails) {
                return Column(
                  children: <Widget>[
                    const SizedBox(height: 15),
                    if (controlsDetails.onStepContinue != null &&
                        currentStep == 0)
                      ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                if (!_isLoading) {
                                  _detectAndUploadImage();
                                  if (teethDetected) {
                                    controlsDetails.onStepContinue!();
                                  }
                                }
                              },
                        style: ButtonStyle(
                          backgroundColor: _isLoading
                              ? MaterialStateProperty.all<Color>(
                                  Colors.transparent)
                              : MaterialStateProperty.all<Color>(
                                  const Color.fromARGB(255, 0, 89, 231)),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          minimumSize: MaterialStateProperty.all<Size>(
                              const Size(double.infinity, 0)),
                          fixedSize: MaterialStateProperty.all<Size>(
                              const Size.fromHeight(50)),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (_isLoading)
                              Container(
                                alignment: Alignment.center,
                                child: const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Color.fromRGBO(78, 44, 112, 1)),
                                  strokeWidth: 2.0,
                                ),
                              ),
                            if (!_isLoading)
                              const Text(
                                'Continue',
                              ),
                          ],
                        ),
                      ),
                    if (currentStep < getSteps().length - 1 && currentStep > 0)
                      LargeButton(
                        buttonText: 'Continue',
                        onTap: controlsDetails.onStepContinue,
                        color: Colors.blue,
                        textcolor: Colors.white,
                      ),
                    if (controlsDetails.onStepCancel != null)
                      TextButton(
                        onPressed: controlsDetails.onStepCancel,
                        child: const Text('Back'),
                      ),
                  ],
                );
              },
            ),
          )
        ]));
  }

  List<Step> getSteps() => [
        // Instructions
        Step(
          isActive: currentStep >= 0,
          title: const Text('Instructions'),
          content: Column(
            children: [
              Container(
                height: 370,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 16, 35, 65),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Section
                    Container(
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 16, 35, 65),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Take Photo',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Please follow the instructions listed below.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // The Rest of the "Instructions" Content
                    ...List.generate(4, (index) {
                      return Column(
                        children: [
                          ListTile(
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            leading: CircleAvatar(
                              // Number icon
                              backgroundColor:
                                  const Color.fromARGB(255, 7, 186, 103),
                              child: Text(
                                (index + 1).toString(),
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ),
                            title: Text(
                              instructions[index],
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      );
                    }),
                  ],
                ),
              ),

              // Camera & Gallery Buttons
              Row(
                children: [
                  const SizedBox(height: 120),

                  // Take Photo Button
                  Expanded(
                    child: SizedBox(
                      height: 80,
                      child: ElevatedButton(
                        onPressed: () => _pickImage(ImageSource.camera),
                        style: ElevatedButton.styleFrom(
                          elevation: 3,
                          backgroundColor:
                              const Color.fromARGB(255, 16, 35, 65),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt_rounded, size: 40),
                            SizedBox(width: 10),
                            Text('Take Photo'),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 20),

                  // Gallery Button
                  Expanded(
                    child: SizedBox(
                      height: 80,
                      child: ElevatedButton(
                        onPressed: () => _pickImage(ImageSource.gallery),
                        style: ElevatedButton.styleFrom(
                          elevation: 3,
                          backgroundColor:
                              const Color.fromARGB(255, 16, 35, 65),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.photo_rounded, size: 40),
                            SizedBox(width: 10),
                            Text('Gallery'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Shade Matched Image
        Step(
          isActive: currentStep >= 1,
          title: const Text('Shade Match'),
          content: Padding(
            padding: const EdgeInsets.only(top: 30),
            child: Column(
              children: [
                Container(
                  height: 400,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 16, 35, 65),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Column(
                    children: [
                      // Header Section
                      Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 16, 35, 65),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Center(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Shade Found!',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  messageOut,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ]),
                        ),
                      ),

                      _imageFile != null
                          ? SizedBox(
                              width: 250,
                              height: 250,
                              child: Image.file(
                                _imageFile!,
                                fit: BoxFit.contain,
                              ),
                            )
                          : const Text("No image"),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Save Details
        Step(
          isActive: currentStep >= 2,
          title: const Text('Save'),
          content: Padding(
            padding: const EdgeInsets.only(top: 30),
            child: Column(
              children: [
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 16, 35, 65),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Column(
                    children: [
                      // Header Section
                      Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 16, 35, 65),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Center(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Would you like to save details?',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'You will be redirected to the save details page',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ]),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Save Button
                      MediumButton(
                          buttonText: 'Save',
                          onTap: _continueToNextScreen,
                          color: Colors.green,
                          textcolor: Colors.white),

                      const SizedBox(height: 20),

                      // Does not save
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
                            side: const BorderSide(color: Colors.red),
                          ),
                          child: const Text('Maybe next time',
                              style: TextStyle(color: Colors.red)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ];
}
