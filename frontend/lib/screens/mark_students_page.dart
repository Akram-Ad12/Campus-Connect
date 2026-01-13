import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../globals.dart' as globals;

class MarkStudentsPage extends StatefulWidget {
  final List<dynamic> courses;
  final List<dynamic> groups;

  const MarkStudentsPage({super.key, required this.courses, required this.groups});

  @override
  State<MarkStudentsPage> createState() => _MarkStudentsPageState();
}

class _MarkStudentsPageState extends State<MarkStudentsPage> {
  String? selectedCourse;
  String? selectedGroup;
  List<dynamic> students = [];
  Map<int, TextEditingController> ccControllers = {};
  Map<int, TextEditingController> controlControllers = {};

  List<dynamic> getFilteredGroups() {
    if (selectedCourse == null) return [];
    return widget.groups.where((group) => group['course_name'].toString() == selectedCourse).toList();
  }

  Future<void> fetchStudents() async {
    if (selectedCourse == null || selectedGroup == null) return;
    
    final url = Uri.parse('http://${globals.serverIP}:8000/api/teacher/get-students').replace(
      queryParameters: {'course_name': selectedCourse, 'group_name': selectedGroup},
    );

    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer ${globals.userToken}',
        'Accept': 'application/json',
      });

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          students = data;
          ccControllers.clear();
          controlControllers.clear();
          for (var student in students) {
            int id = student['id'];
            // Use 'cc' and 'control' to match your database
            ccControllers[id] = TextEditingController(text: student['cc']?.toString() ?? "");
            controlControllers[id] = TextEditingController(text: student['control']?.toString() ?? "");
          }
        });
      }
    } catch (e) { print("Fetch error: $e"); }
  }

  Future<void> updateDatabase(int studentId, String col, String val) async {
    double? value = double.tryParse(val);
    if (value == null || value < 0 || value > 20) return;

    await http.post(
      Uri.parse('http://${globals.serverIP}:8000/api/teacher/update-grade'),
      headers: {
        'Authorization': 'Bearer ${globals.userToken}',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'student_id': studentId,
        'course_name': selectedCourse,
        'column': col, // Sends "cc" or "control"
        'val': value
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mark Students"), backgroundColor: const Color(0xFF673AB7)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(child: DropdownButton<String>(
                  hint: const Text("Course"),
                  value: selectedCourse,
                  items: widget.courses.map((c) => DropdownMenuItem(value: c.toString(), child: Text(c.toString()))).toList(),
                  onChanged: (v) => setState(() { selectedCourse = v; selectedGroup = null; students = []; }),
                )),
                const SizedBox(width: 10),
                Expanded(child: DropdownButton<String>(
                  hint: const Text("Group"),
                  value: selectedGroup,
                  items: getFilteredGroups().map((g) => DropdownMenuItem(value: g['group_name'].toString(), child: Text(g['group_name'].toString()))).toList(),
                  onChanged: (v) => setState(() { selectedGroup = v; fetchStudents(); }),
                )),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  child: ListTile(
                    title: Text(student['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Row(
                      children: [
                        _buildGradeField(student['id'], "cc", "CC"),
                        const SizedBox(width: 20),
                        _buildGradeField(student['id'], "control", "Control"),
                      ],
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

  Widget _buildGradeField(int id, String col, String label) {
    final controller = (col == "cc") ? ccControllers[id] : controlControllers[id];
    return SizedBox(
      width: 80,
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: label),
        onChanged: (val) => updateDatabase(id, col, val),
      ),
    );
  }
}