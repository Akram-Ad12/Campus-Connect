// lib/screens/pending_registrations.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PendingRegistrations extends StatefulWidget {
  const PendingRegistrations({super.key});
  @override
  State<PendingRegistrations> createState() => _PendingRegistrationsState();
}

class _PendingRegistrationsState extends State<PendingRegistrations> {
  List students = [];

  @override
  void initState() {
    super.initState();
    fetchPending();
  }

  Future<void> fetchPending() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/admin/pending-students'));
    if (response.statusCode == 200) {
      setState(() { students = jsonDecode(response.body); });
    }
  }

  Future<void> updateStatus(int id, int status) async {
    await http.post(
      Uri.parse('http://127.0.0.1:8000/api/admin/validate-student'),
      body: {'user_id': id.toString(), 'status': status.toString()},
    );
    fetchPending(); // Refresh list
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(title: const Text("Pending Approvals"), backgroundColor: Colors.white, elevation: 0),
      body: students.isEmpty 
        ? const Center(child: Text("No pending registrations"))
        : ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  title: Text(student['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(student['email']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.check_circle, color: Colors.green), onPressed: () => updateStatus(student['id'], 1)),
                      IconButton(icon: const Icon(Icons.cancel, color: Colors.red), onPressed: () => updateStatus(student['id'], -1)),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }
}