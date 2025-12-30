// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:frontend/screens/assign_groups_page.dart';
import 'package:frontend/screens/login_page.dart';
import 'package:frontend/screens/upload_schedule_page.dart';
import 'manage_students_page.dart';
import 'pending_registrations.dart'; // We will create this next

class AdminHome extends StatelessWidget {
  const AdminHome({super.key});
  Future<void> _handleLogout(BuildContext context) async {
  // 1. (Optional but recommended) Call the Laravel logout API here if you are storing the token
  // 2. Clear the navigation stack and go back to Login
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => const LoginPage()),
    (route) => false, // This line removes all previous screens from the stack
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: const Text("Admin Dashboard", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
    IconButton(
      onPressed: () => _handleLogout(context), // Call the new logout function
      icon: const Icon(Icons.logout, color: Colors.redAccent),
    )
  ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Welcome, Administrator", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [
                  _buildMenuCard(
                    context, 
                    "Validate Students", 
                    Icons.how_to_reg, 
                    const PendingRegistrations(),
                  ),
                  _buildMenuCard(
                    context, 
                    "Assign Groups", 
                    Icons.group_add, 
                    const AssignGroupsPage(),
                  ),
                  _buildMenuCard(
                    context, 
                    "Manage Students", 
                    Icons.group_remove, 
                    const ManageStudentsPage(),
                  ),
                  _buildMenuCard(
                    context, 
                    "Upload Schedules", 
                    Icons.calendar_month, 
                    const UploadSchedulePage(),
                  ),
                  _buildMenuCard(context, "Manage Courses", Icons.book, null),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, IconData icon, Widget? destination, {String? badge}) {
    return InkWell(
      onTap: () {
        if (destination != null) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => destination));
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 45, color: const Color(0xFF673AB7)),
                  const SizedBox(height: 10),
                  Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            if (badge != null)
              Positioned(
                right: 10, top: 10,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(8)),
                  child: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 10)),
                ),
              )
          ],
        ),
      ),
    );
  }
}