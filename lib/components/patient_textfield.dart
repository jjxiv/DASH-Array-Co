import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumericTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Use a regular expression to remove non-numeric characters
    final newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

bool isFieldEmpty(String value) {
  return value.trim().isEmpty;
}

class PatientTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final Color textColor;
  final String image;
  final bool numericalOnly;
  final int textLength;

  const PatientTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    required this.textColor,
    required this.image,
    required this.numericalOnly,
    required this.textLength,
  }) : super(key: key);

  @override
  _PatientTextFieldState createState() => _PatientTextFieldState();
}

class _PatientTextFieldState extends State<PatientTextField> {
  String? errorText;

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
                  widget.image,
                  width: 20.0,
                  height: 20.0,
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: TextField(
                  inputFormatters: widget.numericalOnly
                      ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))]
                      : null,
                  maxLength: widget.textLength,
                  controller: widget.controller,
                  obscureText: widget.obscureText,
                  style: TextStyle(color: widget.textColor),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(vertical: 20.0),
                    hintText: widget.hintText,
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

  void validateField() {
    final text = widget.controller.text;
    if (isFieldEmpty(text)) {
      setState(() {
        errorText = 'Field cannot be empty';
      });
    } else {
      setState(() {
        errorText = null;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Add a listener to the controller to trigger validation when the text changes.
    widget.controller.addListener(validateField);
  }

  @override
  void dispose() {
    // Don't forget to remove the listener when disposing of the widget.
    widget.controller.removeListener(validateField);
    super.dispose();
  }
}
