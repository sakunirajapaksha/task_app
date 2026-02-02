import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  const LogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: Image.asset(
        'assets/icon.png',
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      ),
    );
  }
}