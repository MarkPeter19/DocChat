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
      content: Text(message, style: const TextStyle(fontSize: 16),),
      actions: <Widget>[
        Center(
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 68, 144, 101),
              padding: const EdgeInsets.symmetric(
                  vertical: 10, horizontal: 20),
            ),
            child: const Text('Okay',
                style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }
}
