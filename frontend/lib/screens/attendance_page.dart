// ignore_for_file: avoid_print, use_build_context_synchronously, library_private_types_in_public_api, deprecated_member_use
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      return group['course_name'].toString() == selectedCourse;
    }).toList();
  }

  Future<void> fetchAttendanceList() async {
    if (selectedCourse == null || selectedGroup == null || selectedWeek == null) return;

    setState(() => isLoading = true);
    final url = Uri.parse('http://${globals.serverIP}:8000/api/teacher/get-attendance').replace(
      queryParameters: {
        'course_name': selectedCourse,
        'group_name': selectedGroup,
        'week': selectedWeek.toString(),
      },
    );

    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer ${globals.userToken}',
        'Accept': 'application/json',
      });

      if (response.statusCode == 200) {
        setState(() => students = jsonDecode(response.body));
      }
    } catch (e) {
      print("Error fetching attendance: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _onToggle(int studentId, bool newValue, int index) async {
    setState(() => students[index]['is_present'] = newValue);

    try {
      final response = await http.post(
        Uri.parse('http://${globals.serverIP}:8000/api/teacher/toggle-attendance'),
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
        setState(() => students[index]['is_present'] = !newValue);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to update attendance")));
      }
    } catch (e) {
      print("Error toggling: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: Text("Mark Attendance", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: const Color(0xFF1A1A1A),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSelectionStep("1. Select Course", widget.courses.map((e) => e.toString()).toList(), selectedCourse, (val) {
            setState(() {
              selectedCourse = val;
              selectedGroup = null;
              selectedWeek = null;
              students = [];
            });
          }),
          _buildSelectionStep("2. Select Group", getFilteredGroups().map((e) => e['group_name'].toString()).toList(), selectedGroup, (val) {
            setState(() {
              selectedGroup = val;
              selectedWeek = null;
              students = [];
            });
          }, isEnabled: selectedCourse != null),
          _buildSelectionStep("3. Select Week", weeks.map((e) => "W $e").toList(), selectedWeek != null ? "W $selectedWeek" : null, (val) {
            setState(() => selectedWeek = int.parse(val.replaceAll("W ", "")));
            fetchAttendanceList();
          }, isEnabled: selectedGroup != null),
          
          const SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Students List", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A1A))),
                if (students.isNotEmpty)
                  Text("${students.where((s) => s['is_present'] == true).length}/${students.length} Present", 
                    style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF673AB7), fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF673AB7)))
                : students.isEmpty
                    ? Center(child: Text("Configure Course & Week to load students", style: GoogleFonts.poppins(color: Colors.black38, fontSize: 13)))
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 10, bottom: 30),
                        itemCount: students.length,
                        itemBuilder: (context, index) {
                          final student = students[index];
                          bool isPresent = student['is_present'] == true;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                            decoration: BoxDecoration(
                              color: isPresent ? const Color(0xFFF3E5F5).withOpacity(0.5) : Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: isPresent ? const Color(0xFF673AB7).withOpacity(0.2) : Colors.black.withOpacity(0.05),
                              ),
                            ),
                            child: CheckboxListTile(
                              value: isPresent,
                              activeColor: const Color(0xFF673AB7),
                              checkColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                              onChanged: (val) => _onToggle(student['id'], val ?? false, index),
                              title: Text(student['name'], style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14, color: isPresent ? const Color(0xFF673AB7) : Colors.black87)),
                              subtitle: Text("Student ID: ${student['id']}", style: GoogleFonts.poppins(fontSize: 11, color: Colors.black45)),
                              secondary: CircleAvatar(
                                backgroundColor: isPresent ? const Color(0xFF673AB7) : const Color(0xFFF0F0F0),
                                radius: 18,
                                child: Text(student['name'][0], style: TextStyle(color: isPresent ? Colors.white : Colors.black45, fontSize: 14, fontWeight: FontWeight.bold)),
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

  Widget _buildSelectionStep(String title, List<String> items, String? currentSelection, Function(String) onSelect, {bool isEnabled = true}) {
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 25, top: 15, bottom: 8),
            child: Text(title, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black45, letterSpacing: 0.5)),
          ),
          SizedBox(
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
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF673AB7) : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isSelected ? Colors.transparent : Colors.black.withOpacity(0.08)),
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
        ],
      ),
    );
  }
}