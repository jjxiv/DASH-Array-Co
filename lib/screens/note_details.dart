import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/note.dart';

class NoteDetailsScreen extends StatefulWidget {
  final Note note;

  const NoteDetailsScreen({Key? key, required this.note}) : super(key: key);

  @override
  _NoteDetailsScreenState createState() => _NoteDetailsScreenState();
}

class _NoteDetailsScreenState extends State<NoteDetailsScreen> {
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
        title: const Text("Note Details"),
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
                const SizedBox(height: 30),

                // Patient Name
                Text(
                  widget.note.name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
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
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 20.0, horizontal: 24.0),
                  child: Text(widget.note.note,
                      style:
                          const TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
