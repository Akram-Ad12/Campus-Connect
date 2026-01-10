// ignore_for_file: unused_import, use_build_context_synchronously, deprecated_member_use
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../globals.dart' as globals;

class AttendancePage extends StatefulWidget {
  final List<dynamic> courses;
  final List<dynamic> groups;

  const AttendancePage({super.key, required this.courses, required this.groups});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  String? selectedCourse;
  String? selectedGroup;
  int? selectedWeek;
  List<dynamic> students = [];
  bool isLoading = false;

  final List<int> weeks = List.generate(16, (index) => index + 1);
  List<dynamic> getFilteredGroups() {
  if (selectedCourse == null) return [];
  return widget.groups.where((group) {
    // Ensure we are comparing the course_name inside the map to the selected string
    return group['course_name'].toString() == selectedCourse;
  }).toList();
}

  // Fetch the student list for the specific Week/Group/Course combo
  Future<void> fetchAttendanceList() async {
    if (selectedCourse == null || selectedGroup == null || selectedWeek == null) return;

    setState(() => isLoading = true);
    
    final url = Uri.parse('http://127.0.0.1:8000/api/teacher/get-attendance').replace(
      queryParameters: {
        'course_name': selectedCourse,
        'group_name': selectedGroup,
        'week': selectedWeek.toString(),
      },
    );

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer ${globals.userToken}',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() => students = jsonDecode(response.body));
      }
    } catch (e) {
      print("Error fetching attendance: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Toggle logic - Updates database in real-time
  Future<void> _onToggle(int studentId, bool newValue, int index) async {
    // Update local UI immediately for responsiveness
    setState(() {
      students[index]['is_present'] = newValue;
    });

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/teacher/toggle-attendance'),
        headers: {
          'Authorization': 'Bearer ${globals.userToken}',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'student_id': studentId,
          'course_name': selectedCourse,
          'week': selectedWeek,
          'is_present': newValue,
        }),
      );

      if (response.statusCode != 200) {
        // Rollback UI if the backend request fails
        setState(() {
          students[index]['is_present'] = !newValue;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to update attendance")),
        );
      }
    } catch (e) {
      print("Error toggling attendance: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mark Attendance"),
        backgroundColor: const Color(0xFF673AB7),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: Column(
              children: [
                // 1. Course Selection
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: "Course", prefixIcon: Icon(Icons.book)),
                  hint: const Text("Select Course"),
                  value: selectedCourse,
                  items: widget.courses.map((c) => DropdownMenuItem(value: c.toString(), child: Text(c.toString()))).toList(),
                  onChanged: (v) {
                    setState(() {
                      selectedCourse = v;
                      selectedGroup = null; // Reset children
                      selectedWeek = null;
                      students = [];
                    });
                  },
                ),
                const SizedBox(height: 10),

                // 2. Group Selection (Disabled if no Course)
DropdownButtonFormField<String>(
  decoration: InputDecoration(
    labelText: "Group", 
    prefixIcon: const Icon(Icons.group),
    enabled: selectedCourse != null,
  ),
  value: selectedGroup,
  items: selectedCourse == null 
      ? null 
      : getFilteredGroups().map((g) {
          // CHANGE THIS: Extract only the group_name string for the value
          String nameOnly = g['group_name'].toString(); 
          return DropdownMenuItem<String>(
            value: nameOnly, // This ensures 'selectedGroup' stays a String
            child: Text(nameOnly),
          );
        }).toList(),
  onChanged: (v) {
    setState(() {
      selectedGroup = v; // Still a String, so your API calls remain correct
      selectedWeek = null;
      students = [];
    });
  },
),
                const SizedBox(height: 10),

                // 3. Week Selection (Disabled if no Group)
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    labelText: "Week", 
                    prefixIcon: const Icon(Icons.calendar_month),
                    enabled: selectedGroup != null,
                  ),
                  hint: Text("Select Week", style: TextStyle(color: selectedGroup == null ? Colors.grey : Colors.black)),
                  value: selectedWeek,
                  items: selectedGroup == null 
                      ? null 
                      : weeks.map((w) => DropdownMenuItem(value: w, child: Text("Week $w"))).toList(),
                  onChanged: (v) {
                    setState(() {
                      selectedWeek = v;
                    });
                    fetchAttendanceList();
                  },
                ),
              ],
            ),
          ),

          // Student List Display
          Expanded(
            child: isLoading 
              ? const Center(child: CircularProgressIndicator())
              : students.isEmpty && selectedWeek != null
                ? const Center(child: Text("No students found in this group"))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student = students[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: CheckboxListTile(
                          title: Text(
                            student['name'],
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text("Student ID: ${student['id']}"),
                          value: student['is_present'] == true,
                          activeColor: const Color(0xFF673AB7),
                          onChanged: (bool? val) {
                            if (val != null) {
                              _onToggle(student['id'], val, index);
                            }
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}