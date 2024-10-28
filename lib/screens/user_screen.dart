import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'detail_page.dart'; // Import the new detail page

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  List<String> poList = []; // List to hold PO data

  @override
  void initState() {
    super.initState();
    print("Initializing UserPage..."); // Debugging statement
    readFromFile(); // Read data when the page is initialized
  }

  Future<void> readFromFile() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String path = '${appDocDir.path}/polist.txt';
    File file = File(path);
    print("Attempting to read from file: $path"); // Debugging statement

    if (await file.exists()) {
      print("File exists. Reading contents..."); // Debugging statement
      List<String> contents = await file.readAsLines();
      setState(() {
        poList = contents; // Store the lines from the file
      });
      print("PO List loaded with ${poList.length} entries."); // Debugging statement
    } else {
      print("File does not exist."); // Debugging statement
    }
  }

  void navigateToDetailPage(String content) {
    print("Navigating to detail page with content: $content"); // Debugging statement
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPage(content: content),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD), // Light background for better aesthetics
      appBar: AppBar(
        title: const Text('User Page'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: poList.isEmpty
            ? Center(
                child: Text(
                  'No PO data available.',
                  style: TextStyle(fontSize: 20, color: Colors.grey[600]), // Improved typography for the no data message
                ),
              ) // Show a message if no data
            : Wrap(
                spacing: 8.0, // Space between badges
                runSpacing: 8.0, // Space between rows of badges
                children: poList.map((content) {
                  return GestureDetector(
                    onTap: () => navigateToDetailPage(content), // Navigate on click
                    child: Chip(
                      label: Text(
                        content,
                        style: const TextStyle(fontSize: 16), // Adjusted font size for better readability
                      ), // Display each PO entry as a badge
                      backgroundColor: Colors.blue.shade100,
                      elevation: 2, // Added elevation for a card-like effect
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8), // Rounded corners for chips
                      ),
                    ),
                  );
                }).toList(),
              ),
      ),
    );
  }
}
