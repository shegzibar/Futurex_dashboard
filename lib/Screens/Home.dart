import 'package:flutter/material.dart';
import 'package:futuerx_dashboard/Screens/Faqs.dart';
import 'package:futuerx_dashboard/Screens/News.dart';
import 'package:futuerx_dashboard/Screens/Users.dart';
import 'package:futuerx_dashboard/Screens/instruction.dart';

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
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Two grids per row
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.1, // Adjust for card shape
            ),
            itemCount: 4, // Adjust to 4 grids
            itemBuilder: (context, index) {
              switch (index) {
                case 0:
                  return DashboardButton(
                    icon: Icons.person,
                    label: 'Users',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => UsersPage()),
                      );
                    },
                  );
                case 1:
                  return DashboardButton(
                    icon: Icons.newspaper,
                    label: 'News',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => NewsPage()),
                      );
                    },
                  );
                case 2:
                  return DashboardButton(
                    icon: Icons.help_outline,
                    label: 'FAQ',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => FAQs()),
                      );
                    },
                  );
                case 3:
                  return DashboardButton(
                    icon: Icons.book,
                    label: 'Instructions',
                    onPressed: () {
                      // Replace with your Lectures page navigation
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => InstructionListPage()),
                      );
                    },
                  );
                default:
                  return const SizedBox.shrink();
              }
            },
          ),
        ),
      ),
    );
  }
}

// Reusable DashboardButton widget with a modern card style
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
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12), // Rounded corners
      splashColor: Colors.blue.withOpacity(0.3), // Splash color on tap
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1F36),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 36), // Adjusted icon size
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16, // Adjusted font size for modern look
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
