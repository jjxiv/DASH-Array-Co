import 'package:flutter/material.dart';

class UserInfoTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final Color textColor;
  final String image;

  const UserInfoTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    required this.textColor,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 5),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 16, 35, 65),
          borderRadius: BorderRadius.circular(50.0),
        ),
        child: Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(left: 16.0),
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Colors.white.withOpacity(0.7),
                  BlendMode.dstIn,
                ),
                child: Image.asset(
                  image,
                  width: 20.0,
                  height: 20.0,
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: TextField(
                  maxLength: 40,
                  controller: controller,
                  obscureText: obscureText,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(vertical: 20.0),
                    hintText: hintText,
                    hintStyle: const TextStyle(
                        color: Color.fromARGB(100, 255, 255, 255)),
                    counterText: "",
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
