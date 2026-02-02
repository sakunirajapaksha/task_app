

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:task_app/pages/sign_in.dart';

class StudentPage extends StatefulWidget {
  const StudentPage({super.key});

  @override
  State<StudentPage> createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  String? _userName;
  String? _userRole;
  bool _isLoadingUser = true;

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          _userName = doc['name'] ?? 'Unknown';
          _userRole = doc['role'] ?? 'Unknown';
          _isLoadingUser = false;
        });
      }
    } catch (e) {
      setState(() => _isLoadingUser = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading user data: $e')),
      );
    }
  }

  Future<void> _markTaskDone(DocumentSnapshot taskDoc) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final taskRef = _firestore.collection('tasks').doc(taskDoc.id);
    final data = taskDoc.data() as Map<String, dynamic>;
    final List records = data['records'] ?? [];

    final alreadyDone = records.any((r) => r['studentUID'] == user.uid);

    if (alreadyDone) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('You have already completed this task!'),
        backgroundColor: Colors.orange,
      ));
      return;
    }

    // Student record without grade
    final studentRecord = {
      'studentUID': user.uid,
      'studentEmail': user.email,
      'completedAt': Timestamp.now(),
    };

    await taskRef.update({
      'records': FieldValue.arrayUnion([studentRecord]),
    });

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Task marked as done!'),
      backgroundColor: Colors.green,
    ));
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: _isLoadingUser
            ? const Text("Loading...", style: TextStyle(color: Colors.white))
            : Row(
                children: [
                  const Icon(Icons.account_circle, color: Colors.white, size: 30),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _userName ?? 'No Name',
                        style: const TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      Text(
                        'Role: ${_userRole ?? 'Unknown'}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.white),
            tooltip: "Sign Out",
            onPressed: () async {
              await _auth.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const SigninScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 100),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('tasks')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(color: Colors.white));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        "No tasks available right now.",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    );
                  }

                  final tasks = snapshot.data!.docs;

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      final data = task.data() as Map<String, dynamic>;

                      final records = List<Map<String, dynamic>>.from(
                          data['records'] ?? []);
                      final studentRecord = records.firstWhere(
                        (r) => r['studentUID'] == user?.uid,
                        orElse: () => {},
                      );

                      final isDone = studentRecord.isNotEmpty;

                      // 🔹 Show teacher-assigned class
                      final taskClass = data['class'] ?? 'No class specified';

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: isDone
                                ? [Colors.grey.shade400, Colors.grey.shade600]
                                : [const Color(0xFF8E2DE2), const Color(0xFF4A00E0)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['title'] ?? 'No Title',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                data['description'] ?? 'No Description',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              // 🔹 Display class here
                              Text(
                                "Class: $taskClass",
                                style: const TextStyle(
                                  color: Colors.orangeAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton.icon(
                                  onPressed:
                                      isDone ? null : () => _markTaskDone(task),
                                  icon: Icon(
                                    isDone ? Icons.check_circle : Icons.done_all,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    isDone ? "Completed" : "Mark Done",
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 10),
                                    backgroundColor: isDone
                                        ? Colors.grey.shade700
                                        : const Color(0xFF00C853),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 6,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
