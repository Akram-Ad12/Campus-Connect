// ignore_for_file: use_build_context_synchronously, deprecated_member_use
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'dart:convert';

class AssignGroupsPage extends StatefulWidget {
  const AssignGroupsPage({super.key});

  @override
  State<AssignGroupsPage> createState() => _AssignGroupsPageState();
}

class _AssignGroupsPageState extends State<AssignGroupsPage> {
  List groups = [];
  List users = [];
  bool isLoading = true;
  String searchQuery = ""; 
  final _groupNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    refreshData();
  }

  Map<String, String> get _headers => {
        'Authorization': 'Bearer ${globals.userToken}',
        'Accept': 'application/json',
      };

  Future<void> refreshData() async {
    setState(() => isLoading = true);
    try {
      final gRes = await http.get(Uri.parse('http://${globals.serverIP}:8000/api/admin/groups'), headers: _headers);
      final uRes = await http.get(Uri.parse('http://${globals.serverIP}:8000/api/admin/users-to-assign'), headers: _headers);

      if (gRes.statusCode == 200 && uRes.statusCode == 200) {
        setState(() {
          groups = jsonDecode(gRes.body);
          users = jsonDecode(uRes.body);
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> createGroup() async {
    if (_groupNameController.text.isEmpty) return;
    final response = await http.post(Uri.parse('http://${globals.serverIP}:8000/api/admin/groups'),
      headers: _headers, body: {'name': _groupNameController.text});
    if (response.statusCode == 200 || response.statusCode == 201) {
      _groupNameController.clear();
      refreshData();
    }
  }

  Future<void> deleteGroup(int id) async {
    final response = await http.delete(Uri.parse('http://${globals.serverIP}:8000/api/admin/groups/$id'), headers: _headers);
    if (response.statusCode == 200) refreshData();
  }

  Future<void> assignUser(int userId, String groupName) async {
    final response = await http.post(Uri.parse('http://${globals.serverIP}:8000/api/admin/assign-group'),
      headers: _headers, body: {'user_id': userId.toString(), 'group_name': groupName});
    if (response.statusCode == 200) refreshData();
  }

  void _handleToggle(dynamic user, String groupName, bool isAlreadyIn) {
    String newValue;
    if (user['role'] == 'teacher') {
      List<String> currentList = (user['group_id'] ?? "").toString().split(', ').where((s) => s.isNotEmpty).toList();
      isAlreadyIn ? currentList.remove(groupName) : currentList.add(groupName);
      newValue = currentList.join(', ');
    } else {
      newValue = isAlreadyIn ? "" : groupName;
    }
    assignUser(user['id'], newValue);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FD),
        appBar: AppBar(
          title: Text("Assign Groups", 
            style: GoogleFonts.poppins(color: const Color(0xFF311B92), fontWeight: FontWeight.bold, fontSize: 18)),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF311B92), size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: TabBar(
            labelColor: const Color(0xFF673AB7),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFF673AB7),
            labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
            tabs: const [Tab(text: "Manage Groups"), Tab(text: "Assign Users")],
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF673AB7)))
            : TabBarView(
                children: [_buildGroupManager(), _buildUserAssigner()],
              ),
      ),
    );
  }

  Widget _buildGroupManager() {
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F7),
              borderRadius: BorderRadius.circular(15),
            ),
            child: TextField(
              controller: _groupNameController,
              decoration: InputDecoration(
                hintText: "New Group Name (e.g. CS-01)",
                hintStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.black26),
                border: InputBorder.none,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add_circle, color: Color(0xFF673AB7)),
                  onPressed: createGroup,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: groups.length,
            itemBuilder: (context, i) {
              final groupName = groups[i]['name'];
              final teachers = users.where((u) => u['role'] == 'teacher' && (u['group_id'] ?? "").toString().contains(groupName)).toList();
              final students = users.where((u) => u['role'] == 'student' && (u['group_id'] ?? "").toString() == groupName).toList();

              return Container(
                margin: const EdgeInsets.only(bottom: 15),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.groups_rounded, color: Color(0xFF673AB7), size: 24),
                            const SizedBox(width: 10),
                            Text(groupName, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () => _showDeleteDialog(groups[i]['id'], groupName),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    _buildMemberList("Teachers", teachers),
                    const SizedBox(height: 10),
                    _buildMemberList("Students", students),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMemberList(String label, List members) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black38)),
        const SizedBox(height: 4),
        members.isEmpty
            ? Text("None assigned", style: GoogleFonts.poppins(fontSize: 12, color: Colors.black26, fontStyle: FontStyle.italic))
            : Wrap(
                spacing: 8,
                children: members.map((m) => Chip(
                  backgroundColor: const Color.fromARGB(255, 246, 243, 246),
                  padding: EdgeInsets.zero,
                  label: Text(m['name'], style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF673AB7))),
                  avatar: CircleAvatar(
                    backgroundColor: const Color(0xFF673AB7),
                    child: Text(m['name'][0], style: const TextStyle(fontSize:12, color: Colors.white)),
                  ),
                )).toList(),
              ),
      ],
    );
  }

  Widget _buildUserAssigner() {
    final filteredUsers = users.where((u) => u['name'].toString().toLowerCase().contains(searchQuery.toLowerCase())).toList();

    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: TextField(
            onChanged: (val) => setState(() => searchQuery = val),
            decoration: InputDecoration(
              hintText: "Search users to assign...",
              hintStyle: GoogleFonts.poppins(color: Colors.black26, fontSize: 14),
              prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF673AB7)),
              filled: true,
              fillColor: const Color(0xFFF5F5F7),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: filteredUsers.length,
            itemBuilder: (context, i) {
              final user = filteredUsers[i];
              final currentGroups = (user['group_id'] ?? "").toString();
              
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: ListTile(
                  title: Text(user['name'], style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: _buildGroupBadgeList(currentGroups, user['role']),
                  trailing: PopupMenuButton<String>(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    icon: const Icon(Icons.add_task_rounded, color: Color(0xFF673AB7)),
                    onSelected: (gName) => _handleToggle(user, gName, currentGroups.contains(gName)),
                    itemBuilder: (context) => groups.map<PopupMenuEntry<String>>((g) {
                      bool isAssigned = currentGroups.contains(g['name']);
                      return PopupMenuItem(
                        value: g['name'],
                        child: Row(
                          children: [
                            Icon(isAssigned ? Icons.remove_circle : Icons.add_circle, 
                                 color: isAssigned ? Colors.red : Colors.green, size: 20),
                            const SizedBox(width: 10),
                            Text(g['name'], style: GoogleFonts.poppins(fontSize: 13)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGroupBadgeList(String groups, String role) {
    if (groups.isEmpty) return Text("Unassigned $role", style: const TextStyle(fontSize: 11, color: Colors.black38));
    
    List<String> items = groups.split(', ').where((s) => s.isNotEmpty).toList();
    return Wrap(
      spacing: 4,
      children: items.map((name) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(color: const Color(0xFF673AB7).withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
        child: Text(name, style: const TextStyle(fontSize: 10, color: Color(0xFF673AB7), fontWeight: FontWeight.bold)),
      )).toList(),
    );
  }

  void _showDeleteDialog(int id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Delete Group?", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text("Teachers and students in '$name' will be unassigned."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, elevation: 0),
            onPressed: () { Navigator.pop(ctx); deleteGroup(id); },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}