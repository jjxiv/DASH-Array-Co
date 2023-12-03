import 'dart:io';
import 'dart:convert';
import 'package:dash/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'add_patient_form.dart';

class ImageUploader extends StatefulWidget {
  const ImageUploader({Key? key}) : super(key: key);

  @override
  _ImageUploaderState createState() => _ImageUploaderState();
}

class _ImageUploaderState extends State<ImageUploader> {
  File? _imageFile, selectedImage;
  var resJson;
  bool _teethDetectionSuccess = false;
  bool _isLoading = false;
  String _newImageName = '';

  // Opens instructions dialog at the beginning
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      openInstructionDialog(context);
    });
  }

  void openInstructionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: InstructionScreen(),
        );
      },
    );
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
          });
          _showDetectionResultDialogSuccess(true, message);

          // Upload the image to the Flask server
          _uploadImageToServer();
        } else if (result == 'Retake') {
          // Displays the retake message
          message = jsonResponse['msg'];
          setState(() {
            _teethDetectionSuccess = false;
            _isLoading = false;
          });
          _showDetectionResultDialogFailure(false, message);
        } else if (result == 'Failure') {
          // Teeth was not found
          message = jsonResponse['message'];
          setState(() {
            _teethDetectionSuccess = false;
            _isLoading = false;
          });
          _showDetectionResultDialogFailure(false, message);
        } else {
          // Unknown response error
          message = 'Unknown response from the server';
          setState(() {
            _teethDetectionSuccess = false;
            _isLoading = false;
          });
          _showDetectionResultDialogFailure(false, message);
        }
      } else {
        // Error message
        setState(() {
          _teethDetectionSuccess = false;
          _isLoading = false;
        });
        _showDetectionResultDialogFailure(false, "Error");
      }
    } catch (e) {
      setState(() {
        _teethDetectionSuccess = false;
      });
      _showDetectionResultDialogFailure(false, "Error");
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
          content: Text(
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
      body: Center(
        child: Column(
          children: [
            Center(
              // Step-by-Step Process
              child: Container(
                height: 400,
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 0, 89, 231),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(80.0),
                    bottomRight: Radius.circular(80.0),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Center elements vertically
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [],
                  ),
                ),
              ),
            ),

            // Buttons
            Row(
              children: [
                // Take Photo Button
                Expanded(
                  child: SizedBox(
                    height: 150,
                    child: ElevatedButton(
                      onPressed: () => _pickImage(ImageSource.camera),
                      style: ElevatedButton.styleFrom(
                        elevation: 10,
                        backgroundColor: const Color.fromARGB(255, 16, 35, 65),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt_rounded, size: 40),
                          SizedBox(height: 10),
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
                    height: 150,
                    child: ElevatedButton(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      style: ElevatedButton.styleFrom(
                        elevation: 10,
                        backgroundColor: const Color.fromARGB(255, 16, 35, 65),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.photo_rounded, size: 40),
                          SizedBox(height: 10),
                          Text('Gallery'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Displays Image
            if (_imageFile != null)
              SizedBox(
                width: 300,
                height: 300,
                child: Image.file(
                  _imageFile!,
                  fit: BoxFit.contain,
                ),
              ),

            const SizedBox(height: 20),

            // Continue button
            ElevatedButton(
              onPressed: _isLoading ? null : _detectAndUploadImage,
              style: ButtonStyle(
                backgroundColor: _isLoading
                    ? MaterialStateProperty.all<Color>(Colors.transparent)
                    : MaterialStateProperty.all<Color>(
                        const Color.fromARGB(255, 0, 89, 231)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                minimumSize: MaterialStateProperty.all<Size>(
                    const Size(double.infinity, 0)),
                fixedSize:
                    MaterialStateProperty.all<Size>(const Size.fromHeight(50)),
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
          ],
        ),
      ),
    );
  }
}

class InstructionScreen extends StatefulWidget {
  @override
  _InstructionScreenState createState() => _InstructionScreenState();
}

class _InstructionScreenState extends State<InstructionScreen> {
  int currentStep = 0;
  bool _isChecked = false;

  List<String> instructions = [
    'Make sure that you are in a well-lit room that uses natural lighting',
    'The photo must include the whole face',
    'The mouth must be greater in vertical height than width',
    'Make sure that the surface of teeth is visible enough',
    'Upload your photo',
  ];

  List<String> images = [
    'assets/images/instruction_1.png',
    'assets/images/instruction_2.png',
    'assets/images/instruction_3.png',
    'assets/images/instruction_4.png',
    'assets/images/instruction_5.png',
  ];

  List<String> title = [
    'Lighting',
    'Visible Face',
    'Mouth Position',
    'Teeth Surface',
    'Finalize and Upload',
  ];

  void goToNextStep() {
    setState(() {
      if (currentStep < instructions.length - 1) {
        currentStep++;
      }
    });
  }

  void goToPreviousStep() {
    setState(() {
      if (currentStep > 0) {
        currentStep--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 500,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // Header
                  Container(
                    color: const Color.fromRGBO(78, 44, 112, 1),
                    padding: const EdgeInsets.all(16.0),
                    child: const Text(
                      'Image Guidelines',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 16.0),

                  // Instruction Title
                  Text(
                    title[currentStep],
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16.0),

                  // Arrows and Images
                  Row(
                    children: [
                      // Previous
                      Visibility(
                        visible: currentStep > 0,
                        child: IconButton(
                          onPressed: goToPreviousStep,
                          icon: const Icon(Icons.arrow_back),
                        ),
                      ),

                      // Image
                      Expanded(
                        child: Image.asset(
                          images[currentStep],
                          height: 200.0,
                        ),
                      ),

                      // Next
                      Visibility(
                        visible: currentStep < instructions.length - 1,
                        child: IconButton(
                          onPressed: goToNextStep,
                          icon: const Icon(Icons.arrow_forward),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16.0),

                  // Step description
                  Text(
                    instructions[currentStep],
                    style: const TextStyle(
                      fontSize: 16.0,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 24.0),

                  // Add extra space for the button
                  const SizedBox(height: 60.0),
                ],
              ),
            ),
            // Button
            // Button with bottom padding and checkbox
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(
                    bottom: 35.0), // Adjust the bottom padding value as needed
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Don't show
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Checkbox(
                          value: _isChecked,
                          onChanged: (newValue) {
                            setState(() {
                              _isChecked = newValue ?? false;
                            });
                          },
                        ),
                        const Text(
                          "Don't show this next time",
                          style: TextStyle(fontSize: 14.0),
                        ),
                      ],
                    ),

                    const SizedBox(height: 3.0),

                    // Button
                    FractionallySizedBox(
                      widthFactor: 0.6,
                      child: SizedBox(
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromRGBO(78, 44, 112, 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 3,
                          ),
                          child: const Text('Continue'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
