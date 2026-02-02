import 'package:flutter/material.dart';

class HeaderText extends StatelessWidget {
  final String text;
  const HeaderText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 52, 33, 227),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}