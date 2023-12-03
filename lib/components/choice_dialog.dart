import 'package:flutter/material.dart';

enum DialogAction { ok, cancel }

Future<void> showChoiceDialog(
  BuildContext context,
  String title,
  List<Widget> content,
  IconData iconData,
  VoidCallback onNavigate,
  Function(DialogAction) onAction,
) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: const Color.fromARGB(255, 0, 89, 231),
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Icon(
                iconData,
                color: Colors.white,
                size: 25.0,
              ),
            ),
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: SingleChildScrollView(
                child: ListBody(
                  children: content,
                ),
              ),
            ),
            ButtonBar(
              children: <Widget>[
                TextButton(
                  child: Text('Cancel', style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    Navigator.of(context).pop();
                    onAction(DialogAction.cancel);
                  },
                ),
                TextButton(
                  child: Text('OK', style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    Navigator.of(context).pop();
                    onAction(DialogAction.ok);
                  },
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}
