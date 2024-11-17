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
  final List<String> faculties = [
    'Computer Science',
    'Architecture',
    'Design',
    'Business',
    'IT',
    'Telecommunication',
    'Engineering'
  ];
  final List<String> majors = ['1', '2', '3', '4', '5', '6', '7', '8'];
  final List<String> semesters = [
    '1st semester',
    '2nd semester',
    '3rd semester',
    '4th semester',
    '5th semester',
    '6th semester',
    '7th semester',
    '8th semester',
    '9th semester',
    '10th semester'
  ];
  final List<String> years = [
    for (int i = 2000; i <= 2027; i++) i.toString()
  ];

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
                    return const Text("Error loading users",
                        style: TextStyle(color: Colors.white));
                  }

                  if (!snapshot.hasData) {
                    return const Center(
                        child: CircularProgressIndicator(color: Colors.white));
                  }

                  final users = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return Card(
                        color: const Color(0xFF1A1D3A),
                        margin: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 0.0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Name: ${user['fullName']}",
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text("Index: ${user['index']}",
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 14)),
                              Text("Password: ${user['password']}",
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 14)),
                              Text("Email: ${user['email']}",
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 14)),
                              Text("GPA: ${user['gpa']}",
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 14)),
                              Text(
                                  "Faculty: ${user['faculty']}",
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 14)),
                              Text(
                                  "Semester: ${user['semester']}, Year: ${user['year']}",
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 14)),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.white),
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
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
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
              child: const Text("Add New User",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _addUser() {
    _clearTextControllers();
    _showEditUserDialog();
  }

  void _addUserToFirestore() {
    final indexToCheck = _userIndexController.text;

    if (indexToCheck.isEmpty) {
      _showErrorDialog("Index field cannot be empty!");
      return;
    }

    _firestore
        .collection('Students')
        .where('index', isEqualTo: indexToCheck)
        .get()
        .then((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        _showErrorDialog("This index already exists. Please use a unique index.");
      } else {
        _firestore.collection('Students').add({
          'fullName': _userNameController.text,
          'index': _userIndexController.text,
          'password': _userPasswordController.text,
          'email': _emailController.text,
          'gpa': double.tryParse(_gpaController.text) ?? 0.0,
          'faculty': _selectedFaculty,
          'majorId': _selectedMajor,
          'semester': _selectedSemester,
          'year': _selectedYear,
        });
        _showSuccessDialog("User added successfully!");
      }
    }).catchError((error) {
      _showErrorDialog("An error occurred while checking the index: $error");
    });
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

  void _showEditUserDialog({bool isEditing = false, String? userId}) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1A1D3A),
              title: Text(isEditing ? "Edit User" : "Add New User",
                  style: const TextStyle(color: Colors.white)),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildTextField("Index", _userIndexController),
                    _buildTextField("Name", _userNameController),
                    _buildTextField("Password", _userPasswordController),
                    _buildTextField("Email", _emailController),
                    _buildTextField("GPA", _gpaController),
                    _buildDropdown("Faculty", faculties, (value) {
                      setState(() => _selectedFaculty = value);
                    }, _selectedFaculty),
                    _buildDropdown("Major", majors, (value) {
                      setState(() => _selectedMajor = value);
                    }, _selectedMajor),
                    _buildDropdown("Semester", semesters, (value) {
                      setState(() => _selectedSemester = value);
                    }, _selectedSemester),
                    _buildDropdown("Year", years, (value) {
                      setState(() => _selectedYear = value);
                    }, _selectedYear),
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
                    if (isEditing && userId != null) {
                      _updateUserInFirestore(userId);
                    } else {
                      _addUserToFirestore();
                    }
                    Navigator.pop(context);
                  },
                  child: const Text("Save", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _editUser(String id, String name, String index, String password,
      String email, String faculty, String gpa, String majorId, String semester, String year) {
    _userNameController.text = name;
    _userIndexController.text = index;
    _userPasswordController.text = password;
    _emailController.text = email;
    _gpaController.text = gpa;
    _selectedFaculty = faculty;
    _selectedMajor = majorId;
    _selectedSemester = semester;
    _selectedYear = year;

    _showEditUserDialog(isEditing: true, userId: id);
  }

  void _updateUserInFirestore(String userId) {
    _firestore.collection('Students').doc(userId).update({
      'fullName': _userNameController.text,
      'index': _userIndexController.text,
      'password': _userPasswordController.text,
      'email': _emailController.text,
      'gpa': double.tryParse(_gpaController.text) ?? 0.0,
      'faculty': _selectedFaculty,
      'majorId': _selectedMajor,
      'semester': _selectedSemester,
      'year': _selectedYear,
    }).then((_) {
      _showSuccessDialog("User updated successfully!");
    }).catchError((error) {
      _showErrorDialog("An error occurred while updating the user: $error");
    });
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildDropdown(
      String label, List<String> items, ValueChanged<String?> onChanged, String? selectedValue) {
    return DropdownButton<String>(
      hint: Text(label, style: const TextStyle(color: Colors.white)),
      dropdownColor: const Color(0xFF1A1D3A),
      value: items.contains(selectedValue) ? selectedValue : null, // Ensures selected value is valid
      onChanged: onChanged,
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item, style: const TextStyle(color: Colors.white)),
        );
      }).toList(),
    );
  }


  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1D3A),
          title: const Text("Error", style: TextStyle(color: Colors.white)),
          content: Text(message, style: const TextStyle(color: Colors.white)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("OK", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1D3A),
          title: const Text("Success", style: TextStyle(color: Colors.white)),
          content: Text(message, style: const TextStyle(color: Colors.white)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("OK", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _deleteUser(String id) {
    _firestore.collection('Students').doc(id).delete();
  }

  void _deleteAllUsers() {
    _firestore.collection('Students').get().then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.delete();
      }
    });
  }
}
