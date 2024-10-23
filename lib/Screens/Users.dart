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
  final TextEditingController _gpaController = TextEditingController();

  // Dropdown selections
  String? _selectedFaculty;
  String? _selectedMajor;
  String? _selectedSemester;
  String? _selectedYear;

  // Dropdown lists
  final List<String> faculties = ['Computer science', 'Architecture', 'Design ', 'Business','IT','Telecommunication'];
  final List<String> majors = ['1', '2', '3', '4','5','6','7','8']; // Replace with actual major IDs
  final List<String> semesters = ['1st semester', '2nd semester', '3rd semester','4th semester','5th semester','6th semester','7th semester','8th semester','9th semester','10th semester'];
  final List<String> years = ['2000', '2001', '2002', '2003', '2004','2005','2006','2007','2008','2009','2010','2011','2012','2013','2014','2015','2016','2017','2018','2019','2020','2021','2022','2023','2024','2025','2026','2027']; // For undergrad years

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
    _gpaController.text = gpa;
    _selectedFaculty = faculty;
    _selectedMajor = majorId;
    _selectedSemester = semester;
    _selectedYear = year;
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
                DropdownButtonFormField<String>(
                  value: _selectedFaculty,
                  dropdownColor: const Color(0xFF141A2E),
                  decoration: const InputDecoration(
                    hintText: 'Faculty',
                    hintStyle: TextStyle(color: Colors.white54),
                  ),
                  items: faculties.map((String faculty) {
                    return DropdownMenuItem<String>(
                      value: faculty,
                      child: Text(faculty, style: const TextStyle(color: Colors.white)),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedFaculty = newValue;
                    });
                  },
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
                DropdownButtonFormField<String>(
                  value: _selectedMajor,
                  dropdownColor: const Color(0xFF141A2E),
                  decoration: const InputDecoration(
                    hintText: 'Major ID',
                    hintStyle: TextStyle(color: Colors.white54),
                  ),
                  items: majors.map((String majorId) {
                    return DropdownMenuItem<String>(
                      value: majorId,
                      child: Text(majorId, style: const TextStyle(color: Colors.white)),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedMajor = newValue;
                    });
                  },
                ),
                DropdownButtonFormField<String>(
                  value: _selectedSemester,
                  dropdownColor: const Color(0xFF141A2E),
                  decoration: const InputDecoration(
                    hintText: 'Semester',
                    hintStyle: TextStyle(color: Colors.white54),
                  ),
                  items: semesters.map((String semester) {
                    return DropdownMenuItem<String>(
                      value: semester,
                      child: Text(semester, style: const TextStyle(color: Colors.white)),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedSemester = newValue;
                    });
                  },
                ),
                DropdownButtonFormField<String>(
                  value: _selectedYear,
                  dropdownColor: const Color(0xFF141A2E),
                  decoration: const InputDecoration(
                    hintText: 'Year',
                    hintStyle: TextStyle(color: Colors.white54),
                  ),
                  items: years.map((String year) {
                    return DropdownMenuItem<String>(
                      value: year,
                      child: Text(year, style: const TextStyle(color: Colors.white)),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedYear = newValue;
                    });
                  },
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

                final userIndex = _userIndexController.text;

                try {
                  if (userId == null) {
                    // Check if user with the same index already exists
                    final existingUser = await _firestore.collection('Students').doc(userIndex).get();
                    if (existingUser.exists) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('User with this index already exists'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    // Add new user with index as document ID
                    await _firestore.collection('Students').doc(userIndex).set({
                      'fullName': _userNameController.text,
                      'email': _emailController.text,
                      'faculty': _selectedFaculty,
                      'gpa': double.tryParse(_gpaController.text) ?? 0.0,
                      'index': userIndex,
                      'majorId': int.tryParse(_selectedMajor ?? '0') ?? 0,
                      'password': _userPasswordController.text,
                      'semester': _selectedSemester,
                      'year': int.tryParse(_selectedYear ?? '0') ?? 0,
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('User created successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    // Update existing user
                    await _firestore.collection('Students').doc(userId).update({
                      'fullName': _userNameController.text,
                      'email': _emailController.text,
                      'faculty': _selectedFaculty,
                      'gpa': double.tryParse(_gpaController.text) ?? 0.0,
                      'index': userIndex,
                      'majorId': int.tryParse(_selectedMajor ?? '0') ?? 0,
                      'password': _userPasswordController.text,
                      'semester': _selectedSemester,
                      'year': int.tryParse(_selectedYear ?? '0') ?? 0,
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('User updated successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }

                  Navigator.of(context).pop();
                } catch (e) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to save user: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('User deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
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
    _gpaController.clear();
    _userIndexController.clear();
    _userPasswordController.clear();
    _selectedFaculty = null;
    _selectedMajor = null;
    _selectedSemester = null;
    _selectedYear = null;
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _emailController.dispose();
    _gpaController.dispose();
    _userIndexController.dispose();
    _userPasswordController.dispose();
    super.dispose();
  }
}
