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
  final List<String> faculties = ['Computer science', 'Architecture', 'Design', 'Business', 'IT', 'Telecommunication'];
  final List<String> majors = ['1', '2', '3', '4', '5', '6', '7', '8'];
  final List<String> semesters = ['1st semester', '2nd semester', '3rd semester', '4th semester', '5th semester', '6th semester', '7th semester', '8th semester', '9th semester', '10th semester'];
  final List<String> years = ['2000', '2001', '2002', '2003', '2004', '2005', '2006', '2007', '2008', '2009', '2010', '2011', '2012', '2013', '2014', '2015', '2016', '2017', '2018', '2019', '2020', '2021', '2022', '2023', '2024', '2025', '2026', '2027'];

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
                    return const Text("Error loading users", style: TextStyle(color: Colors.white));
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator(color: Colors.white));
                  }

                  final users = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return Card(
                        color: const Color(0xFF1A1D3A),
                        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Name: ${user['fullName']}", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text("Index: ${user['index']}", style: const TextStyle(color: Colors.white70, fontSize: 14)),
                              Text("Email: ${user['email']}", style: const TextStyle(color: Colors.white70, fontSize: 14)),
                              Text("GPA: ${user['gpa']}", style: const TextStyle(color: Colors.white70, fontSize: 14)),
                              Text("Faculty: ${user['faculty']}", style: const TextStyle(color: Colors.white70, fontSize: 14)),
                              Text("Semester: ${user['semester']}, Year: ${user['year']}", style: const TextStyle(color: Colors.white70, fontSize: 14)),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
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
                            ],
                          ),
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
              child: const Text("Add New User", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // Add User Dialog
  void _addUser() {
    _clearTextControllers();
    _showEditUserDialog();
  }

  // Edit User Function
  void _editUser(String userId, String name, String index, String password, String email, String faculty, String gpa, String majorId, String semester, String year) {
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
          title: Text(userId == null ? "Add User" : "Edit User", style: const TextStyle(color: Colors.white)),
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
                  value: faculties.contains(_selectedFaculty) ? _selectedFaculty : null,
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
                  value: majors.contains(_selectedMajor) ? _selectedMajor : null,
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
                  value: semesters.contains(_selectedSemester) ? _selectedSemester : null,
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
                  value: years.contains(_selectedYear) ? _selectedYear : null,
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
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel", style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () {
                if (userId == null) {
                  _addUserToFirestore();
                } else {
                  _updateUserInFirestore(userId);
                }
                Navigator.pop(context);
              },
              child: Text(userId == null ? "Add" : "Update", style: const TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );
  }

  // Firestore Functions
  void _addUserToFirestore() {
    // Logic to add user to Firestore
  }

  void _updateUserInFirestore(String userId) {
    // Logic to update user in Firestore
  }

  void _deleteUser(String userId) {
    // Logic to delete user from Firestore
  }

  void _deleteAllUsers() {
    // Logic to delete all users from Firestore
  }

  void _clearTextControllers() {
    _userIndexController.clear();
    _userPasswordController.clear();
    _userNameController.clear();
    _emailController.clear();
    _gpaController.clear();
    _selectedFaculty = null;
    _selectedMajor = null;
    _selectedSemester = null;
    _selectedYear = null;
  }
}
