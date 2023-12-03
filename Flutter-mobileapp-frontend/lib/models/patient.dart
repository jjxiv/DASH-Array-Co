import 'dart:convert';

List<Patient> patientFromJson(String str) => List<Patient>.from(json.decode(str).map((x) => Patient.fromJson(x)));

String patientToJson(List<Patient> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Patient {
  int id;
  String name;
  String contact;
  String email;
  String shade;
  String owner;
  String note;
  String date;
  String image;

  Patient({
    required this.contact,
    required this.email,
    required this.id,
    required this.image,
    required this.owner,
    required this.name,
    required this.note,
    required this.shade,
    required this.date,
  });

  factory Patient.fromJson(Map<String, dynamic> json) => Patient(
    contact: json["contact"],
    email: json["email"],
    id: json["id"],
    image: json["image"],
    owner: json["owner"],
    name: json["name"],
    note: json["note"],
    shade: json["shade"],
    date: json["date"],
  );

  Map<String, dynamic> toJson() => {
    "contact": contact,
    "email": email,
    "id": id,
    "image": image,
    "owner":owner,
    "name": name,
    "note": note,
    "shade": shade,
    "date": date
  };

  @override
  String toString(){
    String result = name;
    return result;
  }
}
