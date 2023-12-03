import 'dart:convert';
import 'package:dash/screens/home_screen.dart';
import 'package:dash/screens/patient_details.dart';
import 'package:flutter/material.dart';
import 'package:dash/models/patient.dart';
import 'package:dash/providers/patientApi.dart';
import 'package:dash/screens/update_patient_form.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class DatabaseScreen extends StatefulWidget {
  const DatabaseScreen({Key? key}) : super(key: key);

  @override
  State<DatabaseScreen> createState() => _DatabaseScreenState();
}

class _DatabaseScreenState extends State<DatabaseScreen> {
  Stream<List<Patient>>? patientsStream;
  var isLoaded = false;
  var isEmpty = false;
  late List<Patient> allPatients = [];
  late List<Patient> displayedPatients = [];
  bool isSortAscending = true; // Track the sorting order

  @override
  void initState() {
    super.initState();
    patientsStream = PatientApi().pollPatients(const Duration(seconds: 3));
    getRecord(); // Fetch initial set of patient data
  }

  Future<void> getRecord() async {
    final patients = await PatientApi().getAllPatients();
    if (patients == null) {
      // Error handling
    } else if (patients.isEmpty) {
      isEmpty = true;
      isLoaded = true;
    } else {
      setState(() {
        allPatients = patients;
        displayedPatients = patients;
        isLoaded = true;
      });
    }
  }

  Future<void> showMessageDialog(String title, String message) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Text(
              message,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void searchPatients(String query) {
    setState(() {
      displayedPatients = allPatients
          .where((patient) =>
              patient.name?.toLowerCase().contains(query.toLowerCase()) ??
              false)
          .toList();
    });
  }

  void sortPatients() {
    setState(() {
      isSortAscending = !isSortAscending;
      displayedPatients.sort((a, b) {
        if (isSortAscending) {
          // Sort in A-Z order
          return a.name!.compareTo(b.name!);
        } else {
          // Sort by relevance to date
          return b.date!.compareTo(a.date!);
        }
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
        title: const Text("View Records"),
        actions: [
          IconButton(
            onPressed: sortPatients,
            icon: Icon(
              isSortAscending ? Icons.sort_by_alpha : Icons.calendar_today,
            ),
          ),
        ],
        titleSpacing: 10.0,
      ),
      backgroundColor: const Color.fromARGB(255, 14, 26, 50),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
            child: Container(
              height: 60,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: const Color.fromARGB(255, 16, 35, 65),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Search',
                    hintStyle: TextStyle(color: Colors.white),
                    prefixIcon: Icon(Icons.search, color: Colors.white),
                    contentPadding: EdgeInsets.symmetric(vertical: 15.0),
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    searchPatients(value);
                  },
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Items
          Expanded(
            child: StreamBuilder<List<Patient>>(
              stream: patientsStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final patients = displayedPatients;
                  return ListView.builder(
                    itemCount: patients.length,
                    itemBuilder: (context, index) {
                      final patient = patients[index];

                      return Dismissible(
                        key: Key(patient.id.toString()),
                        confirmDismiss: (direction) async {
                          bool confirmDelete = await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Confirm Deletion'),
                                content: const Text(
                                    'Are you sure you want to delete this record?'),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text('Cancel'),
                                    onPressed: () {
                                      Navigator.of(context).pop(false);
                                    },
                                  ),
                                  TextButton(
                                    child: const Text('Delete'),
                                    onPressed: () {
                                      Navigator.of(context).pop(true);
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                          return confirmDelete;
                        },
                        onDismissed: (direction) async {
                          // Handle the dismiss action if confirmed
                          final deletedPatient =
                              await PatientApi().deletePatient(patient.id);
                          showMessageDialog("Success",
                              "$deletedPatient has been removed successfully");
                          getRecord();

                          // Remove the dismissed item from the list
                          setState(() {
                            patients.removeAt(index);
                          });
                        },
                        background: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              child: const Padding(
                                padding: EdgeInsets.only(right: 16.0),
                                child: Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Item
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 10.0),
                          child: Container(
                            height: 80,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: const Color.fromARGB(255, 16, 35, 65),
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              child: ListTile(
                                title: Text(patient.name,
                                    style:
                                        const TextStyle(color: Colors.white)),
                                subtitle: Text(patient.date,
                                    style:
                                        const TextStyle(color: Colors.white)),
                                onTap: () {
                                  Get.to(
                                      () => PatientDetailsScreen(
                                          patient: patient),
                                      transition: Transition.rightToLeft);
                                },
                                trailing: Container(
                                  width: 45,
                                  height: 45,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      color: const Color.fromARGB(
                                          20, 255, 255, 255)),
                                  child: IconButton(
                                    onPressed: () async {
                                      final updatedPatient = await Get.to(
                                          () => (updatePatientForm(patient)),
                                          transition: Transition.rightToLeft);
                                      if (updatedPatient != null) {
                                        showMessageDialog("Success",
                                            "$updatedPatient has been updated successfully");
                                        getRecord();
                                      }
                                    },
                                    icon: const Icon(Icons.edit,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  if (isEmpty) {
                    return const Center(child: Text('No patients found'));
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
