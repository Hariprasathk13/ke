import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart'; // Path provider for accessing files
import 'adminitem.dart'; // Separate file for the detail page

class AdminPOPage extends StatefulWidget {
  const AdminPOPage({super.key});

  @override
  _AdminPOPageState createState() => _AdminPOPageState();
}

class _AdminPOPageState extends State<AdminPOPage> {
  final TextEditingController poInputController = TextEditingController();
  String errorText = "";
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String dateDisplay = "No date selected";
  String timeDisplay = "No time selected";

  List<Map<String, String>> savedData = []; // List to store PO data

  @override
  void initState() {
    super.initState();
    readFromFile(); // Read data when the page is initialized
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD), // Lighter background color
      appBar: AppBar(
        title: const Text("Admin PO Menu"),
        backgroundColor: Colors.blueAccent, // Updated app bar color
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: poInputController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: "Enter PO No",
                errorText: errorText.isNotEmpty ? errorText : null,
                border: const OutlineInputBorder(), // Added border
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: validatePOInput,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: openDatePicker,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Button color
                    elevation: 5,
                  ),
                  child: const Text("Pick Date"),
                ),
                Text(dateDisplay, style: const TextStyle(fontSize: 16)), // Updated text style
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: openTimePicker,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Button color
                    elevation: 5,
                  ),
                  child: const Text("Pick Time"),
                ),
                Text(timeDisplay, style: const TextStyle(fontSize: 16)), // Updated text style
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: addItem,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent, // Updated button color
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15), // Adjusted padding
              ),
              child: const Text("ADD"),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: savedData.isEmpty
                  ? const Center(child: Text("No PO data is available", style: TextStyle(fontSize: 18))) // Updated text style
                  : ListView(
                      children: savedData.map((data) {
                        return ListTile(
                          title: GestureDetector(
                            onTap: () {
                              // Navigate to detail page
                              navigateToDetailPage(data);
                            },
                            child: Chip(
                              label: Text(
                                  'PO No: ${data["po"]}, Date: ${data["date"]}, Time: ${data["time"]}'),
                              backgroundColor: Colors.blue.shade100,
                              avatar: const Icon(Icons.list_alt),
                              deleteIcon: const Icon(Icons.delete, color: Colors.red),
                              onDeleted: () => _showDeleteConfirmationDialog(data),
                              deleteButtonTooltipMessage: "Delete PO",
                            ),
                          ),
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void validatePOInput(String value) {
    if (value.isEmpty) {
      setState(() {
        errorText = "PO Number cannot be empty!";
      });
    } else {
      setState(() {
        errorText = ""; // Clear the error if validation passes
      });
    }
  }

  Future<void> addItem() async {
    if (poInputController.text.isEmpty || errorText.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid PO number!')),
      );
      return;
    }

    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date!')),
      );
      return;
    }

    if (selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a time!')),
      );
      return;
    }

    String enteredPO = poInputController.text;
    String formattedDate = "${selectedDate!.toLocal()}".split(' ')[0];
    String formattedTime = "${selectedTime!.hour}:${selectedTime!.minute}";

    // Add new data to the list and update the UI
    setState(() {
      savedData.add({
        "po": enteredPO,
        "date": formattedDate,
        "time": formattedTime,
      });
    });

    // Debugging: Print the new entry to the console
    print(
        'New Entry Added: {PO: $enteredPO, Date: $formattedDate, Time: $formattedTime}');

    // Save to the text file
    await saveToFile(enteredPO, formattedDate, formattedTime);

    // Reset the input fields
    poInputController.clear();
    errorText = "";
    selectedDate = null;
    selectedTime = null;
    dateDisplay = "No date selected";
    timeDisplay = "No time selected";

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PO Added Successfully!')),
    );
  }

  Future<void> saveToFile(String po, String date, String time) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String path = '${appDocDir.path}/polist.txt'; // Get path to app's docs dir
    File file = File(path);

    String content = 'PO No: $po, Date: $date, Time: $time';
    await file.writeAsString('$content\n', mode: FileMode.append);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data saved successfully!')),
    );
  }

  Future<void> readFromFile() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String path = '${appDocDir.path}/polist.txt';
    File file = File(path);
    if (await file.exists()) {
      List<String> contents = await file.readAsLines();
      setState(() {
        savedData = contents.map((line) {
          List<String> parts = line.split(', ');
          return {
            "po": parts[0].split(': ')[1],
            "date": parts[1].split(': ')[1],
            "time": parts[2].split(': ')[1],
          };
        }).toList();
      });
    }
  }

  Future<void> _showDeleteConfirmationDialog(Map<String, String> data) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete this PO?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () async {
                // Remove PO entry
                setState(() {
                  savedData.remove(data);
                });

                // Check if poNumber is not null before deleting the file
                if (data["po"] != null) {
                  await deletePOFile(data["po"]!);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('PO number is null. Cannot delete file.')),
                  );
                }

                Navigator.of(context).pop();
                saveAllToFile(); // Save changes after deletion
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PO Deleted Successfully!')),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> deletePOFile(String poNumber) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String filePath = '${appDocDir.path}/$poNumber.txt'; // Specify the path to the PO file

    File file = File(filePath);
    if (await file.exists()) {
      await file.delete(); // Delete the file
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PO file deleted successfully!')),
      );
    }
  }

  Future<void> saveAllToFile() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String path = '${appDocDir.path}/polist.txt';
    File file = File(path);
    StringBuffer content = StringBuffer();

    for (var data in savedData) {
      content.writeln('PO No: ${data["po"]}, Date: ${data["date"]}, Time: ${data["time"]}');
    }

    await file.writeAsString(content.toString());
  }

  void openDatePicker() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2021),
      lastDate: DateTime(2101),
    );
    setState(() {
      selectedDate = pickedDate;
      dateDisplay = "${pickedDate?.toLocal()}".split(' ')[0];
    });
    }

  void openTimePicker() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        selectedTime = pickedTime;
        timeDisplay = "${pickedTime.hour}:${pickedTime.minute.toString().padLeft(2, '0')}"; // Ensure two-digit minute
      });
    }
  }

  void navigateToDetailPage(Map<String, String> data) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PODetailPage(
          data: data,
          onEdit: (editedData) {
            // Find the index of the current data
            int index = savedData.indexOf(data);
            if (index != -1) {
              // Update the list with the new data
              setState(() {
                savedData[index] = editedData;
              });
              // Save all data to the text file
              saveAllToFile();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('PO Edited Successfully!')),
              );
            }
          },
          onDelete: (deletedData) {
            setState(() {
              savedData.remove(deletedData);
            });
            saveAllToFile(); // Save changes after deletion
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('PO Deleted Successfully!')),
            );
          },
        ),
      ),
    );
  }
}
