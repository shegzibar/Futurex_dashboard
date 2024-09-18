import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UsersPage extends StatefulWidget {
  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _facultyController = TextEditingController();
  final TextEditingController _gpaController = TextEditingController();
  final TextEditingController _indexController = TextEditingController();
  final TextEditingController _majorIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _semesterController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();

  // Method to validate fields before saving
  bool _validateFields() {
    if (_fullNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _facultyController.text.isEmpty ||
        _gpaController.text.isEmpty ||
        _indexController.text.isEmpty ||
        _majorIdController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _semesterController.text.isEmpty ||
        _yearController.text.isEmpty) {
      return false;
    }
    return true;
  }

  // Method to build text fields
  Widget _buildTextField(TextEditingController controller, String labelText, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(labelText: labelText),
    );
  }

  // Show User Edit Dialog
  void _showEditUserDialog({String? userId}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF141A2E),
          title: Text(userId == null ? "Add User" : "Edit User",
              style: const TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(_fullNameController, 'Full Name'),
                _buildTextField(_emailController, 'Email'),
                _buildTextField(_facultyController, 'Faculty'),
                _buildTextField(_gpaController, 'GPA', isNumber: true),
                _buildTextField(_indexController, 'Index', isNumber: true),
                _buildTextField(_majorIdController, 'Major ID', isNumber: true),
                _buildTextField(_passwordController, 'Password'),
                _buildTextField(_semesterController, 'Semester'),
                _buildTextField(_yearController, 'Year', isNumber: true),  // Ensure year accepts numbers
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (_validateFields()) {
                  if (userId == null) {
                    // Add new user
                    _firestore.collection('Students').doc(_indexController.text).set({
                      'fullName': _fullNameController.text,
                      'email': _emailController.text,
                      'faculty': _facultyController.text,
                      'gpa': double.tryParse(_gpaController.text) ?? 0.0,
                      'index': int.parse(_indexController.text),
                      'majorId': int.parse(_majorIdController.text),
                      'password': _passwordController.text,
                      'semester': _semesterController.text,
                      'year': int.tryParse(_yearController.text) ?? 0, // Parse as int
                    });
                  } else {
                    // Update existing user
                    _firestore.collection('Students').doc(userId).update({
                      'fullName': _fullNameController.text,
                      'email': _emailController.text,
                      'faculty': _facultyController.text,
                      'gpa': double.tryParse(_gpaController.text) ?? 0.0,
                      'index': int.parse(_indexController.text),
                      'majorId': int.parse(_majorIdController.text),
                      'password': _passwordController.text,
                      'semester': _semesterController.text,
                      'year': int.tryParse(_yearController.text) ?? 0, // Parse as int
                    });
                  }
                  Navigator.of(context).pop();
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit User'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _showEditUserDialog(),
          child: const Text('Show Edit Dialog'),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _facultyController.dispose();
    _gpaController.dispose();
    _indexController.dispose();
    _majorIdController.dispose();
    _passwordController.dispose();
    _semesterController.dispose();
    _yearController.dispose();
    super.dispose();
  }
}
