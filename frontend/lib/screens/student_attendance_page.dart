// ignore_for_file: library_private_types_in_public_api, deprecated_member_use
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../globals.dart' as globals;

class StudentAttendancePage extends StatefulWidget {
  const StudentAttendancePage({super.key});

  @override
  _StudentAttendancePageState createState() => _StudentAttendancePageState();
}

class _StudentAttendancePageState extends State<StudentAttendancePage> {
  List<dynamic> _attendanceData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAttendance();
  }

  Future<void> _fetchAttendance() async {
    try {
      final response = await http.get(
        Uri.parse('http://${globals.serverIP}:8000/api/student/attendance'),
        headers: {
          'Authorization': 'Bearer ${globals.userToken}',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          _attendanceData = jsonDecode(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // Build the 8x2 grid of cubes
  Widget _buildWeekGrid(List<dynamic> attendedWeeks) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCubeRow(1, 8, attendedWeeks),
        const SizedBox(height: 4),
        _buildCubeRow(9, 16, attendedWeeks),
      ],
    );
  }

  Widget _buildCubeRow(int start, int end, List<dynamic> attendedWeeks) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(8, (index) {
        int currentWeek = start + index;
        bool present = attendedWeeks.contains(currentWeek);
        return Container(
          width: 12,
          height: 12,
          margin: const EdgeInsets.only(right: 3),
          decoration: BoxDecoration(
            color: present ? const Color(0xFF673AB7) : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Attendance", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF673AB7),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF673AB7)))
          : Padding(
              padding: const EdgeInsets.all(15.0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: SingleChildScrollView(
                  child: DataTable(
                    horizontalMargin: 15,
                    columnSpacing: 20,
                    headingRowColor: MaterialStateProperty.all(const Color(0xFFF3E5F5)),
                    columns: const [
                      DataColumn(label: Text('Course', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Count', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Weeks', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: _attendanceData.map((data) {
                      return DataRow(cells: [
                        DataCell(Text(data['course_name'] ?? 'N/A', style: const TextStyle(fontSize: 13))),
                        DataCell(Text("${data['total_attended']}/16")),
                        DataCell(
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: _buildWeekGrid(data['attended_weeks']),
                          ),
                        ),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            ),
    );
  }
}