// ignore_for_file: unused_import, avoid_print, use_build_context_synchronously, library_private_types_in_public_api, deprecated_member_use
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../globals.dart' as globals;

class ManageCoursesPage extends StatefulWidget {
  const ManageCoursesPage({super.key});

  @override
  _ManageCoursesPageState createState() => _ManageCoursesPageState();
}

class _ManageCoursesPageState extends State<ManageCoursesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> courses = ["DAM", "DAW", "OTAM", "ACS", "TEC", "IASR", "BDM"];
  
  List<dynamic> allTeachers = [];
  List<dynamic> allGroups = [];
  List<dynamic> assignedTeachers = [];
  List<dynamic> assignedGroups = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    refreshData();
  }

  Future<void> refreshData() async {
    final headers = {'Authorization': 'Bearer ${globals.userToken}', 'Accept': 'application/json'};
    final uRes = await http.get(Uri.parse('http://127.0.0.1:8000/api/admin/users-to-assign'), headers: headers);
    final gRes = await http.get(Uri.parse('http://127.0.0.1:8000/api/admin/groups'), headers: headers);
    final aRes = await http.get(Uri.parse('http://127.0.0.1:8000/api/admin/course-assignments'), headers: headers);

    setState(() {
      allTeachers = jsonDecode(uRes.body).where((u) => u['role'] == 'teacher').toList();
      allGroups = jsonDecode(gRes.body);
      assignedTeachers = jsonDecode(aRes.body)['teachers'];
      assignedGroups = jsonDecode(aRes.body)['groups'];
      isLoading = false;
    });
  }

  Future<void> toggleAssignment(String course, int id, String type, String action) async {
    await http.post(
      Uri.parse('http://127.0.0.1:8000/api/admin/toggle-course-assignment'),
      headers: {'Authorization': 'Bearer ${globals.userToken}', 'Content-Type': 'application/json'},
      body: jsonEncode({'course_name': course, 'id': id, 'type': type, 'action': action}),
    );
    refreshData(); // Sync UI with database so items persist after exit
  }

  Widget _buildCourseList(String type) {
    return ListView.builder(
      itemCount: courses.length,
      itemBuilder: (context, i) {
        String course = courses[i];
        
        // Filter assignments for this specific course
        var currentItems = type == 'teacher' 
          ? assignedTeachers.where((a) => a['course_name'] == course)
          : assignedGroups.where((a) => a['course_name'] == course);

        return Card(
          margin: const EdgeInsets.all(10),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(course, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 10),
                // The "Keywords" Wrap
                Wrap(
                  spacing: 8,
                  children: currentItems.map((item) {
                    final data = type == 'teacher' 
                        ? allTeachers.firstWhere((t) => t['id'] == item['teacher_id'])
                        : allGroups.firstWhere((g) => g['id'] == item['group_id']);
                    return Chip(
                      label: Text(data['name']),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () => toggleAssignment(course, data['id'], type, 'remove'),
                    );
                  }).toList(),
                ),
                const Divider(),
                // Dropdown to Add New
                DropdownButton<int>(
                  hint: Text("Add ${type == 'teacher' ? 'Teacher' : 'Group'}"),
                  isExpanded: true,
                  items: (type == 'teacher' ? allTeachers : allGroups).map<DropdownMenuItem<int>>((item) {
                    return DropdownMenuItem(value: item['id'], child: Text(item['name']));
                  }).toList(),
                  onChanged: (val) => toggleAssignment(course, val!, type, 'add'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Courses"),
        bottom: TabBar(controller: _tabController, tabs: const [
          Tab(text: "Assign Teachers", icon: Icon(Icons.person)),
          Tab(text: "Assign Groups", icon: Icon(Icons.groups)),
        ]),
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : TabBarView(controller: _tabController, children: [
            _buildCourseList('teacher'),
            _buildCourseList('group'),
          ]),
    );
  }
}