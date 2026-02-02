

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:task_app/pages/teacher_page.dart';
import 'package:task_app/pages/student_page.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  /// Teacher role select කිරීම + Name & Subject input
  Future<void> _selectTeacher(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final nameController = TextEditingController();
    final subjectController = TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Enter Teacher Details"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Enter Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: subjectController,
              decoration: const InputDecoration(
                labelText: "Enter Subject",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 50, 50, 241),
            ),
            onPressed: () async {
              final name = nameController.text.trim();
              final subject = subjectController.text.trim();

              if (name.isEmpty || subject.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Please fill all fields!"),
                  backgroundColor: Colors.red,
                ));
                return;
              }

              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .update({
                'role': 'teacher',
                'name': name,
                'subject': subject,
              });

              Navigator.of(dialogContext).pop();

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const TeacherPage()),
              );
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }

  /// Student role select කිරීම + Name & Class input
  Future<void> _selectStudent(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final nameController = TextEditingController();
    final classController = TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Enter Student Details"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Enter Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: classController,
              decoration: const InputDecoration(
                labelText: "Enter Class Name",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0B5739),
            ),
            onPressed: () async {
              final name = nameController.text.trim();
              final className = classController.text.trim();

              if (name.isEmpty || className.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Please fill all fields!"),
                  backgroundColor: Colors.red,
                ));
                return;
              }

              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .update({
                'role': 'student',
                'name': name,
                'class': className,
              });

              Navigator.of(dialogContext).pop();

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const StudentPage()),
              );
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color.fromARGB(255, 126, 44, 219), Color(0xFF3CA67B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Image at top
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Image.asset(
                        'assets/images/role_selection.png', // ✅ place your image here
                        height: 200,
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "Select Your Role",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Teacher Button
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color.fromARGB(255, 75, 9, 151),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 5,
                      ),
                      icon: const Icon(Icons.person, size: 28),
                      label: const Text(
                        "I'm a Teacher",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () => _selectTeacher(context),
                    ),
                    const SizedBox(height: 20),

                    // Student Button
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color.fromARGB(255, 75, 6, 135),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 5,
                      ),
                      icon: const Icon(Icons.school, size: 28),
                      label: const Text(
                        "I'm a Student",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () => _selectStudent(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
