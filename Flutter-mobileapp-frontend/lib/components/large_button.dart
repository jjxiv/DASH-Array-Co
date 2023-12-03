import 'package:flutter/material.dart';

class LargeButton extends StatelessWidget {
  final String buttonText;
  final Function()? onTap;
  final Color color;
  final Color textcolor;

  const LargeButton({
    super.key,
    required this.buttonText,
    required this.onTap,
    required this.color,
    required this.textcolor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 50,
      child: ElevatedButton(
        onPressed: onTap,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(color),
          shape: MaterialStateProperty.all(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          )),
        ),
        child: Text(buttonText, style: TextStyle(color: textcolor)),
      ),
    );
  }
}
