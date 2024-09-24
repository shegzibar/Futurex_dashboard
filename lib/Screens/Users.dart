import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UsersPage extends StatefulWidget {
  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Controllers for user fields
  final TextEditingController _userIndexController = TextEditingController();
  final TextEditingController _userPasswordController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _facultyController = TextEditingController();
  final TextEditingController _gpaController = TextEditingController();
  final TextEditingController _majorIdController = TextEditingController();
  final TextEditingController _semesterController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        title: const Text('Manage Users', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF141A2E),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: _deleteAllUsers,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('Students').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text(
                      "Error loading users",
                      style: TextStyle(color: Colors.white),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  }

                  final users = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return ListTile(
                        title: Text(
                          "Name: ${user['fullName']}, Index: ${user['index']}, Email: ${user['email']}, GPA: ${user['gpa']}, Faculty: ${user['faculty']}",
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          "Semester: ${user['semester']}, Year: ${user['year']}, Major ID: ${user['majorId']}",
                          style: const TextStyle(color: Colors.white54),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.white),
                              onPressed: () {
                                _editUser(
                                  user.id,
                                  user['fullName'],
                                  user['index'],
                                  user['password'],
                                  user['email'],
                                  user['faculty'],
                                  user['gpa'].toString(),
                                  user['majorId'].toString(),
                                  user['semester'],
                                  user['year'].toString(),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _deleteUser(user.id);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _addUser,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text(
                "Add New User",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Add User Dialog
  void _addUser() {
    // Clear all controllers before adding a new user
    _clearTextControllers();
    _showEditUserDialog();
  }

  // Edit User Function
  void _editUser(
      String userId,
      String name,
      String index,
      String password,
      String email,
      String faculty,
      String gpa,
      String majorId,
      String semester,
      String year,
      ) {
    _userNameController.text = name;
    _userIndexController.text = index;
    _userPasswordController.text = password;
    _emailController.text = email;
    _facultyController.text = faculty;
    _gpaController.text = gpa;
    _majorIdController.text = majorId;
    _semesterController.text = semester;
    _yearController.text = year;
    _showEditUserDialog(userId: userId);
  }

  // Show User Edit Dialog
  void _showEditUserDialog({String? userId}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF141A2E),
          title: Text(
            userId == null ? "Add User" : "Edit User",
            style: const TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  style: const TextStyle(color: Colors.white),
                  controller: _userNameController,
                  decoration: const InputDecoration(
                    hintText: 'Full Name',
                    hintStyle: TextStyle(color: Colors.white54),
                  ),
                ),
                TextField(
                  style: const TextStyle(color: Colors.white),
                  controller: _emailController,
                  decoration: const InputDecoration(
                    hintText: 'Email',
                    hintStyle: TextStyle(color: Colors.white54),
                  ),
                ),
                TextField(
                  style: const TextStyle(color: Colors.white),
                  controller: _facultyController,
                  decoration: const InputDecoration(
                    hintText: 'Faculty',
                    hintStyle: TextStyle(color: Colors.white54),
                  ),
                ),
                TextField(
                  style: const TextStyle(color: Colors.white),
                  controller: _gpaController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'GPA',
                    hintStyle: TextStyle(color: Colors.white54),
                  ),
                ),
                TextField(
                  style: const TextStyle(color: Colors.white),
                  controller: _majorIdController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Major ID',
                    hintStyle: TextStyle(color: Colors.white54),
                  ),
                ),
                TextField(
                  style: const TextStyle(color: Colors.white),
                  controller: _semesterController,
                  decoration: const InputDecoration(
                    hintText: 'Semester',
                    hintStyle: TextStyle(color: Colors.white54),
                  ),
                ),
                TextField(
                  style: const TextStyle(color: Colors.white),
                  controller: _yearController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Year',
                    hintStyle: TextStyle(color: Colors.white54),
                  ),
                ),
                TextField(
                  style: const TextStyle(color: Colors.white),
                  controller: _userIndexController,
                  decoration: const InputDecoration(
                    hintText: 'Index',
                    hintStyle: TextStyle(color: Colors.white54),
                  ),
                ),
                TextField(
                  style: const TextStyle(color: Colors.white),
                  controller: _userPasswordController,
                  decoration: const InputDecoration(
                    hintText: 'Password',
                    hintStyle: TextStyle(color: Colors.white54),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                // Validate inputs if necessary
                if (_userNameController.text.isEmpty ||
                    _emailController.text.isEmpty ||
                    _userIndexController.text.isEmpty ||
                    _userPasswordController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Please fill in all required fields'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                if (userId == null) {
                  // Add new user to Firestore
                  try {
                    await _firestore.collection('Students').add({
                      'fullName': _userNameController.text,
                      'email': _emailController.text,
                      'faculty': _facultyController.text,
                      'gpa': double.tryParse(_gpaController.text) ?? 0.0,
                      'index': _userIndexController.text,
                      'majorId': int.tryParse(_majorIdController.text) ?? 0,
                      'password': _userPasswordController.text,
                      'semester': _semesterController.text,
                      'year': int.tryParse(_yearController.text) ?? 0,
                    });

                    Navigator.of(context).pop();

                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('User created successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    // Handle errors
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to create user: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } else {
                  // Update existing user
                  try {
                    await _firestore.collection('Students').doc(userId).update({
                      'fullName': _userNameController.text,
                      'email': _emailController.text,
                      'faculty': _facultyController.text,
                      'gpa': double.tryParse(_gpaController.text) ?? 0.0,
                      'index': _userIndexController.text,
                      'majorId': int.tryParse(_majorIdController.text) ?? 0,
                      'password': _userPasswordController.text,
                      'semester': _semesterController.text,
                      'year': int.tryParse(_yearController.text) ?? 0,
                    });

                    Navigator.of(context).pop();

                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('User updated successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    // Handle errors
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to update user: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  // Delete a specific user
  void _deleteUser(String userId) async {
    try {
      await _firestore.collection('Students').doc(userId).delete();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('User deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete user: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Delete all users
  void _deleteAllUsers() async {
    final usersCollection = _firestore.collection('Students');
    var snapshots = await usersCollection.get();

    for (var doc in snapshots.docs) {
      await doc.reference.delete();
    }

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('All users deleted successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Clear all text controllers
  void _clearTextControllers() {
    _userNameController.clear();
    _emailController.clear();
    _facultyController.clear();
    _gpaController.clear();
    _majorIdController.clear();
    _semesterController.clear();
    _yearController.clear();
    _userIndexController.clear();
    _userPasswordController.clear();
  }

  @override
  void dispose() {
    // Dispose controllers when the widget is disposed
    _userNameController.dispose();
    _emailController.dispose();
    _facultyController.dispose();
    _gpaController.dispose();
    _majorIdController.dispose();
    _semesterController.dispose();
    _yearController.dispose();
    _userIndexController.dispose();
    _userPasswordController.dispose();
    super.dispose();
  }
}
