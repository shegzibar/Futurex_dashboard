import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UsersPage extends StatefulWidget {
  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _userIndexController = TextEditingController();
  final TextEditingController _userPasswordController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();  // Added controller for name

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        title: const Text('Manage Users',style: TextStyle(color: Colors.white),),
        leading: IconButton(onPressed: (){Navigator.pop(context);}, icon: Icon(Icons.arrow_back ,color: Colors.white,)),
        backgroundColor: const Color(0xFF141A2E),
        
        actions: [
          // Delete All Button
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
                    return Center(child: const CircularProgressIndicator(color: Colors.white,));
                  }

                  final users = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return ListTile(
                        title: Text(
                          "Name: ${user['fullName']}, Index: ${user['index']}, Password: ${user['password']}",
                          style: const TextStyle(color: Colors.white),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.white),
                              onPressed: () {
                                _editUser(user.id, user['fullName'], user['index'], user['password']);
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
              onPressed: () {
                _addUser();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text("Add New User",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
            ),
          ],
        ),
      ),
    );
  }

  // Add User Dialog
  void _addUser() {
    _showEditUserDialog();
  }

  // Edit User Function
  void _editUser(String userId, String name, String index, String password) {
    _userNameController.text = name;  // Set name in the text field
    _userIndexController.text = index;
    _userPasswordController.text = password;
    _showEditUserDialog(userId: userId);
  }

  // Show User Edit Dialog
  void _showEditUserDialog({String? userId}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF141A2E),
          title: const Text("Edit User", style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                style: TextStyle(
                  color: Colors.white, // Replace with your desired color
                ),
                controller: _userNameController,  // TextField for name
                decoration: const InputDecoration(hintText: 'User Name'),
              ),
              TextField(
                style: TextStyle(
                  color: Colors.white, // Replace with your desired color
                ),
                controller: _userIndexController,
                decoration: const InputDecoration(hintText: 'User Index'),
              ),
              TextField(
                style: TextStyle(
                  color: Colors.white, // Replace with your desired color
                ),
                controller: _userPasswordController,
                decoration: const InputDecoration(hintText: 'User Password'),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (userId == null) {
                  _firestore.collection('users').add({
                    'name': _userNameController.text,  // Add name to Firestore
                    'index': _userIndexController.text,
                    'password': _userPasswordController.text,
                  });
                } else {
                  _firestore.collection('users').doc(userId).update({
                    'name': _userNameController.text,  // Update name in Firestore
                    'index': _userIndexController.text,
                    'password': _userPasswordController.text,
                  });
                }
                Navigator.of(context).pop();
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  // Delete a specific user
  void _deleteUser(String userId) {
    _firestore.collection('users').doc(userId).delete();
  }

  // Delete all users
  void _deleteAllUsers() async {
    final usersCollection = _firestore.collection('users');

    // Get all documents in the 'users' collection
    var snapshots = await usersCollection.get();

    for (var doc in snapshots.docs) {
      await doc.reference.delete(); // Delete each document
    }
  }
}
