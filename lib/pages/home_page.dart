

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<String> _getUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return "User";

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    return doc.data()?['name'].split(" ").first ?? "User";
    //return fullName.split(" ").first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  backgroundColor: const Color(0xFF0B5739),
  title: FutureBuilder<String>(
    future: _getUserName(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Text('Loading...', style: textStyle());
      } else if (snapshot.hasError) {
        return Text('Error', style: textStyle());
      } else {
        return Text('Welcome, ${snapshot.data}', style: textStyle());
      }
    },
  ),
),

      body: const Center(
        child: Text('Welcome to the Home Page!'),
      ),
    );
  }
}

TextStyle textStyle() {
  return const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );
}