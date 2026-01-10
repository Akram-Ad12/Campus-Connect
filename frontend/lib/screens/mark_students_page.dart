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
  List<dynamic> getFilteredGroups() {
  if (selectedCourse == null) return [];
  return widget.groups.where((group) {
    // Ensure we are comparing the course_name inside the map to the selected string
    return group['course_name'].toString() == selectedCourse;
  }).toList();
}

  Future<void> fetchStudents() async {
  if (selectedCourse == null || selectedGroup == null) return;
  
  // Use Uri.http or Uri.parse with Query Parameters for safety
  final url = Uri.parse('http://127.0.0.1:8000/api/teacher/get-students').replace(
    queryParameters: {
      'course_name': selectedCourse,
      'group_name': selectedGroup,
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
      setState(() {
        students = jsonDecode(response.body);
      });
    } else {
      print("Error: ${response.statusCode} - ${response.body}");
    }
  } catch (e) {
    print("Request failed: $e");
  }
}

  Future<void> updateDatabase(int studentId, String col, String val) async {
    double? value = double.tryParse(val);
    if (value == null || value < 0 || value > 20) return; // Validation handled in UI error text

    await http.post(
      Uri.parse('http://127.0.0.1:8000/api/teacher/update-grade'),
      headers: {'Authorization': 'Bearer ${globals.userToken}', 'Content-Type': 'application/json'},
      body: jsonEncode({
        'student_id': studentId,
        'course_name': selectedCourse,
        'column': col,
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
          // Selectors
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(child: DropdownButton<String>(
                  hint: const Text("Course"),
                  value: selectedCourse,
                  items: widget.courses.map((c) => DropdownMenuItem(value: c.toString(), child: Text(c.toString()))).toList(),
                  onChanged: (v) => setState(() { selectedCourse = v; fetchStudents(); }),
                )),
                const SizedBox(width: 10),
                Expanded(child: DropdownButton<String>(
                  hint: const Text("Group"),
                  value: selectedGroup,
                  items: widget.groups.where((g) => g['course_name'] == selectedCourse).map((g) {
  String nameOnly = g['group_name'].toString();
  return DropdownMenuItem<String>(
    value: nameOnly,
    child: Text(nameOnly),
  );
}).toList(),
                  onChanged: (v) => setState(() { selectedGroup = v; fetchStudents(); }),
                )),
              ],
            ),
          ),

          // Student List
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
                        _buildGradeField(student['id'], "cc", student['cc'].toString(), "CC"),
                        const SizedBox(width: 20),
                        _buildGradeField(student['id'], "control", student['control'].toString(), "Control"),
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

  Widget _buildGradeField(int id, String col, String initialVal, String label) {
    return SizedBox(
      width: 80,
      child: TextFormField(
        initialValue: initialVal == "0" ? "" : initialVal,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: label, errorStyle: const TextStyle(fontSize: 10)),
        onChanged: (val) {
          double? n = double.tryParse(val);
          if (n != null && n >= 0 && n <= 20) {
            updateDatabase(id, col, val);
          }
        },
        validator: (val) {
          double? n = double.tryParse(val ?? "");
          if (n == null || n < 0 || n > 20) return "0-20 only";
          return null;
        },
        autovalidateMode: AutovalidateMode.onUserInteraction,
      ),
    );
  }
}