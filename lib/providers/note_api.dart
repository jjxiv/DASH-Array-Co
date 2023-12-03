import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:dash/models/note.dart';
import 'dart:io';

class NoteApi {
  get path => null;
  // String email = EmailManager().email;
  String? email = FirebaseAuth.instance.currentUser?.email.toString();
  String? ownerEmail = FirebaseAuth.instance.currentUser?.email.toString();
  String httpLink = "http://array-co.online";

  //establish connection notes
  Future<List<Note>?> getAllNotes() async {
    var client = http.Client();
    var uri = Uri.parse("$httpLink/note/$email");
    print("Value of email is $email");
    var response = await client.get(uri);
    if (response.statusCode == 200) {
      var json = response.body;
      return noteFromJson(json);
    } else {
      print('Error: ${response.statusCode} - ${response.reasonPhrase}');
      return null;
    }
  }

  Stream<List<Note>> pollNotes(Duration duration) async* {
    while (true) {
      await Future.delayed(duration);
      List<Note>? notes = await getAllNotes();
      if (notes != null) {
        yield notes;
      }
    }
  }

  // Add patient
  Future<Note>? addNote(String owner, String name, String note) async {
    var client = http.Client();
    var uri = Uri.parse("$httpLink/note");
    final http.Response response = await client.post(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(
          <String, String>{'owner': ownerEmail!, 'name': name, 'note': note}),
    );

    if (response.statusCode == 200) {
      var json = response.body;
      return Note.fromJson(jsonDecode(json));
    } else {
      throw Exception('Failed to save notes');
    }
  }

  // Delete patient
  Future<Note>? deleteNote(int id) async {
    var client = http.Client();
    var uri = Uri.parse("$httpLink/note/$id");
    final http.Response response =
        await client.delete(uri, headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    });
    if (response.statusCode == 200) {
      var json = response.body;
      return Note.fromJson(jsonDecode(json));
    } else {
      throw Exception('Failed to delete note');
    }
  }

  // Update patient
  Future<Note>? updateNote(int id, String name, String note) async {
    var client = http.Client();
    var uri = Uri.parse("$httpLink/note/$id");
    final http.Response response = await client.put(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'name': name, 'note': note}),
    );
    if (response.statusCode == 200) {
      var json = response.body;
      return Note.fromJson(jsonDecode(json));
    } else {
      throw Exception('Failed to update notes');
    }
  }
}
