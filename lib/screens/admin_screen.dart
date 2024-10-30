import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For loading the asset file
import 'adminpo.dart'; // Import the AdminPage

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final TextEditingController userIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  Map<String, String> adminCredentials = {}; // Store credentials here

  @override
  void initState() {
    super.initState();
    _loadCredentials(); // Load credentials on init
  }

  Future<void> _loadCredentials() async {
    // Load the credentials from the text file
    final String data =
        await rootBundle.loadString('assets/admin_credentials.txt');
    // Split the lines and populate the map
    final List<String> lines = data.split('\n');
    for (var line in lines) {
      final parts = line.split(':');
      if (parts.length == 2) {
        adminCredentials[parts[0]] = parts[1]; // key-value pairs
      }
    }
  }

  void _login() {
    // Validate entered credentials
    final String enteredUserId = userIdController.text;
    final String enteredPassword = passwordController.text;

    if (adminCredentials[enteredUserId] == enteredPassword) {
      // Redirect to AdminPage if credentials are valid
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const AdminPOPage()),
      );
    } else {
      // Show an error message if credentials are invalid
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid credentials')),
      );
    }

    // Clear the text fields after attempting to log in
    userIdController.clear();
    passwordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE1F5FE), // Lighter background color
      appBar: AppBar(
        title: const Text('Admin Page'),
        backgroundColor: Colors.blueAccent, // Updated app bar color
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Row(
                  children: [
                    Image.asset(
                      'assets/logo.png',
                      height: 50,
                      width: 50,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'KE',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  '• Quality • Consistency • Trust',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blueGrey,
                  ),
                ),
                const SizedBox(height: 30),
                const Text('User ID (பயனர் ஐடி)',
                    style: TextStyle(fontSize: 16, color: Colors.black54)),
                const SizedBox(height: 5),
                TextField(
                  controller: userIdController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 20), // Padding for the text field
                    hintText: 'Enter your User ID', // Added hint text
                    hintStyle:
                        const TextStyle(color: Colors.grey), // Hint text color
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Password (கடவுச்சொல்)',
                    style: TextStyle(fontSize: 16, color: Colors.black54)),
                const SizedBox(height: 5),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 20), // Padding for the text field
                    hintText: 'Enter your Password', // Added hint text
                    hintStyle:
                        const TextStyle(color: Colors.grey), // Hint text color
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(20),
                    backgroundColor: Colors.black,
                    elevation: 5, // Added elevation for depth
                  ),
                  onPressed: _login,
                  child: const Icon(Icons.arrow_forward,
                      color: Colors.white), // Call the login function
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
