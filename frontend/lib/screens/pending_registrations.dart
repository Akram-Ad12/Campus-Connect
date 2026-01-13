// lib/screens/pending_registrations.dart
import 'package:flutter/material.dart';
import 'package:frontend/globals.dart' as globals;
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PendingRegistrations extends StatefulWidget {
  const PendingRegistrations({super.key});
  @override
  State<PendingRegistrations> createState() => _PendingRegistrationsState();
}

class _PendingRegistrationsState extends State<PendingRegistrations> {
  List students = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPending();
  }

  Future<void> fetchPending() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse('http://${globals.serverIP}:8000/api/admin/pending-students'));
      if (response.statusCode == 200) {
        setState(() { students = jsonDecode(response.body); });
      }
    } catch (e) {
      debugPrint("Error fetching: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> updateStatus(int id, int status) async {
    setState(() {
      students.removeWhere((s) => s['id'] == id);
    });

    await http.post(
      Uri.parse('http://${globals.serverIP}:8000/api/admin/validate-student'),
      body: {'user_id': id.toString(), 'status': status.toString()},
    );
    fetchPending(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: Text(
          "Pending Approvals", 
          style: GoogleFonts.poppins(color: const Color(0xFF311B92), fontWeight: FontWeight.bold, fontSize: 18)
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF311B92), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading && students.isEmpty
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF673AB7)))
          : students.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: fetchPending,
                  color: const Color(0xFF673AB7),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    itemCount: students.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final student = students[index];
                      return _buildStudentCard(student);
                    },
                  ),
                ),
    );
  }

  Widget _buildStudentCard(dynamic student) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFEDE9FE),
          child: Text(
            student['name'][0].toUpperCase(),
            style: const TextStyle(color: Color(0xFF673AB7), fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          student['name'],
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: Text(
          student['email'],
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.black45),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildActionButton(
              icon: Icons.close_rounded,
              color: Colors.redAccent,
              onPressed: () => updateStatus(student['id'], -1),
            ),
            const SizedBox(width: 6),
            _buildActionButton(
              icon: Icons.check_rounded,
              color: Colors.green,
              onPressed: () => updateStatus(student['id'], 1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required Color color, required VoidCallback onPressed}) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 22),
        onPressed: onPressed,
        constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.mark_email_read_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "All caught up!",
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
          ),
          Text(
            "No pending student registrations.",
            style: GoogleFonts.poppins(color: Colors.black38),
          ),
        ],
      ),
    );
  }
}