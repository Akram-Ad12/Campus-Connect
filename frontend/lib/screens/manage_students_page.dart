// ignore_for_file: unused_import, avoid_print, use_build_context_synchronously, library_private_types_in_public_api, deprecated_member_use
import 'package:flutter/material.dart';
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

  // Reuse your existing headers logic
  Map<String, String> get _headers => {
    'Authorization': 'Bearer ${globals.userToken}',
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  Future<void> fetchUsers() async {
    setState(() => isLoading = true);
    try {
      // Reusing your existing endpoint that gets validated students/teachers
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/admin/users-to-assign'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        setState(() {
          allUsers = jsonDecode(response.body);
        });
      }
    } catch (e) {
      debugPrint("Error fetching students: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> deleteStudent(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('http://127.0.0.1:8000/api/admin/users/$id'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Student deleted successfully")),
        );
        fetchUsers(); // Refresh the list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to delete. Backend might be restricted.")),
        );
      }
    } catch (e) {
      debugPrint("Delete error: $e");
    }
  }

  void _confirmDelete(dynamic student) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Are you sure?"),
        content: Text("This will permanently delete ${student['name']}. This action cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              deleteStudent(student['id']);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Logic to group and filter students
  Map<String, List<dynamic>> getGroupedStudents() {
    Map<String, List<dynamic>> grouped = {};

    // 1. Filter: Only Students + Search Query
    List<dynamic> filtered = allUsers.where((u) {
      final isStudent = u['role'] == 'student';
      final matchesSearch = u['name'].toString().toLowerCase().contains(searchQuery.toLowerCase());
      return isStudent && matchesSearch;
    }).toList();

    // 2. Group by group_id/name
    for (var s in filtered) {
      String groupName = (s['group_id'] == null || s['group_id'].toString().isEmpty)
          ? "Unassigned Students"
          : s['group_id'].toString();

      if (!grouped.containsKey(groupName)) grouped[groupName] = [];
      grouped[groupName]!.add(s);
    }

    // 3. Sort students alphabetically within groups
    grouped.forEach((key, list) {
      list.sort((a, b) => a['name'].toString().toLowerCase().compareTo(b['name'].toString().toLowerCase()));
    });

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final groupedData = getGroupedStudents();
    final sortedKeys = groupedData.keys.toList()..sort((a, b) {
      if (a == "Unassigned Students") return -1;
      if (b == "Unassigned Students") return 1;
      return a.compareTo(b);
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: const Text("Manage Students", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search Bar Section
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: TextField(
                    onChanged: (val) => setState(() => searchQuery = val),
                    decoration: InputDecoration(
                      hintText: "Search students by name...",
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF673AB7)),
                      filled: true,
                      fillColor: const Color(0xFFF0F0F0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                // List Section
                Expanded(
                  child: ListView.builder(
                    itemCount: sortedKeys.length,
                    itemBuilder: (context, index) {
                      String sectionTitle = sortedKeys[index];
                      List<dynamic> studentsInSection = groupedData[sectionTitle]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                            child: Text(
                              sectionTitle,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          ...studentsInSection.map((student) => Card(
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: const Color(0xFF673AB7).withOpacity(0.1),
                                    child: Text(student['name'][0].toUpperCase(),
                                        style: const TextStyle(color: Color(0xFF673AB7))),
                                  ),
                                  title: Text(student['name'], style: const TextStyle(fontWeight: FontWeight.w600)),
                                  subtitle: Text(student['email'] ?? ""),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                    onPressed: () => _confirmDelete(student),
                                  ),
                                ),
                              )),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}