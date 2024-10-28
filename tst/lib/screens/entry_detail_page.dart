import 'package:flutter/material.dart';

class EntryDetailPage extends StatelessWidget {
  final String entry;

  const EntryDetailPage({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    // Split the entry into parts (assuming a format like "key1:value1, key2:value2")
    List<String> entryParts = entry.split(', ');

    // Print the parts for debugging
    for (var part in entryParts) {
      print('Entry Part: $part');
    }

    // Initialize int variables for the 2nd and 3rd elements
    int? secondElement;
    int? thirdElement;
    String? picodata;

    // Check if there are enough parts and split by ':'
    if (entryParts.length > 1) {
      List<String> secondPart = entryParts[1].split(':');
      if (secondPart.length > 1) {
        // Parse the second element
        secondElement = int.tryParse(secondPart[1].trim());
        print('Second Element: $secondElement');
      }
    }

    if (entryParts.length > 2) {
      List<String> thirdPart = entryParts[2].split(':');
      if (thirdPart.length > 1) {
        // Parse the third element
        thirdElement = int.tryParse(thirdPart[1].trim());
        print('Third Element: $thirdElement');
      }
    }

    // Concatenate secondElement and thirdElement into picodata
    if (secondElement != null && thirdElement != null) {
      picodata = '$secondElement, $thirdElement';
    } else if (secondElement != null) {
      picodata = '$secondElement';
    } else if (thirdElement != null) {
      picodata = '$thirdElement';
    } else {
      picodata = ''; // Fallback in case both are null
    }

    print('Picodata: $picodata'); // Print picodata for debugging

    return Scaffold(
      backgroundColor: const Color(0xFFA5CAE4),
      appBar: AppBar(
        title: const Text('Entry Details'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Card(
            elevation: 4.0, // Adds a shadow effect
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0), // Rounded corners
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Detailed Entry Information',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20), // Space between title and entry
                  const Divider(), // Adds a divider line
                  const SizedBox(height: 10), // Space after divider
                  // Display each part
                  for (var part in entryParts)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: Text(
                        part,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  const SizedBox(height: 20), // Add space before displaying picodata
                  // Display picodata if it has a value
                  
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
