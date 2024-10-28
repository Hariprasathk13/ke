import 'package:flutter/material.dart';
import 'dart:io'; // Import for File operations
import 'package:path_provider/path_provider.dart'; // Import to access file directory
import 'item_detail_page.dart';

class PODetailPage extends StatefulWidget {
  final Map<String, String> data;
  final Function(Map<String, String>) onEdit;
  final Function(Map<String, String>) onDelete;

  const PODetailPage({super.key, 
    required this.data,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  _PODetailPageState createState() => _PODetailPageState();
}

class _PODetailPageState extends State<PODetailPage> {
  late Map<String, String> data;

  final TextEditingController poInputController = TextEditingController();
  final TextEditingController itemNumberController = TextEditingController();
  final TextEditingController minWeightController = TextEditingController();
  final TextEditingController maxWeightController = TextEditingController();
  final TextEditingController startSerialController = TextEditingController();
  final TextEditingController endSerialController = TextEditingController();

  String errorText = "";
  String itemData = "No item data available."; // Default message
  List<String> itemNumbers = []; // List of item numbers to display as chips
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String dateDisplay = "No date selected";
  String timeDisplay = "No time selected";

  @override
  void initState() {
    super.initState();
    data = widget.data; // Initialize with the passed data
    poInputController.text = data["po"]!;
    dateDisplay = data["date"]!;
    timeDisplay = data["time"]!;

    // Check for the presence of the text file
    checkForItemData();
  }

  Future<void> checkForItemData() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String fileName = '${data["po"]}.txt'; // Use PO number as file name
    File file = File('${appDocDir.path}/$fileName');

    if (await file.exists()) {
      String contents = await file.readAsString();
      print("File Contents on Load:\n$contents"); // Debugging print
      if (contents.isNotEmpty) {
        // Extract item numbers from the file contents
        List<String> extractedItemNumbers = extractItemNumbers(contents);
        setState(() {
          itemData = contents; // Update with the file contents
          itemNumbers = extractedItemNumbers; // Update item numbers list
        });
      }
    } else {
      // Create the file if it doesn't exist
      await file.create();
      print("File Created: ${file.path}"); // Debugging print
    }
  }

  // Function to extract item numbers from the file contents
  List<String> extractItemNumbers(String contents) {
    List<String> itemList = [];
    RegExp itemNumberRegExp = RegExp(r'Item Number:\s*(\d+)');
    Iterable<RegExpMatch> matches = itemNumberRegExp.allMatches(contents);

    for (var match in matches) {
      itemList.add(match.group(1)!); // Add the item number to the list
    }

    return itemList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD), // Lighter background for better aesthetics
      appBar: AppBar(
        title: const Text("PO Details"),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              widget.onDelete(data);
              Navigator.pop(context);
            },
            tooltip: "Delete PO",
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align text to the start
          children: [
            TextField(
              controller: poInputController,
              keyboardType: TextInputType.text, // Allow letters and numbers
              decoration: InputDecoration(
                labelText: "PO No",
                errorText: errorText.isNotEmpty ? errorText : null,
                border: const OutlineInputBorder(), // Added border
                filled: true, // Filled background
                fillColor: Colors.white, // Fill color for the text field
              ),
              onChanged: (value) {
                validatePOInput(value);
              },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Date: $dateDisplay", style: const TextStyle(fontSize: 16)), // Increased font size
                ElevatedButton(
                  onPressed: openDatePicker,
                  child: const Text("Change Date"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Time: $timeDisplay", style: const TextStyle(fontSize: 16)), // Increased font size
                ElevatedButton(
                  onPressed: openTimePicker,
                  child: const Text("Change Time"),
                ),
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: editItem,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: const Text("SAVE"),
            ),
            const SizedBox(height: 20),
            const Text(
              'Add Item Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: itemNumberController,
              decoration: const InputDecoration(
                labelText: "Item Number",
                border: OutlineInputBorder(), // Added border
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: minWeightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Min Weight",
                border: OutlineInputBorder(), // Added border
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: maxWeightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Max Weight",
                border: OutlineInputBorder(), // Added border
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: startSerialController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Start Serial",
                border: OutlineInputBorder(), // Added border
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: endSerialController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "End Serial",
                border: OutlineInputBorder(), // Added border
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: addItemDetails,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text("ADD"),
            ),
            const SizedBox(height: 20),
            const Text(
              'Item Numbers',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8.0, // Space between the chips
              runSpacing: 4.0, // Space between the lines of chips
              children: itemNumbers.map((itemNumber) {
                return InkWell(
                  onTap: () {
                    // Navigate to the ItemDetailPage when a chip is clicked
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ItemDetailPage(
                          itemData: itemData, // Pass the existing item data
                          poNumber: data["po"]!, // Pass the PO number
                          onUpdate: (String updatedData) {
                            setState(() {
                              itemData = updatedData; // Update displayed item data
                              itemNumbers = extractItemNumbers(updatedData); // Update item numbers list
                            });
                            print('Updated Item Data: $itemData'); // Debugging print
                            print('Updated Item Numbers: $itemNumbers'); // Debugging print
                          },
                        ),
                      ),
                    );
                  },
                  child: Chip(
                    label: Text(
                      itemNumber,
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.blue,
                    deleteIcon: const Icon(Icons.cancel, color: Colors.white),
                    onDeleted: () => deleteItem(itemNumber), // Add delete functionality
                  ),
                );
              }).toList(),
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

  Future<void> openDatePicker() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2021),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
        dateDisplay = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> openTimePicker() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        selectedTime = pickedTime;
        timeDisplay = "${pickedTime.hour}:${pickedTime.minute}"; // Updated time display
      });
    }
  }

