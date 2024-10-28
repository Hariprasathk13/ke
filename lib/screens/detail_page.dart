import 'package:flutter/material.dart';
import 'dart:io'; // Import to work with files
import 'package:path_provider/path_provider.dart'; // Import for path_provider
import 'entry_detail_page.dart'; // Import the EntryDetailPage

class DetailPage extends StatefulWidget {
  final String content;

  const DetailPage({super.key, required this.content});

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  List<String> fileContents = []; // List to hold contents from the text file
  String poNo = ""; // Variable to store the PO No value
  String date = ""; // Variable to store the date
  String time = ""; // Variable to store the time

  @override
  void initState() {
    super.initState();
    print("DetailPage initialized with content: ${widget.content}"); // Debugging statement

    // Split the content by commas to extract PO No, date, and time
    List<String> entries = widget.content.split(',');

    // Iterate over entries to find PO No, date, and time
    for (var entry in entries) {
      List<String> keyValue = entry.split(':'); // Split by colon
      if (keyValue.length == 2) {
        String key = keyValue[0].trim();
        String value = keyValue[1].trim();
        if (key == "PO No") {
          poNo = value; // Store the PO No value
        } else if (key == "Date") {
          date = value; // Store the date value
        } else if (key == "Time") {
          time = value; // Store the time value
        }
      }
    }

    print("Stored PO No value: $poNo"); // Debugging statement
    print("Stored Date value: $date"); // Debugging statement
    print("Stored Time value: $time"); // Debugging statement

    // Read from the file named <poNo>.txt
    readFile();
  }

  Future<void> readFile() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String path = '${appDocDir.path}/$poNo.txt'; // Create the file path
    File file = File(path);

    // Check if the file exists and read its contents
    if (await file.exists()) {
      List<String> contents = await file.readAsLines();
      setState(() {
        fileContents = contents; // Store the lines from the file
      });
      print("File contents loaded. Number of lines: ${fileContents.length}"); // Debugging statement
    } else {
      print("File does not exist: $path"); // Debugging statement
    }
  }

  @override
  Widget build(BuildContext context) {
    print("Building DetailPage..."); // Debugging statement

    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD), // Light background color for a soft appearance
      appBar: AppBar(
        title: const Text('PO Details'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start, // Align items to the start
            crossAxisAlignment: CrossAxisAlignment.start, // Align items to the start
            children: [
              const Text(
                'PO Information:',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              // Display PO details in a Card
              Card(
                elevation: 4,
                color: Colors.white, // White background for better contrast
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PO No: $poNo',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Date: $date',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Time: $time',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Display only the first element of each line in badge format
              if (fileContents.isNotEmpty)
                Wrap(
                  spacing: 8.0, // Space between badges
                  runSpacing: 8.0, // Space between rows of badges
                  children: fileContents.map((line) {
                    // Split each line and take the first element
                    String firstElement = line.split(',').first.trim(); // Assuming comma as the delimiter
                    return InkWell(
                      onTap: () {
                        // Navigate to the EntryDetailPage when tapped
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EntryDetailPage(entry: line), // Pass the whole entry
                          ),
                        );
                      },
                      child: Chip(
                        label: Text(firstElement), // Display the first element as a badge
                        backgroundColor: Colors.blue.shade100,
                      ),
                    );
                  }).toList(),
                )
              else
                const Text(
                  'No data available from the file.',
                  style: TextStyle(fontSize: 18, color: Colors.grey), // Change color for no data message
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
