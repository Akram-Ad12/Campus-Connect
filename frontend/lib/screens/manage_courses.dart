// ignore_for_file: avoid_print, use_build_context_synchronously, library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    try {
      final uRes = await http.get(Uri.parse('http://${globals.serverIP}:8000/api/admin/users-to-assign'), headers: headers);
      final gRes = await http.get(Uri.parse('http://${globals.serverIP}:8000/api/admin/groups'), headers: headers);
      final aRes = await http.get(Uri.parse('http://${globals.serverIP}:8000/api/admin/course-assignments'), headers: headers);

      if (mounted) {
        setState(() {
          allTeachers = jsonDecode(uRes.body).where((u) => u['role'] == 'teacher').toList();
          allGroups = jsonDecode(gRes.body);
          assignedTeachers = jsonDecode(aRes.body)['teachers'];
          assignedGroups = jsonDecode(aRes.body)['groups'];
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching course data: $e");
    }
  }

  Future<void> toggleAssignment(String course, int id, String type, String action) async {
    await http.post(
      Uri.parse('http://${globals.serverIP}:8000/api/admin/toggle-course-assignment'),
      headers: {'Authorization': 'Bearer ${globals.userToken}', 'Content-Type': 'application/json'},
      body: jsonEncode({'course_name': course, 'id': id, 'type': type, 'action': action}),
    );
    refreshData();
  }

  Widget _buildCourseList(String type) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      itemCount: courses.length,
      itemBuilder: (context, i) {
        String course = courses[i];

        var currentItems = type == 'teacher'
            ? assignedTeachers.where((a) => a['course_name'] == course)
            : assignedGroups.where((a) => a['course_name'] == course);

        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: currentItems.map((item) {
                    final data = type == 'teacher'
                        ? allTeachers.firstWhere((t) => t['id'] == item['teacher_id'], orElse: () => {'name': 'Unknown'})
                        : allGroups.firstWhere((g) => g['id'] == item['group_id'], orElse: () => {'name': 'Unknown'});
                    
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3E5F5).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFCE93D8).withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            data['name'],
                            style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF673AB7), fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => toggleAssignment(course, data['id'], type, 'remove'),
                            child: const Icon(Icons.close, size: 16, color: Color(0xFF673AB7)),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(color: Color(0xFFEEEEEE)),
                ),
                // Modern Dropdown Styling
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FD),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      hint: Text("Add ${type == 'teacher' ? 'Teacher' : 'Group'}", 
                        style: GoogleFonts.poppins(fontSize: 14, color: Colors.black45)),
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF673AB7)),
                      items: (type == 'teacher' ? allTeachers : allGroups).map<DropdownMenuItem<int>>((item) {
                        return DropdownMenuItem(
                          value: item['id'], 
                          child: Text(item['name'], style: GoogleFonts.poppins(fontSize: 14)));
                      }).toList(),
                      onChanged: (val) => toggleAssignment(course, val!, type, 'add'),
                    ),
                  ),
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
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF311B92), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Manage Courses",
          style: GoogleFonts.poppins(color: const Color(0xFF311B92), fontWeight: FontWeight.bold, fontSize: 18),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF673AB7),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF673AB7),
          indicatorWeight: 3,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
          tabs: const [
            Tab(text: "Assign Teachers", icon: Icon(Icons.person_outline, size: 20)),
            Tab(text: "Assign Groups", icon: Icon(Icons.groups_outlined, size: 20)),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF673AB7)))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildCourseList('teacher'),
                _buildCourseList('group'),
              ],
            ),
    );
  }
}