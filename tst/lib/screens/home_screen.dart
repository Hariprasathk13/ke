import 'package:flutter/material.dart';
import 'package:tst/widgets/custom_button.dart'; // Import the custom button widget
import 'admin_screen.dart'; // Import the admin screen
import 'user_screen.dart'; // Import the user screen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isAdminActive = false; // State for Admin button (default off)
  bool isUserActive = false; // State for User button (default off)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE1F5FE), // Lighter background color for freshness
      body: SingleChildScrollView( // Make the body scrollable
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo.png',
                height: 200, // Adjusted height for better visibility
                width: 200,  // Adjusted width for better visibility
              ),
              const SizedBox(height: 20),
              const Text(
                'Karthik Enterprises',
                style: TextStyle(
                  fontSize: 42, // Slightly increased font size
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent, // Changed color for better contrast
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Quality • Consistency • Trust',
                style: TextStyle(
                  fontSize: 20, // Slightly increased font size
                  color: Colors.blueGrey,
                ),
              ),
              const SizedBox(height: 40),
              // Change Row to Column for vertical alignment
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Admin Button
                  CustomButton(
                    text: 'Admin',
                    localizedText: 'நிர்வாகி',
                    onTap: () {
                      setState(() {
                        isAdminActive = true; // Set Admin button state to active
                        isUserActive = false; // Deactivate User button
                      });
                      Navigator.of(context).push(_createRoute(const AdminScreen())).then((_) {
                        setState(() {
                          isAdminActive = false; // Reset Admin button state to off after navigation
                        });
                      });
                    },
                    onColor: Colors.blueAccent, // Color when active
                    offColor: Colors.white, // Color when inactive
                    isActive: isAdminActive, // Pass the state
                  ),
                  const SizedBox(height: 20), // Add space between buttons
                  // User Button
                  CustomButton(
                    text: 'User',
                    localizedText: 'பயனர்',
                    onTap: () {
                      setState(() {
                        isUserActive = true; // Set User button state to active
                        isAdminActive = false; // Deactivate Admin button
                      });
                      Navigator.of(context).push(_createRoute(const UserPage())).then((_) {
                        setState(() {
                          isUserActive = false; // Reset User button state to off after navigation
                        });
                      });
                    },
                    onColor: Colors.blueAccent, // Color when active
                    offColor: Colors.white, // Color when inactive
                    isActive: isUserActive, // Pass the state
                  ),
                ],
              ),
              const SizedBox(height: 40), // Add some space at the bottom if needed
            ],
          ),
        ),
      ),
    );
  }

  // Custom page route for smooth transitions
  Route _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0); // Start from the right
        const end = Offset.zero; // End at the center
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }
}
