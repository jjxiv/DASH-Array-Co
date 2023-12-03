import 'package:dash/screens/home_screen.dart';
import 'package:dash/screens/note_details.dart';
import 'package:dash/screens/note_screen.dart';
import 'package:flutter/material.dart';
import 'package:dash/models/note.dart';
import 'package:dash/providers/note_api.dart';
import 'package:dash/screens/update_note_form.dart';
import 'package:dash/screens/add_note_form.dart';
import 'package:get/get.dart';

class DatabaseNoteScreen extends StatefulWidget {
  const DatabaseNoteScreen({Key? key}) : super(key: key);

  @override
  State<DatabaseNoteScreen> createState() => _DatabaseNoteScreenState();
}

class _DatabaseNoteScreenState extends State<DatabaseNoteScreen> {
  Stream<List<Note>>? notesStream;
  var isLoaded = false;
  var isEmpty = false;
  late List<Note> allNotes = [];
  late List<Note> displayedNotes = [];

  @override
  void initState() {
    super.initState();
    notesStream = NoteApi().pollNotes(const Duration(seconds: 3));
    getRecord(); // Fetch initial set of notes data
  }

  Future<void> getRecord() async {
    final notes = await NoteApi().getAllNotes();
    setState(() {
      allNotes = notes!;
      displayedNotes = notes!;
      isLoaded = true;
    });
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

  void searchNotes(String query) {
    setState(() {
      displayedNotes = allNotes
          .where((note) =>
              note.name?.toLowerCase().contains(query.toLowerCase()) ?? false)
          .toList();
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
        title: const Text("Notes"),
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
                    searchNotes(value);
                  },
                ),
              ),
            ),
          ),

          // List Items
          Expanded(
            child: StreamBuilder<List<Note>>(
              stream: notesStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final notes = displayedNotes;
                  return ListView.builder(
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      return Dismissible(
                        key: Key(note.id.toString()),
                        confirmDismiss: (direction) async {
                          bool confirmDelete = await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Confirm Deletion'),
                                content: const Text(
                                    'Are you sure you want to delete this note?'),
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
                          final deletedNote =
                              await NoteApi().deleteNote(note.id);
                          showMessageDialog("Success",
                              "$deletedNote has been removed successfully");
                          getRecord();
                        },
                        movementDuration: const Duration(milliseconds: 200),
                        crossAxisEndOffset: 0.67,
                        // Delete Button
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

                        // Items
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
                                title: Text(
                                  note.name,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                onTap: () {
                                  Get.to(() => (NoteDetailsScreen(note: note)),
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
                                      final updatedNote = await Get.to(
                                          () => (updateNoteForm(note)),
                                          transition: Transition.rightToLeft);
                                      if (updatedNote != null) {
                                        showMessageDialog("Success",
                                            "$updatedNote has been updated successfully");
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
                    return const Center(child: Text('No notes found'));
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 0, 89, 231),
        onPressed: () async {
          final data = await Get.to(() => (const AddNoteForm()),
              transition: Transition.rightToLeft);
          if (data != null) {
            showMessageDialog("Success", "$data has been added successfully");
            getRecord();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
