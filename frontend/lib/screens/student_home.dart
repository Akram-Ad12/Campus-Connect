// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StudentHome extends StatelessWidget {
  final Map userData; // Data passed from Login response [cite: 35]

  const StudentHome({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Student Dashboard")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // This satisfies the "Student Card" requirement [cite: 13, 27]
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF673AB7), Color(0xFF311B92)]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(userData['name'], style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  Text("ID: ${userData['id']}", style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 10),
                  Text("Role: Student", style: const TextStyle(color: Colors.white)),
                ],
              ),
            ),
            // Placeholder for marks/schedules [cite: 14, 31]
            const ListTile(leading: Icon(Icons.list_alt), title: Text("View My Marks")),
          ],
        ),
      ),
    );
  }
}