import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
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
  TextEditingController _imageNameController = TextEditingController();
  bool _teethDetectionSuccess = false;

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

  // Validates the image chosen (HAAR Cascade)
  /* Future<void> _detectSmiles() async {
    // Code for teeth detection

    // Temporarily disabled teeth detection
    setState(() {
      _teethDetectionSuccess = true;
    });
    _showDetectionResultDialog(true);
  } */

  // Uploads to cloud VPS
  Future<String?> _uploadImage(File imageFile) async {
    var stream = new http.ByteStream(imageFile.openRead());
    var length = await imageFile.length();

    var uri = Uri.parse(
        'http://array-co.online/upload'); // Replace with your Flask server URL
    var request = new http.MultipartRequest("POST", uri);

    var multipartFile = new http.MultipartFile('image', stream, length,
        filename: path.basename(imageFile.path));

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

  void _showDetectionResultDialog(bool success) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(success ? 'Success' : 'Failure'),
          content: Text(success
              ? 'Smile detected!'
              : 'No opened mouth with teeth detected.'),
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

  void _continueToNextScreen() async {
    if (_imageFile != null) {
      String imageName = path.basename(_imageFile!.path);

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Enter Image Name'),
            content: TextField(
              controller: _imageNameController,
              decoration: const InputDecoration(
                hintText: 'New Image Name',
              ),
            ),
            actions: [
              TextButton(
                child: const Text('Save'),
                onPressed: () async {
                  String newFileName = _imageNameController.text;
                  String newPath =
                      path.join(path.dirname(_imageFile!.path), newFileName);
                  File newImageFile = await _imageFile!.copy(newPath + ".jpg");

                  // Upload the image to the Flask server
                  String? uploadResult = await _uploadImage(newImageFile);

                  if (uploadResult == 'OK') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AddPatientForm(imageFile: newImageFile),
                      ),
                    );
                  } else {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Error'),
                          content:
                              Text('Failed to upload image: $uploadResult'),
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
                }, // Disable the button if teeth detection failed
              ),
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
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
  void dispose() {
    _imageNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () => _pickImage(ImageSource.camera),
            child: const Text('Take Photo'),
          ),
          ElevatedButton(
            onPressed: () => _pickImage(ImageSource.gallery),
            child: const Text('Choose from Gallery'),
          ),
          if (_imageFile != null)
            Container(
              width: 300,
              height: 400,
              child: Image.file(
                _imageFile!,
                fit: BoxFit.cover,
              ),
            ),
          /* ElevatedButton(
            onPressed: _detectSmiles,
            child: const Text('Check teeth'),
          ), */
          ElevatedButton(
            onPressed: _continueToNextScreen,
            child: const Text('Upload'),
          ),
        ],
      ),
    );
  }
}