  void editItem() async {
    if (errorText.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid PO number!')),
      );
      return;
    }

    String updatedPO = poInputController.text;
    String formattedDate = selectedDate != null
        ? "${selectedDate!.toLocal()}".split(' ')[0]
        : data["date"]!;
    String formattedTime = selectedTime != null
        ? "${selectedTime!.hour}:${selectedTime!.minute}"
        : data["time"]!;

    // Create a map for updated data
    Map<String, String> updatedData = {
      "po": updatedPO,
      "date": formattedDate,
      "time": formattedTime,
    };

    if (updatedPO != data["po"]) {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String oldFileName = '${data["po"]}.txt';
      String newFileName = '$updatedPO.txt';
      File oldFile = File('${appDocDir.path}/$oldFileName');
      File newFile = File('${appDocDir.path}/$newFileName');

      if (await oldFile.exists()) {
        await oldFile.rename(newFile.path); // Rename the file
        print("File Renamed: ${newFile.path}"); // Debugging print
      }
    }

    widget.onEdit(updatedData); // Notify parent widget of changes
    Navigator.pop(context);
  }

  void addItemDetails() async {
    String itemNumber = itemNumberController.text;
    String minWeightStr = minWeightController.text;
    String maxWeightStr = maxWeightController.text;
    String startSerialStr = startSerialController.text;
    String endSerialStr = endSerialController.text;

    // Validate inputs
    if (itemNumber.isEmpty ||
        minWeightStr.isEmpty ||
        maxWeightStr.isEmpty ||
        startSerialStr.isEmpty ||
        endSerialStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all item details')),
      );
      return;
    }

    // Create a new item string
    String newItem =
        'Item Number: $itemNumber, Min Weight: $minWeightStr, Max Weight: $maxWeightStr, Start Serial: $startSerialStr, End Serial: $endSerialStr\n';

    // Append the new item to the text file
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String fileName = '${data["po"]}.txt'; // Use PO number as file name
    File file = File('${appDocDir.path}/$fileName');
    await file.writeAsString(newItem, mode: FileMode.append);

    // Read the updated contents of the text file
    String contents = await file.readAsString();
    print("File Contents after Adding Item:\n$contents"); // Debugging print

    setState(() {
      itemData = contents; // Update with the new contents
      itemNumbers = extractItemNumbers(contents); // Update the item numbers list
    });

    // Clear input fields after adding item
    itemNumberController.clear();
    minWeightController.clear();
    maxWeightController.clear();
    startSerialController.clear();
    endSerialController.clear();
  }

  void deleteItem(String itemNumber) async {
    // Read the current contents of the text file
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String fileName = '${data["po"]}.txt'; // Use PO number as file name
    File file = File('${appDocDir.path}/$fileName');

    // Read the contents of the file
    String contents = await file.readAsString();
    print("File Contents before Deletion:\n$contents"); // Debugging print

    List<String> lines = contents.split('\n');

    // Filter out the line with the item number to be deleted
    List<String> updatedLines =
        lines.where((line) => !line.contains(itemNumber)).toList();

    // Write the updated contents back to the file
    await file.writeAsString(updatedLines.join('\n'));

    // Read and print the updated contents
    String updatedContents = await file.readAsString();
    print("File Contents after Deletion:\n$updatedContents"); // Debugging print

    setState(() {
      itemNumbers.remove(itemNumber); // Remove item number from the list
      itemData = updatedContents; // Update itemData with the new contents
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Item deleted successfully')),
    );
  }
}
