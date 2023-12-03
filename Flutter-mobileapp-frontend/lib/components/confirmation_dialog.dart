import 'package:flutter/material.dart';

Future<void> showConfirmationDialog(
  BuildContext context,
  String title,
  List<Widget> content,
  IconData iconData,
  VoidCallback onNavigate,
) async {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 0, 89, 231),
            borderRadius: BorderRadius.circular(15),
          ),
          width: 300,
          height: 120,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        // Icon
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Icon(
                            iconData,
                            color: Colors.white,
                            size: 25.0,
                          ),
                        ),
                        // Title
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                          ),
                        ),
                      ],
                    ),
                    // Close
                    IconButton(
                      icon: const Icon(Icons.close,
                          color: Colors.white, size: 20.0),
                      onPressed: () {
                        Navigator.of(context).pop();
                        onNavigate();
                      },
                    ),
                  ],
                ),
                // Items
                Padding(
                  padding: const EdgeInsets.only(left: 50.0, right: 10.0),
                  child: SingleChildScrollView(
                    child: ListBody(
                      children: content.map((widget) {
                        if (widget is Text) {
                          return Text(
                            widget.data!,
                            style: const TextStyle(color: Colors.white),
                          );
                        } else {
                          return widget;
                        }
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
