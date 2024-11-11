import 'package:flutter/material.dart';
import 'package:futuerx_dashboard/Screens/Faqs.dart';
import 'package:futuerx_dashboard/Screens/News.dart';
import 'package:futuerx_dashboard/Screens/Users.dart';
// Import the FAQ and Lectures pages

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
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: GridView.count(
            crossAxisCount: 2, // Two buttons per row
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            shrinkWrap: true,
            children: [
              // Users Button
              DashboardButton(
                icon: Icons.person,
                label: 'Users',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UsersPage()),
                  );
                },
              ),

              // News Button
              DashboardButton(
                icon: Icons.newspaper,
                label: 'News',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NewsPage()),
                  );
                },
              ),

              // FAQ Button
              DashboardButton(
                icon: Icons.help_outline,
                label: 'FAQ',
                onPressed: () {

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FAQs()),
                  );
                },
              ),

              // Lectures Button
              DashboardButton(
                icon: Icons.book,
                label: 'Lectures Sheets',
                onPressed: () {
                  // Navigate to Lectures Page
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => LecturesPage()),
                  // );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Reusable DashboardButton widget with icons, optimized for smaller size
class DashboardButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const DashboardButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF141A2E),
        padding: const EdgeInsets.all(12), // Reduced padding for compact size
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Slightly rounded corners
        ),
      ).copyWith(
        backgroundColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.pressed)) {
            return const Color(0xFF1F2A45);
          }
          return const Color(0xFF141A2E);
        }),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 28), // Smaller icon size
          const SizedBox(height: 6), // Reduced spacing
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14, // Smaller font size
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
