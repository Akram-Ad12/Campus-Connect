// ignore_for_file: unused_import, avoid_print, use_build_context_synchronously, library_private_types_in_public_api, deprecated_member_use
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../globals.dart' as globals;

class ManageStudentsPage extends StatefulWidget {
  const ManageStudentsPage({super.key});

  @override
  _ManageStudentsPageState createState() => _ManageStudentsPageState();
}

class _ManageStudentsPageState extends State<ManageStudentsPage> {
  List<dynamic> allUsers = [];
  bool isLoading = true;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Map<String, String> get _headers => {
        'Authorization': 'Bearer ${globals.userToken}',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

  Future<void> fetchUsers() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('http://${globals.serverIP}:8000/api/admin/users-to-assign'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        setState(() {
          allUsers = jsonDecode(response.body);
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> deleteStudent(int id) async {
    final response = await http.delete(
      Uri.parse('http://${globals.serverIP}:8000/api/admin/users/$id'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account removed")),
      );
      fetchUsers();
    }
  }

  Map<String, List<dynamic>> getGroupedStudents() {
    Map<String, List<dynamic>> grouped = {};
    List<dynamic> filtered = allUsers.where((u) {
      final isStudent = u['role'] == 'student';
      final matchesSearch = u['name'].toString().toLowerCase().contains(searchQuery.toLowerCase());
      return isStudent && matchesSearch;
    }).toList();

    for (var s in filtered) {
      String groupName = (s['group_id'] == null) ? "Unassigned" : "Group ${s['group_id']}";
      if (!grouped.containsKey(groupName)) grouped[groupName] = [];
      grouped[groupName]!.add(s);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final groupedData = getGroupedStudents();
    final sortedKeys = groupedData.keys.toList()..sort();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: Text("Manage Students", 
          style: GoogleFonts.poppins(color: const Color(0xFF311B92), fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF311B92), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Styled Search Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: TextField(
              onChanged: (val) => setState(() => searchQuery = val),
              decoration: InputDecoration(
                hintText: "Search students...",
                hintStyle: GoogleFonts.poppins(color: Colors.black26, fontSize: 14),
                prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF673AB7)),
                filled: true,
                fillColor: const Color(0xFFF5F5F7),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: isLoading 
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF673AB7)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  itemCount: sortedKeys.length,
                  itemBuilder: (context, index) {
                    final key = sortedKeys[index];
                    final students = groupedData[key]!;
                    return _buildGroupSection(key, students);
                  },
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupSection(String title, List<dynamic> students) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(25, 15, 25, 10),
          child: Text(title.toUpperCase(),
              style: GoogleFonts.poppins(
                  fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black38, letterSpacing: 1.1)),
        ),
        ...students.map((student) => _buildStudentTile(student)),
      ],
    );
  }

  Widget _buildStudentTile(dynamic student) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFF3E5F5),
          child: Text(student['name'][0].toUpperCase(),
              style: const TextStyle(color: Color(0xFF673AB7), fontWeight: FontWeight.bold)),
        ),
        title: Text(student['name'], style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(student['email'], style: GoogleFonts.poppins(fontSize: 11, color: Colors.black45)),
        trailing: Container(
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 22),
            onPressed: () => _showDeleteDialog(student),
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(dynamic student) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Delete Student?", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text("Are you sure you want to remove ${student['name']}? This action is permanent."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Keep")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, elevation: 0),
            onPressed: () {
              Navigator.pop(ctx);
              deleteStudent(student['id']);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}