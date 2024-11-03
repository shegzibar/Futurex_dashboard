import 'package:flutter/material.dart';
import 'package:futuerx_dashboard/Screens/News.dart';
import 'package:futuerx_dashboard/Screens/Users.dart';
 // Import the FAQ page

class Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: const Color(0xFF141A2E),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Users Button
            ThemeButton(
              label: 'Users',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UsersPage()),
                );
              },
            ),
            const SizedBox(height: 20),

            // News Button
            ThemeButton(
              label: 'News',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NewsPage()),
                );
              },
            ),
            const SizedBox(height: 20),

            // FAQ Button
            ThemeButton(
              label: 'FAQ',
              onPressed: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => FAQPage()), // Define your FAQPage class separately
                // );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Reusable ThemeButton widget
class ThemeButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const ThemeButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
        backgroundColor: const Color(0xFF141A2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero, // No rounded corners
        ),
        elevation: 5, // Adds a subtle shadow for depth
      ).copyWith(
        backgroundColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.pressed)) {
            return const Color(0xFF1F2A45); // Slightly darker when pressed
          }
          return const Color(0xFF141A2E);
        }),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
