import 'package:flutter/material.dart';

class HomeScreenList extends StatelessWidget {
  final String displayText;
  final String displayImg;
  final Function() onTap;

  const HomeScreenList({
    Key? key,
    required this.displayText,
    required this.displayImg,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: FractionallySizedBox(
          widthFactor: 0.5,
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(displayImg),
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
            alignment: Alignment.bottomLeft,
            height: 100,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                displayText,
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
