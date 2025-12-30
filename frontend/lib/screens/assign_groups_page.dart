// ignore_for_file: unused_import, use_build_context_synchronously, deprecated_member_use
import 'package:flutter/material.dart';
import '../globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login_page.dart'; // Make sure this is where your userToken variable is defined

class AssignGroupsPage extends StatefulWidget {
  const AssignGroupsPage({super.key});

  @override
  State<AssignGroupsPage> createState() => _AssignGroupsPageState();
}

class _AssignGroupsPageState extends State<AssignGroupsPage> {
  List groups = [];
  List users = [];
  bool isLoading = true;
  final _groupNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    refreshData();
  }

  // Helper for Sanctum Headers
  Map<String, String> get _headers => {
    'Authorization': 'Bearer ${globals.userToken}', 
    'Accept': 'application/json',
  };

  Future<void> refreshData() async {
    setState(() => isLoading = true);
    try {
      final gRes = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/admin/groups'),
        headers: _headers,
      );
      final uRes = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/admin/users-to-assign'),
        headers: _headers,
      );

      if (gRes.statusCode == 200 && uRes.statusCode == 200) {
        setState(() {
          groups = jsonDecode(gRes.body);
          users = jsonDecode(uRes.body);
        });
      } else {
        _showError("Failed to fetch data: ${gRes.statusCode}");
      }
    } catch (e) {
      _showError("Connection error. Is Laravel running?");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> createGroup() async {
    if (_groupNameController.text.isEmpty) return;

    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/api/admin/groups'),
      headers: _headers,
      body: {'name': _groupNameController.text},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      _groupNameController.clear();
      refreshData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Group created successfully!")),
      );
    } else {
      _showError("Could not create group. Check if it already exists.");
    }
  }

  Future<void> deleteGroup(int id) async {
    final response = await http.delete(
      Uri.parse('http://127.0.0.1:8000/api/admin/groups/$id'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      refreshData(); // Refresh the list after deleting
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Group deleted successfully")),
      );
    } else {
      _showError("Failed to delete group.");
    }
  }

  void _showDeleteDialog(int groupId, String groupName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Are you sure?"),
        content: Text("Deleting group '$groupName' will result in all Teachers and Students to be unassigned from it."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), // Close dialog
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // Close dialog
              deleteGroup(groupId); // Run delete function
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> assignUser(int userId, String groupName) async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/api/admin/assign-group'),
      headers: _headers,
      body: {
        'user_id': userId.toString(),
        'group_name': groupName,
      },
    );

    if (response.statusCode == 200) {
      refreshData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User assigned to $groupName")),
      );
    } else {
      _showError("Assignment failed.");
    }
  }

void _handleToggle(dynamic user, String groupName, bool isAlreadyIn) {
    String newValue;
    
    if (user['role'] == 'teacher') {
      // For Teachers: Handle comma-separated list
      List<String> currentList = (user['group_id'] ?? "").toString()
          .split(', ')
          .where((s) => s.isNotEmpty)
          .toList();

      if (isAlreadyIn) {
        currentList.remove(groupName);
      } else {
        currentList.add(groupName);
      }
      newValue = currentList.join(', ');
    } else {
      // For Students: Single group only
      newValue = isAlreadyIn ? "" : groupName;
    }

    // Calls your existing assignUser function with the new string
    assignUser(user['id'], newValue);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F7),
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            "Assign Groups",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          bottom: const TabBar(
            labelColor: Color(0xFF673AB7),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF673AB7),
            tabs: [
              Tab(text: "Manage Groups"),
              Tab(text: "Assign Users"),
            ],
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF673AB7)))
            : TabBarView(
                children: [
                  _buildGroupManager(),
                  _buildUserAssigner(),
                ],
              ),
      ),
    );
  }

Widget _buildGroupManager() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: TextField(
              controller: _groupNameController,
              decoration: InputDecoration(
                hintText: "New Group Name (e.g. CS-01)",
                border: InputBorder.none,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add_circle, color: Color(0xFF673AB7)),
                  onPressed: createGroup,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: groups.length,
              itemBuilder: (context, i) {
                final group = groups[i];
                final String groupName = group['name'];

                // DYNAMIC FILTERING: Find teachers whose group_id contains THIS group name
                final String teacherList = users
                    .where((u) =>
                        u['role'] == 'teacher' &&
                        (u['group_id'] ?? "").toString().contains(groupName))
                    .map((u) => u['name'])
                    .join(', ');

                // DYNAMIC FILTERING: Find students assigned to THIS group
                final String studentList = users
                    .where((u) =>
                        u['role'] == 'student' &&
                        (u['group_id'] ?? "").toString() == groupName)
                    .map((u) => u['name'])
                    .join(', ');

                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: const Icon(Icons.group, color: Color(0xFF673AB7)),
                    title: Text(groupName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Assigned Teachers: ${teacherList.isEmpty ? 'None' : teacherList}",
                            style: const TextStyle(fontSize: 12, color: Colors.black54),
                          ),
                          Text(
                            "Assigned Students: ${studentList.isEmpty ? 'None' : studentList}",
                            style: const TextStyle(fontSize: 12, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      onPressed: () => _showDeleteDialog(group['id'], groupName),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserAssigner() {
    if (users.isEmpty) {
      return const Center(child: Text("No validated students or teachers found."));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: users.length,
      itemBuilder: (context, i) {
        final user = users[i];
        final String currentGroups = (user['group_id'] ?? "").toString();

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            title: Text(user['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
            // Shows "Groups" for teachers and "Group" for students
            subtitle: Text(
              user['role'] == 'teacher' 
                ? "Teacher • Groups: ${currentGroups.isEmpty ? 'Unassigned' : currentGroups}"
                : "Student • Group: ${currentGroups.isEmpty ? 'Unassigned' : currentGroups}"
            ),
            trailing: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Color(0xFF673AB7)),
              onSelected: (groupName) {
                // Logic to decide if we are adding or removing
                bool isAlreadyIn = currentGroups.contains(groupName);
                _handleToggle(user, groupName, isAlreadyIn);
              },
              itemBuilder: (context) {
                return groups.map<PopupMenuEntry<String>>((g) {
                  bool isAssigned = currentGroups.contains(g['name']);
                  return PopupMenuItem(
                    value: g['name'],
                    child: Row(
                      children: [
                        Icon(
                          isAssigned ? Icons.remove_circle_outline : Icons.add_circle_outline,
                          color: isAssigned ? Colors.red : Colors.green,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(isAssigned ? "Unassign from ${g['name']}" : "Assign to ${g['name']}"),
                      ],
                    ),
                  );
                }).toList();
              },
            ),
          ),
        );
      },
    );
  }
}