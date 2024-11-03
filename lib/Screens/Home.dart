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
            StylishButton(
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
            StylishButton(
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
            StylishButton(
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

// Reusable StylishButton widget
class StylishButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const StylishButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
        backgroundColor: const Color(0xFF141A2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40),
        ),
        elevation: 10,
      ).copyWith(
        backgroundColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.pressed)) {
            return const Color(0xFF141A2E).withOpacity(0.7);
          }
          return null;
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
