import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FAQs extends StatefulWidget {
  const FAQs({super.key});

  @override
  State<FAQs> createState() => _FAQsState();
}

class _FAQsState extends State<FAQs> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Controllers for creating/updating an FAQ
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _answerController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _keywordController = TextEditingController();

  // Method to create a new FAQ
  Future<void> _createFAQ() async {
    await _firestore.collection('FAQs').add({
      'question': _questionController.text,
      'answer': _answerController.text,
      'category': _categoryController.text,
      'keyword': _keywordController.text.split(','), // Convert comma-separated keywords into list
    });

    // Clear controllers after creating FAQ
    _questionController.clear();
    _answerController.clear();
    _categoryController.clear();
    _keywordController.clear();
  }

  // Method to read FAQs from Firestore
  Stream<QuerySnapshot> _readFAQs() {
    return _firestore.collection('FAQs').snapshots();
  }

  // Method to update an existing FAQ
  Future<void> _updateFAQ(String id) async {
    await _firestore.collection('FAQs').doc(id).update({
      'question': _questionController.text,
      'answer': _answerController.text,
      'category': _categoryController.text,
      'keyword': _keywordController.text.split(','),
    });

    _questionController.clear();
    _answerController.clear();
    _categoryController.clear();
    _keywordController.clear();
  }

  // Method to delete an FAQ
  Future<void> _deleteFAQ(String id) async {
    await _firestore.collection('FAQs').doc(id).delete();
  }

  // Dialog for creating or updating FAQs
  Future<void> _showFAQDialog({String? id, String? question, String? answer, String? category, List<dynamic>? keywords}) async {
    _questionController.text = question ?? '';
    _answerController.text = answer ?? '';
    _categoryController.text = category ?? '';
    _keywordController.text = keywords?.join(', ') ?? '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          title: Text(id == null ? 'Add FAQ' : 'Update FAQ', style: const TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _questionController,
                decoration: const InputDecoration(labelText: 'Question', labelStyle: TextStyle(color: Colors.white)),
                style: const TextStyle(color: Colors.white),
              ),
              TextField(
                controller: _answerController,
                decoration: const InputDecoration(labelText: 'Answer', labelStyle: TextStyle(color: Colors.white)),
                style: const TextStyle(color: Colors.white),
              ),
              TextField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Category', labelStyle: TextStyle(color: Colors.white)),
                style: const TextStyle(color: Colors.white),
              ),
              TextField(
                controller: _keywordController,
                decoration: const InputDecoration(labelText: 'Keywords (comma separated)', labelStyle: TextStyle(color: Colors.white)),
                style: const TextStyle(color: Colors.white),
              ),
            ],
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
                  _createFAQ();
                } else {
                  _updateFAQ(id);
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
      backgroundColor: const Color(0xFF0A0E21), // Background color for the whole screen
      appBar: AppBar(
        title: const Text('FAQs',style: TextStyle(color: Colors.white),),
        backgroundColor: const Color(0xFF141A2E), // Matching app theme color
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFAQDialog(),
        backgroundColor: const Color(0xFF141A2E),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _readFAQs(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading FAQs', style: TextStyle(color: Colors.red)));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              Map<String, dynamic> faq = doc.data() as Map<String, dynamic>;

              return Card(
                color: const Color(0xFF1A1A2E),
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(faq['question'] ?? '', style: const TextStyle(color: Colors.white)),
                  subtitle: Text(faq['answer'] ?? '', style: const TextStyle(color: Colors.white70)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showFAQDialog(
                          id: doc.id,
                          question: faq['question'],
                          answer: faq['answer'],
                          category: faq['category'],
                          keywords: faq['keyword'],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteFAQ(doc.id),
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
