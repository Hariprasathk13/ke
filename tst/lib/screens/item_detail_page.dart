import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ItemDetailPage extends StatefulWidget {
  final String itemData; // String containing the item data
  final String poNumber; // PO number to access the file
  final Function(String) onUpdate; // Callback function to pass updated data

  const ItemDetailPage({super.key, 
    required this.itemData,
    required this.poNumber,
    required this.onUpdate, // Initialize the callback in constructor
  });

  @override
  _ItemDetailPageState createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  late TextEditingController itemNumberController;
  late TextEditingController minWeightController;
  late TextEditingController maxWeightController;
  late TextEditingController startSerialController;
  late TextEditingController endSerialController;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with the data passed from the previous page
    itemNumberController = TextEditingController(text: extractFieldValue('Item Number', widget.itemData));
    minWeightController = TextEditingController(text: extractFieldValue('Min Weight', widget.itemData));
    maxWeightController = TextEditingController(text: extractFieldValue('Max Weight', widget.itemData));
    startSerialController = TextEditingController(text: extractFieldValue('Start Serial', widget.itemData));
    endSerialController = TextEditingController(text: extractFieldValue('End Serial', widget.itemData));

    // Debug prints to show initialized values
    print('Initial item number: ${itemNumberController.text}');
    print('Initial min weight: ${minWeightController.text}');
    print('Initial max weight: ${maxWeightController.text}');
    print('Initial start serial: ${startSerialController.text}');
    print('Initial end serial: ${endSerialController.text}');
  }

  @override
  void dispose() {
    itemNumberController.dispose();
    minWeightController.dispose();
    maxWeightController.dispose();
    startSerialController.dispose();
    endSerialController.dispose();
    super.dispose();
  }

  String extractFieldValue(String fieldName, String data) {
    // Update regex to account for either a comma or the end of the string
    RegExp regExp = RegExp('$fieldName:\\s*(.+?)(\\s*,|\\s*\$)');
    final match = regExp.firstMatch(data);
    String value = match != null ? match.group(1)!.trim() : '';
    print('Extracted $fieldName: $value'); // Debugging print
    return value;
  }

  Future<void> saveEditedData() async {
    // Validate input fields
    if (itemNumberController.text.isEmpty ||
        minWeightController.text.isEmpty ||
        maxWeightController.text.isEmpty ||
        startSerialController.text.isEmpty ||
        endSerialController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields must be filled!')),
      );
      return;
    }

    // Create the updated item string
    String updatedItem = 'Item Number: ${itemNumberController.text}, '
        'Min Weight: ${minWeightController.text}, '
        'Max Weight: ${maxWeightController.text}, '
        'Start Serial: ${startSerialController.text}, '
        'End Serial: ${endSerialController.text}';

    print('Updated Item String: $updatedItem'); // Debugging print

    // Access the file to update
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String fileName = '${widget.poNumber}.txt'; // Use PO number as file name
    File file = File('${appDocDir.path}/$fileName');

    // Read current contents and update
    String contents = await file.readAsString();
    print('File Contents Before Update:\n$contents'); // Debugging print

    List<String> lines = contents.split('\n');
    // Find the index of the item to be updated and replace it
    int index = lines.indexWhere((line) => line.contains(extractFieldValue('Item Number', widget.itemData)));
    if (index != -1) {
      lines[index] = updatedItem; // Update the line with new item data
      await file.writeAsString(lines.join('\n')); // Write the updated lines back to the file

      // Read the updated contents
      String updatedContents = await file.readAsString();
      print('File Contents After Update:\n$updatedContents'); // Debugging print

      // Call the onUpdate callback with the updated item data
      widget.onUpdate(updatedItem); // Pass the updated item data back to PODetailPage

      // Navigate back to the previous page
      Navigator.pop(context);
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item Updated Successfully!')),
      );
    } else {
      print('Item not found for update.'); // Debugging print
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD), // Light background color
      appBar: AppBar(
        title: const Text("Edit Item"),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: saveEditedData,
            tooltip: "Save Changes",
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView( // Enables scrolling for smaller screens
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Edit Item Details',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20), // Space between title and text fields
              _buildTextField(itemNumberController, "Item Number"),
              _buildTextField(minWeightController, "Min Weight", isNumeric: true),
              _buildTextField(maxWeightController, "Max Weight", isNumeric: true),
              _buildTextField(startSerialController, "Start Serial", isNumeric: true),
              _buildTextField(endSerialController, "End Serial", isNumeric: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isNumeric = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0), // Space between text fields
      child: TextField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0), // Rounded corners for text fields
            borderSide: const BorderSide(color: Colors.blue),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: Colors.blueAccent),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0), // Padding inside the text fields
        ),
      ),
    );
  }
}
