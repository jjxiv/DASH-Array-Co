import 'dart:convert';

List<Note> noteFromJson(String str) => List<Note>.from(json.decode(str).map((x) => Note.fromJson(x)));

String noteToJson(List<Note> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Note {
  int id;
  String owner;
  String name;
  String note;

  Note({
    required this.id,
    required this.owner,
    required this.name,
    required this.note,
  });

  factory Note.fromJson(Map<String, dynamic> json) => Note(
    id: json["id"],
    owner: json["owner"],
    name: json["name"],
    note: json["note"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "owner":owner,
    "name": name,
    "note": note,
  };

  @override
  String toString(){
    String result = name;
    return result;
  }
}
