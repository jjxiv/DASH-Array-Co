import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String? id;
  final String fullName;
  final String email;
  final String password;

  const UserModel({
    this.id,
    required this.fullName,
    required this.email,
    required this.password,
  });

  // Converts to Json
  toJson() {
    return {
      "FullName": fullName,
      "Email": email,
      "Password": password,
    };
  }

  // Map user fetched from Firebase to UserModel
  factory UserModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    return UserModel(
        id: document.id,
        fullName: data["FullName"],
        email: data["Email"],
        password: data["Password"]);
  }
}
