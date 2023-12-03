import 'package:dash/components/confirmation_dialog.dart';
import 'package:dash/components/large_button.dart';
import 'package:flutter/material.dart';
import 'package:dash/providers/note_api.dart';
import 'package:dash/models/note.dart';
import 'package:get/get.dart';

class updateNoteForm extends StatefulWidget {
  final Note note;
  const updateNoteForm(this.note, {Key? key}) : super(key: key);

  @override
  State<updateNoteForm> createState() => _updateNoteFormState();
}

class _updateNoteFormState extends State<updateNoteForm> {
  var _noteNameController = TextEditingController();
  var _noteNoteController = TextEditingController();

  bool _validateName = false;
  bool _validateNote = false;

  @override
  void initState() {
    _noteNameController.text = widget.note.name;
    _noteNoteController.text = widget.note.note;
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
        title: const Text("Update Note"),
        titleSpacing: 10.0,
      ),
      backgroundColor: const Color.fromARGB(255, 14, 26, 50),
      body: SingleChildScrollView(
        child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Title
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 16, 35, 65),
                    borderRadius: BorderRadius.circular(50.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 5.0, horizontal: 15.0),
                    child: TextField(
                      controller: _noteNameController,
                      maxLength: 40,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 20.0),
                        hintText: 'Title',
                        hintStyle: const TextStyle(
                            color: Color.fromARGB(100, 255, 255, 255)),
                        counterText: '',
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorText:
                            _validateName ? "Title can't be empty." : null,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Note
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 16, 35, 65),
                    borderRadius: BorderRadius.circular(50.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 10.0),
                    child: TextField(
                      controller: _noteNoteController,
                      maxLines: 10,
                      maxLength: 280,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 20.0,
                            horizontal: 15.0), // Adjust content padding
                        hintText: 'Enter Note',
                        hintStyle: const TextStyle(
                            color: Color.fromARGB(100, 255, 255, 255)),
                        errorText:
                            _validateNote ? "Note Value Can't Be Empty" : null,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        counterStyle: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                Column(
                  children: [
                    // Update
                    SizedBox(
                      width: 300,
                      height: 50,
                      child: LargeButton(
                        buttonText: "Update Note",
                        color: const Color.fromARGB(255, 0, 89, 231),
                        textcolor: Colors.white,
                        onTap: () async {
                          setState(() {
                            _noteNameController.text.isEmpty
                                ? _validateName = true
                                : _validateName = false;
                            _noteNoteController.text.isEmpty
                                ? _validateNote = true
                                : _validateNote = false;
                          });
                          if (_validateName == false &&
                              _validateNote == false) {
                            var result = await NoteApi().updateNote(
                              widget.note.id,
                              _noteNameController.text,
                              _noteNoteController.text,
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
                    ),

                    const SizedBox(height: 15),

                    // Cancel
                    SizedBox(
                      width: 200,
                      height: 40,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
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
                          style: TextStyle(
                              color: Color.fromARGB(255, 245, 91, 127)),
                        ),
                      ),
                    )
                  ],
                )
              ],
            )),
      ),
    );
  }
}
