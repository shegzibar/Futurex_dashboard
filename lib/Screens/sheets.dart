import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class SheetsPage extends StatefulWidget {
  const SheetsPage({super.key});

  @override
  State<SheetsPage> createState() => _SheetsPageState();
}

class _SheetsPageState extends State<SheetsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final TextEditingController _nameController = TextEditingController();

  // Method to create a new sheet
  Future<void> _createSheet() async {
    String sheetName = _nameController.text;
    if (sheetName.isEmpty) return;

    // Prompt user to select a PDF file
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null && result.files.single.path != null) {
      // Get the PDF file path (null-safe)
      final filePath = result.files.single.path!;
      final storageRef = _storage.ref('sheets/$sheetName.pdf');

      // Upload the PDF to Firebase Storage
      await storageRef.putFile(File(filePath));

      // Get the URL of the uploaded PDF
      final pdfUrl = await storageRef.getDownloadURL();

      // Add the sheet document to Firestore
      await _firestore.collection('sheets').add({
        'name': sheetName,
        'pdfUrl': pdfUrl,
      });

      _nameController.clear();
    }
  }

  // Method to read sheets from Firestore
  Stream<QuerySnapshot> _readSheets() {
    return _firestore.collection('sheets').snapshots();
  }

  // Method to update an existing sheet
  Future<void> _updateSheet(String id) async {
    String sheetName = _nameController.text;
    if (sheetName.isEmpty) return;

    // Prompt user to select a PDF file
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null && result.files.single.path != null) {
      // Get the PDF file path (null-safe)
      final filePath = result.files.single.path!;
      final storageRef = _storage.ref('gs://futurex-19db0.appspot.com/$sheetName.pdf');

      // Upload the new PDF to Firebase Storage
      await storageRef.putFile(File(filePath));

      // Get the URL of the updated PDF
      final pdfUrl = await storageRef.getDownloadURL();

      // Update the Firestore document
      await _firestore.collection('sheets').doc(id).update({
        'name': sheetName,
        'pdfUrl': pdfUrl,
      });

      _nameController.clear();
    }
  }

  // Method to delete a sheet
  Future<void> _deleteSheet(String id, String sheetName) async {
    try {
      // Delete from Firebase Storage
      final storageRef = _storage.ref('sheets/$sheetName.pdf');
      await storageRef.delete();
    } catch (e) {
      // Handle the case where the file may not exist in storage
      print("Error deleting PDF from storage: $e");
    }

    // Delete from Firestore
    await _firestore.collection('sheets').doc(id).delete();
  }

  // Dialog for creating or updating sheets
  Future<void> _showSheetDialog({String? id, String? name}) async {
    _nameController.text = name ?? '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          title: Text(id == null ? 'Add Sheet' : 'Update Sheet', style: const TextStyle(color: Colors.white)),
          content: TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Sheet Name', labelStyle: TextStyle(color: Colors.white)),
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(id == null ? 'Create' : 'Update', style: const TextStyle(color: Colors.green)),
              onPressed: () {
                if (id == null) {
                  _createSheet();
                } else {
                  _updateSheet(id);
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        title: const Text('Sheets'),
        backgroundColor: const Color(0xFF141A2E),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showSheetDialog(),
        backgroundColor: const Color(0xFF141A2E),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _readSheets(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading sheets', style: TextStyle(color: Colors.red)));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              Map<String, dynamic> sheet = doc.data() as Map<String, dynamic>;
              String sheetName = sheet['name'] ?? 'No Name';
              String pdfUrl = sheet['pdfUrl'] ?? 'No PDF URL';

              return Card(
                color: const Color(0xFF1A1A2E),
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(sheetName, style: const TextStyle(color: Colors.white)),
                  subtitle: Text(pdfUrl, style: const TextStyle(color: Colors.white70)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showSheetDialog(id: doc.id, name: sheetName),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteSheet(doc.id, sheetName),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
