import 'dart:convert';
import 'package:dash/components/detail_list.dart';
import 'package:flutter/material.dart';
import 'package:dash/models/patient.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class PatientDetailsScreen extends StatefulWidget {
  final Patient patient;

  const PatientDetailsScreen({Key? key, required this.patient})
      : super(key: key);

  @override
  _PatientDetailsScreenState createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  Future<String> getBase64Image(String url) async {
    var response = await http.get(Uri.parse(url));

    print(url);
    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      var base64Image = responseData['img'];
      return base64Image;
    } else {
      throw Exception('Failed to fetch base64 image');
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
              color: Color.fromARGB(50, 255, 255, 255),
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
        backgroundColor: const Color.fromARGB(255, 0, 89, 231),
        elevation: 0,
        title: const Text("Patient Details"),
        titleSpacing: 10.0,
      ),
      backgroundColor: const Color.fromARGB(255, 14, 26, 50),
      body: Stack(children: [
        // Background
        Container(
          height: 150,
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 0, 89, 231),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(80.0),
              bottomRight: Radius.circular(80.0),
            ),
          ),

          // Patient Name
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 12),

                // Label
                const Text(
                  "Patient Name",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 10),

                // Patient Name
                Text(
                  widget.patient.name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),

        // List Items
        Center(
          child: Container(
            // Background
            margin: const EdgeInsets.only(top: 70),
            height: 550,
            width: 350,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 16, 35, 65),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 50),

                // Patient ID
                DetailList(
                  label: "Patient ID",
                  value: widget.patient.id.toString(),
                ),

                DetailList(
                  label: "Date Taken",
                  value: widget.patient.date.toString(),
                ),

                // Contact
                DetailList(
                  label: "Contact",
                  value: widget.patient.contact.toString(),
                ),

                DetailList(
                  label: "Email",
                  value: widget.patient.email.toString(),
                ),

                DetailList(
                  label: "Shade",
                  value: widget.patient.shade.toString(),
                ),

                DetailList(
                  label: "Note",
                  value: widget.patient.note.toString(),
                ),

                // Image
                Center(
                  child: FutureBuilder<String>(
                    future: getBase64Image(
                        'http://192.168.0.18:5000/cropped_images/${widget.patient.image}'),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        print('Image loading error: ${snapshot.error}');
                        return Text('Failed to load image: ${snapshot.error}');
                      } else if (snapshot.hasData) {
                        return Image.memory(
                          width: 300,
                          height: 250,
                          base64Decode(snapshot.data!),
                          errorBuilder: (context, error, stackTrace) {
                            print('Image loading error: $error');
                            return Text('Failed to load image: $error');
                          },
                        );
                      } else {
                        return const Text('Image not available');
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
