// ignore_for_file: avoid_print, use_build_context_synchronously, library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  bool isLoading = false;
  
  Map<int, TextEditingController> ccControllers = {};
  Map<int, TextEditingController> controlControllers = {};

  List<dynamic> getFilteredGroups() {
    if (selectedCourse == null) return [];
    return widget.groups.where((group) => group['course_name'].toString() == selectedCourse).toList();
  }

  Future<void> fetchStudents() async {
    if (selectedCourse == null || selectedGroup == null) return;
    
    setState(() => isLoading = true);
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
            ccControllers[id] = TextEditingController(text: student['cc']?.toString() ?? "");
            controlControllers[id] = TextEditingController(text: student['control']?.toString() ?? "");
          }
        });
      }
    } catch (e) {
      print("Fetch error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> updateDatabase(int studentId, String col, String val) async {
    double? value = double.tryParse(val);
    if (value == null || value < 0 || value > 20) return;

    try {
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
          'column': col,
          'val': value
        }),
      );
    } catch (e) {
      print("Update error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: Text("Student Grades", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: const Color(0xFF1A1A1A),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Course Selection
          _buildHeaderLabel("1. Choose Course"),
          _buildPillSelector(widget.courses.map((e) => e.toString()).toList(), selectedCourse, (val) {
            setState(() {
              selectedCourse = val;
              selectedGroup = null;
              students = [];
            });
          }),

          // 2. Group Selection
          _buildHeaderLabel("2. Choose Group"),
          _buildPillSelector(
            getFilteredGroups().map((e) => e['group_name'].toString()).toList(), 
            selectedGroup, 
            (val) {
              setState(() => selectedGroup = val);
              fetchStudents();
            },
            isEnabled: selectedCourse != null
          ),

          const SizedBox(height: 20),

          // 3. Grade Table
          Expanded(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 10),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
              ),
              child: isLoading 
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF673AB7)))
                : students.isEmpty 
                  ? _buildEmptyState()
                  : _buildGradeTable(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradeTable() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: DataTable(
        columnSpacing: 20,
        headingRowHeight: 40,
        horizontalMargin: 10,
        columns: [
          DataColumn(label: Text("Student", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13))),
          DataColumn(label: Text("CC (/20)", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13))),
          DataColumn(label: Text("Exam (/20)", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13))),
        ],
        rows: students.map((student) {
          int id = student['id'];
          return DataRow(cells: [
            DataCell(
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(student['name'], style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500)),
                  Text("ID: $id", style: GoogleFonts.poppins(fontSize: 10, color: Colors.black38)),
                ],
              ),
            ),
            DataCell(_buildGradeInput(id, "cc")),
            DataCell(_buildGradeInput(id, "control")),
          ]);
        }).toList(),
      ),
    );
  }

  Widget _buildGradeInput(int id, String type) {
    return Container(
      width: 60,
      height: 40,
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: TextFormField(
        controller: type == "cc" ? ccControllers[id] : controlControllers[id],
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF673AB7)),
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFF0EEF7),
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF673AB7), width: 1.5)),
        ),
        onChanged: (val) => updateDatabase(id, type, val),
      ),
    );
  }

  // --- UI Components ---

  Widget _buildHeaderLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 25, top: 15, bottom: 8),
      child: Text(text, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black45, letterSpacing: 0.8)),
    );
  }

  Widget _buildPillSelector(List<String> items, String? currentSelection, Function(String) onSelect, {bool isEnabled = true}) {
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.4,
      child: SizedBox(
        height: 40,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: items.length,
          itemBuilder: (context, index) {
            bool isSelected = currentSelection == items[index];
            return GestureDetector(
              onTap: isEnabled ? () => onSelect(items[index]) : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF673AB7) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isSelected ? Colors.transparent : Colors.black12),
                ),
                child: Text(
                  items[index],
                  style: GoogleFonts.poppins(
                    color: isSelected ? Colors.white : Colors.black54,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.group, size: 50, color: Colors.black12),
          const SizedBox(height: 10),
          Text("Select Course & Group to view records", 
            style: GoogleFonts.poppins(color: Colors.black38, fontSize: 13)),
        ],
      ),
    );
  }
}