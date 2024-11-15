import 'dart:io' if (dart.library.html) 'dart:html' as html;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';

class InstructionListPage extends StatefulWidget {
  const InstructionListPage({Key? key}) : super(key: key);

  @override
  _InstructionListPageState createState() => _InstructionListPageState();
}

class _InstructionListPageState extends State<InstructionListPage> {
  final TextEditingController _documentNameController = TextEditingController();
  final TextEditingController _p1Controller = TextEditingController();
  final TextEditingController _p2Controller = TextEditingController();
  final TextEditingController _p3Controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  String? _p1ImageUrl, _p2ImageUrl, _p3ImageUrl;

  Future<String?> _uploadImage(XFile image, String paragraph) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child('instruction_images/${paragraph}_${DateTime.now()}.jpg');

      if (kIsWeb) {
        // Web-specific image upload using Uint8List
        Uint8List bytes = await image.readAsBytes();
        await storageRef.putData(bytes);
      } else {
        // Mobile-specific image upload using File
        await storageRef.putFile(File(image.path));
      }

      return await storageRef.getDownloadURL();
    } catch (e) {
      print("Error uploading $paragraph image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error uploading $paragraph image: $e")),
      );
      return null;
    }
  }

  Future<void> _pickImage(String paragraph) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final url = await _uploadImage(image, paragraph);
      if (mounted) { // Check if widget is still in memory
        setState(() {
          if (paragraph == 'p1') _p1ImageUrl = url;
          if (paragraph == 'p2') _p2ImageUrl = url;
          if (paragraph == 'p3') _p3ImageUrl = url;
        });
      }
    }
  }

  Future<void> _addInstruction() async {
    if (_documentNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a document name.")),
      );
      return;
    }

    final instructionData = {
      'name': _documentNameController.text,
      'type': 'instruction',
      'p1': _p1Controller.text,
      'p1ImageUrl': _p1ImageUrl,
      'p2': _p2Controller.text,
      'p2ImageUrl': _p2ImageUrl,
      'p3': _p3Controller.text,
      'p3ImageUrl': _p3ImageUrl,
    };

    try {
      await FirebaseFirestore.instance.collection('instructions').doc(_documentNameController.text).set(instructionData);
      await FirebaseFirestore.instance.collection('sheets').doc(_documentNameController.text).set({
        'name': _documentNameController.text,
        'type': 'instruction',
      });
      _clearForm();
    } catch (e) {
      print("Error adding instruction: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error adding instruction: $e")),
      );
    }
  }

  void _clearForm() {
    _documentNameController.clear();
    _p1Controller.clear();
    _p2Controller.clear();
    _p3Controller.clear();
    setState(() {
      _p1ImageUrl = null;
      _p2ImageUrl = null;
      _p3ImageUrl = null;
    });
  }

  Widget _buildTextField(String label, TextEditingController controller, VoidCallback onPickImage, String? imageUrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Colors.white54),
            border: const OutlineInputBorder(),
          ),
        ),
        Row(
          children: [
            TextButton(
              onPressed: onPickImage,
              child: const Text('Pick Image', style: TextStyle(color: Colors.green)),
            ),
            if (imageUrl != null)
              Image.network(imageUrl, height: 50, width: 50, fit: BoxFit.cover),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141A2E),
        title: const Text('Instructions', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Add New Instruction",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _documentNameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Document Name",
                labelStyle: TextStyle(color: Colors.white54),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            _buildTextField('Paragraph 1', _p1Controller, () => _pickImage('p1'), _p1ImageUrl),
            _buildTextField('Paragraph 2', _p2Controller, () => _pickImage('p2'), _p2ImageUrl),
            _buildTextField('Paragraph 3', _p3Controller, () => _pickImage('p3'), _p3ImageUrl),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addInstruction,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Save Instruction', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance.collection('instructions').snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Colors.white));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No instructions found.', style: TextStyle(color: Colors.white)));
                  }

                  final instructions = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: instructions.length,
                    itemBuilder: (context, index) {
                      final instruction = instructions[index];
                      return Card(
                        color: const Color(0xFF1A1D3A),
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          title: Text(instruction['p1'] ?? 'No Title', style: const TextStyle(color: Colors.white)),
                          subtitle: Text(instruction['p2'] ?? '', style: const TextStyle(color: Colors.white70)),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white),
                            onPressed: () => _showEditDialog(instruction.id, instruction.data() as Map<String, dynamic>),
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

  void _showEditDialog(String id, Map<String, dynamic> instructionData) {
    _p1Controller.text = instructionData['p1'] ?? '';
    _p2Controller.text = instructionData['p2'] ?? '';
    _p3Controller.text = instructionData['p3'] ?? '';
    _p1ImageUrl = instructionData['p1ImageUrl'];
    _p2ImageUrl = instructionData['p2ImageUrl'];
    _p3ImageUrl = instructionData['p3ImageUrl'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF141A2E),
          title: const Text('Edit Instruction', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField('Paragraph 1', _p1Controller, () => _pickImage('p1'), _p1ImageUrl),
                _buildTextField('Paragraph 2', _p2Controller, () => _pickImage('p2'), _p2ImageUrl),
                _buildTextField('Paragraph 3', _p3Controller, () => _pickImage('p3'), _p3ImageUrl),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () async {
                await _updateInstruction(id);
                Navigator.pop(context);
              },
              child: const Text('Save', style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateInstruction(String id) async {
    try {
      await FirebaseFirestore.instance.collection('instructions').doc(id).update({
        'p1': _p1Controller.text,
        'p1ImageUrl': _p1ImageUrl,
        'p2': _p2Controller.text,
        'p2ImageUrl': _p2ImageUrl,
        'p3': _p3Controller.text,
        'p3ImageUrl': _p3ImageUrl,
      });
    } catch (e) {
      print("Error updating instruction: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating instruction: $e")),
      );
    }
  }
}
