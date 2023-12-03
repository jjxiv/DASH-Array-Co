import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:dash/models/patient.dart';
import 'dart:io';

class PatientApi {
  get path => null;
  // String email = EmailManager().email;
  String? email = FirebaseAuth.instance.currentUser?.email.toString();
  String? ownerEmail = FirebaseAuth.instance.currentUser?.email.toString();

  //establish connection patient
  Future<List<Patient>?> getAllPatients() async {
    var client = http.Client();
    var uri = Uri.parse("https://array-co.online/patient/$email");
    //print("Value of email is $email");
    var response = await client.get(uri);
    if (response.statusCode == 200) {
      var json = response.body;
      return patientFromJson(json);
    } else {
      print('Error: ${response.statusCode} - ${response.reasonPhrase}');
      return null;
    }
  }

  Stream<List<Patient>> pollPatients(Duration duration) async* {
    while (true) {
      await Future.delayed(duration);
      List<Patient>? patients = await getAllPatients();
      if (patients != null) {
        yield patients;
      }
    }
  }

  // Add patient
  Future<Patient>? addPatient(String owner, String name, String contact,
      String email, String shade, String image, String note) async {
    var client = http.Client();
    var uri = Uri.parse("http://array-co.online/patient");
    final http.Response response = await client.post(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'owner': ownerEmail!,
        'name': name,
        'contact': contact,
        'email': email,
        'shade': shade,
        'image': image,
        'note': note
      }),
    );

    if (response.statusCode == 200) {
      var json = response.body;
      return Patient.fromJson(jsonDecode(json));
    } else {
      throw Exception('Failed to save patient');
    }
  }

  // Delete patient
  Future<Patient>? deletePatient(int id) async {
    var client = http.Client();
    var uri = Uri.parse("http://array-co.online/patient/$id");
    final http.Response response =
        await client.delete(uri, headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    });
    if (response.statusCode == 200) {
      var json = response.body;
      return Patient.fromJson(jsonDecode(json));
    } else {
      throw Exception('Failed to delete patient');
    }
  }

  // Update patient
  Future<Patient>? updatePatient(String name, String contact, String email,
      String shade, String image, String note, int id) async {
    var client = http.Client();
    var uri = Uri.parse("http://array-co.online/patient/$id");
    final http.Response response = await client.put(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'name': name,
        'contact': contact,
        'email': email,
        'shade': shade,
        'image': image,
        'note': note
      }),
    );
    if (response.statusCode == 200) {
      var json = response.body;
      return Patient.fromJson(jsonDecode(json));
    } else {
      throw Exception('Failed to update patient');
    }
  }

  Future<String> _uploadImage(File imageFile) async {
    try {
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
        return response.reasonPhrase!;
      } else {
        // Error uploading image
        return 'Failed to upload image. HTTP Status: ${response.statusCode}';
      }
    } catch (e) {
      // Exception occurred during image upload
      return 'Error uploading image: $e';
    }
  }
}
