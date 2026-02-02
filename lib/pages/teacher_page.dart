

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:task_app/pages/sign_in.dart';

class TeacherPage extends StatefulWidget {
  const TeacherPage({super.key});

  @override
  State<TeacherPage> createState() => _TeacherPageState();
}

class _TeacherPageState extends State<TeacherPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _classController = TextEditingController(); // 🔹 Added class controller
  DateTime? _selectedDate;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _teacherName;
  String? _teacherRole;

  @override
  void initState() {
    super.initState();
    _loadTeacherData();
  }

  Future<void> _loadTeacherData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (doc.exists) {
      final data = doc.data();
      setState(() {
        _teacherName = data?['name'] ?? 'Unknown Teacher';
        _teacherRole = data?['role'] ?? 'teacher';
      });
    }
  }

  Future<void> _addTask(BuildContext dialogContext) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final title = _titleController.text.trim();
    final desc = _descController.text.trim();
    final subject = _subjectController.text.trim();
    final className = _classController.text.trim(); // 🔹 class
    final date = _selectedDate;

    if (title.isEmpty || desc.isEmpty || subject.isEmpty || className.isEmpty || date == null) {
      ScaffoldMessenger.of(dialogContext).showSnackBar(
        const SnackBar(content: Text('Please fill all fields!'), backgroundColor: Colors.red),
      );
      return;
    }

    try {
      await _firestore.collection('tasks').add({
        'title': title,
        'description': desc,
        'subject': subject,
        'class': className, // 🔹 store class
        'date': Timestamp.fromDate(date),
        'createdBy': user.uid,
        'teacherName': _teacherName ?? '',
        'createdAt': Timestamp.now(),
        'records': [],
      });

      _clearControllers();
      Navigator.of(dialogContext).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Task added successfully!'), backgroundColor: Colors.indigo),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding task: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _editTask(String taskId, Map<String, dynamic> existingData) async {
    _titleController.text = existingData['title'] ?? '';
    _descController.text = existingData['description'] ?? '';
    _subjectController.text = existingData['subject'] ?? '';
    _classController.text = existingData['class'] ?? ''; // 🔹 class
    _selectedDate = (existingData['date'] as Timestamp?)?.toDate();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFFF5F4FA),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              title: const Text("Edit Task",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.indigo)),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildTextField("Task Title", _titleController, Icons.title),
                    const SizedBox(height: 10),
                    _buildTextField("Description", _descController, Icons.description, maxLines: 3),
                    const SizedBox(height: 10),
                    _buildTextField("Subject", _subjectController, Icons.book),
                    const SizedBox(height: 10),
                    _buildTextField("Class", _classController, Icons.class_), // 🔹 class
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          setState(() => _selectedDate = pickedDate);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.indigo.shade200),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedDate == null
                                  ? "Select Date"
                                  : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                              style: const TextStyle(fontSize: 16),
                            ),
                            const Icon(Icons.calendar_today, color: Colors.indigo),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text("Cancel", style: TextStyle(color: Colors.grey))),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  onPressed: () async {
                    final title = _titleController.text.trim();
                    final desc = _descController.text.trim();
                    final subject = _subjectController.text.trim();
                    final className = _classController.text.trim();
                    final date = _selectedDate;

                    if (title.isEmpty || desc.isEmpty || subject.isEmpty || className.isEmpty || date == null) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill all fields!'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    try {
                      await _firestore.collection('tasks').doc(taskId).update({
                        'title': title,
                        'description': desc,
                        'subject': subject,
                        'class': className, // 🔹 update class
                        'date': Timestamp.fromDate(date),
                      });

                      _clearControllers();
                      Navigator.pop(dialogContext);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✅ Task updated successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error updating task: $e')),
                      );
                    }
                  },
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: const Text("Save Changes", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _clearControllers() {
    _titleController.clear();
    _descController.clear();
    _subjectController.clear();
    _classController.clear();
    _selectedDate = null;
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.indigo),
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Future<void> _deleteTask(String taskId, String createdBy) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    if (createdBy != currentUser.uid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⚠️ You can only delete tasks you created!"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text("Delete Task", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Are you sure you want to delete this task permanently?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _firestore.collection('tasks').doc(taskId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🗑️ Task deleted successfully!'), backgroundColor: Colors.red),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting task: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _exitApp() async {
    await _auth.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const SigninScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: _teacherName == null
            ? const Text("Teacher Dashboard")
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_teacherName ?? '', style: const TextStyle(fontSize: 18)),
                  Text(_teacherRole ?? '',
                      style: const TextStyle(fontSize: 14, color: Colors.white70)),
                ],
              ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: "Logout",
            onPressed: _exitApp,
          ),
        ],
      ),
      floatingActionButton: (_teacherRole == "teacher")
          ? FloatingActionButton.extended(
              backgroundColor: Colors.indigo,
              onPressed: () => _showAddTaskDialog(),
              icon: const Icon(Icons.add),
              label: const Text("New Task"),
            )
          : null,
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('tasks').orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.indigo));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No tasks created yet."));
          }

          final tasks = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              final data = task.data() as Map<String, dynamic>;
              final date = (data['date'] as Timestamp?)?.toDate();
              final createdBy = data['createdBy'];
              final teacherName = data['teacherName'] ?? 'Unknown';
              final records = List<Map<String, dynamic>>.from(data['records'] ?? []);

              return Card(
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  title: Text(
                    data['title'] ?? 'No Title',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Text(
                    "Subject: ${data['subject']}  | Class: ${data['class'] ?? 'N/A'}",
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  childrenPadding: const EdgeInsets.all(10),
                  children: [
                    Text("📘 Description: ${data['description']}", style: const TextStyle(fontSize: 14)),
                    if (date != null) Text("📅 Date: ${DateFormat('yyyy-MM-dd').format(date)}"),
                    Text("👩‍🏫 Created by: $teacherName"),
                    const Divider(),
                    const Text("✅ Completed Students:", style: TextStyle(fontWeight: FontWeight.bold)),
                    if (records.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("No students completed yet."),
                      )
                    else
                      ...records.map((r) {
                        final completedAt = (r['completedAt'] as Timestamp?)?.toDate();
                        final studentEmail = r['studentEmail'] ?? 'Unknown Email';
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.indigo.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Colors.indigo,
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                            title: Text(studentEmail),
                            subtitle: completedAt != null
                                ? Text("⏰ ${DateFormat('yyyy-MM-dd – kk:mm').format(completedAt)}")
                                : null,
                          ),
                        );
                      }),
                    if (createdBy == currentUser?.uid)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () => _editTask(task.id, data),
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            label: const Text("Edit", style: TextStyle(color: Colors.blue)),
                          ),
                          TextButton.icon(
                            onPressed: () => _deleteTask(task.id, createdBy),
                            icon: const Icon(Icons.delete, color: Colors.red),
                            label: const Text("Delete", style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddTaskDialog() {
    _clearControllers();
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: const Color(0xFFF5F4FA),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: const Text("Create New Task",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.indigo)),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  _buildTextField("Task Title", _titleController, Icons.title),
                  const SizedBox(height: 10),
                  _buildTextField("Description", _descController, Icons.description, maxLines: 3),
                  const SizedBox(height: 10),
                  _buildTextField("Subject", _subjectController, Icons.book),
                  const SizedBox(height: 10),
                  _buildTextField("Class", _classController, Icons.class_), // 🔹 class
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        setState(() => _selectedDate = pickedDate);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.indigo.shade200),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedDate == null
                                ? "Select Date"
                                : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                            style: const TextStyle(fontSize: 16),
                          ),
                          const Icon(Icons.calendar_today, color: Colors.indigo),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text("Cancel", style: TextStyle(color: Colors.grey))),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                onPressed: () => _addTask(dialogContext),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text("Add Task", style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }
}


