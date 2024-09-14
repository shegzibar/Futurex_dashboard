import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // To format the date and time

class NewsPage extends StatefulWidget {
  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _newsTitleController = TextEditingController();
  final TextEditingController _newsContentController = TextEditingController();
  final TextEditingController _newsFromController = TextEditingController();

  Timestamp? _newsTime; // To store the selected timestamp
  String _formattedTime = "Pick a Date & Time"; // To show on the button before selection

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        title: const Text('Manage News',style: TextStyle(color: Colors.white),),
        backgroundColor: const Color(0xFF141A2E),
        leading: IconButton(onPressed: (){Navigator.pop(context);}, icon: Icon(Icons.arrow_back ,color: Colors.white,)),
        actions: [
          // Delete All Button
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: _deleteAllNews,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('News').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text("Error loading news", style: TextStyle(color: Colors.white));
                  }

                  if (!snapshot.hasData) {
                    return Center(child: const CircularProgressIndicator(color: Colors.white,));
                  }

                  final newsList = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: newsList.length,
                    itemBuilder: (context, index) {
                      final news = newsList[index];
                      final Timestamp timestamp = news['time'];
                      final DateTime date = timestamp.toDate();
                      final String formattedDate = DateFormat.yMMMd().add_jm().format(date);

                      return ListTile(
                        title: Text(
                          "Title: ${news['title']}, From: ${news['from']}, Time: $formattedDate",
                          style: const TextStyle(color: Colors.white),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.white),
                              onPressed: () {
                                _editNews(news.id, news['title'], news['news'], news['from'], timestamp);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _deleteNews(news.id);
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
                _addNews();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text("Add New News", style: TextStyle(color: Colors.white ,fontWeight: FontWeight.bold),),
            ),
          ],
        ),
      ),
    );
  }

  // Add News Dialog
  void _addNews() {
    _showEditNewsDialog();
  }

  // Edit News Function
  void _editNews(String newsId, String title, String content, String from, Timestamp time) {
    _newsTitleController.text = title;
    _newsContentController.text = content;
    _newsFromController.text = from;
    _newsTime = time; // Set existing time
    _formattedTime = DateFormat.yMMMd().add_jm().format(time.toDate());
    _showEditNewsDialog(newsId: newsId);
  }

  // Show News Edit Dialog
  void _showEditNewsDialog({String? newsId}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF141A2E),
          title: const Text("Edit News", style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                style: TextStyle(
                  color: Colors.white, // Replace with your desired color
                ),
                controller: _newsTitleController,
                decoration: const InputDecoration(hintText: 'News Title'),
              ),
              TextField(
                style: TextStyle(
                  color: Colors.white, // Replace with your desired color
                ),
                controller: _newsContentController,
                decoration: const InputDecoration(hintText: 'News Content'),
              ),
              TextField(
                style: TextStyle(
                  color: Colors.white, // Replace with your desired color
                ),
                controller: _newsFromController,
                decoration: const InputDecoration(hintText: 'From'),
              ),
              SizedBox(height: 10,),
              ElevatedButton(
                onPressed: () async {
                  await _selectDateTime(context);
                },
                child: Text(_formattedTime), // Show formatted time or placeholder
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (_newsTime == null) {
                  _newsTime = Timestamp.now(); // Default to current time if none selected
                }

                if (newsId == null) {
                  _firestore.collection('News').add({
                    'title': _newsTitleController.text,
                    'news': _newsContentController.text,
                    'from': _newsFromController.text,
                    'time': _newsTime, // Use Timestamp field
                  });
                } else {
                  _firestore.collection('News').doc(newsId).update({
                    'title': _newsTitleController.text,
                    'news': _newsContentController.text,
                    'from': _newsFromController.text,
                    'time': _newsTime, // Update Timestamp field
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

  // Function to pick Date and Time
  Future<void> _selectDateTime(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        final DateTime fullDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        setState(() {
          _newsTime = Timestamp.fromDate(fullDateTime); // Set selected timestamp
          _formattedTime = DateFormat.yMMMd().add_jm().format(fullDateTime); // Format for display
        });
      }
    }
  }

  // Delete a specific news item
  void _deleteNews(String newsId) {
    _firestore.collection('News').doc(newsId).delete();
  }

  // Delete all news
  void _deleteAllNews() async {
    final newsCollection = _firestore.collection('News');

    // Get all documents in the 'News' collection
    var snapshots = await newsCollection.get();

    for (var doc in snapshots.docs) {
      await doc.reference.delete(); // Delete each document
    }
  }
}
