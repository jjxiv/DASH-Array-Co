import 'package:flutter/material.dart';

class HomeCard extends StatelessWidget {
  final String buttonText;
  final String imagePath;
  final VoidCallback onPressed;

  HomeCard({
    required this.buttonText,
    required this.imagePath,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: 150,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 16, 35, 65),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 3,
          ),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text(
                      buttonText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Image.asset(
                    imagePath,
                    width: 90,
                    height: 90,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
