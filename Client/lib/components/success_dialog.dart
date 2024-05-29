import 'package:flutter/material.dart';

class SuccessDialog extends StatelessWidget {
  final String message;
  final VoidCallback onPressed;

  const SuccessDialog({super.key, required this.message, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'lib/assets/success.png',
            height: 100,
            width: 100,
          ),
          const SizedBox(height: 10),
          const Text(
            'Success!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
      content: Text(message),
      actions: <Widget>[
        Center(
          child: TextButton(
            onPressed: onPressed,
            child: const Text('Okay'),
          ),
        ),
      ],
    );
  }
}
