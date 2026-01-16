// ignore_for_file: library_private_types_in_public_api, deprecated_member_use
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
            color: present ? const Color(0xFF673AB7) : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(3), // Slightly more rounded for premium look
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      appBar: AppBar(
        title: Text("Attendance Records", 
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFF2D3142), fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2D3142)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF673AB7)))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, bottom: 12.0),
                    child: Text("Semester Overview", 
                      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black38, letterSpacing: 0.5)),
                  ),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8)),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              Container(
                                color: const Color(0xFFFBFBFF),
                                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                                child: Table(
                                  columnWidths: const {
                                    0: FlexColumnWidth(2.5),
                                    1: FlexColumnWidth(1.2),
                                    2: FlexColumnWidth(2.3),
                                  },
                                  children: [
                                    TableRow(
                                      children: [
                                        _headerText('COURSE'),
                                        _headerText('COUNT'),
                                        _headerText('WEEKS'),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(height: 1, color: Color(0xFFF1F1F1)),
                              // Body Section
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _attendanceData.length,
                                separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F1F1)),
                                itemBuilder: (context, index) {
                                  final data = _attendanceData[index];

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                                    child: Table(
                                      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                      columnWidths: const {
                                        0: FlexColumnWidth(2.5),
                                        1: FlexColumnWidth(1.2),
                                        2: FlexColumnWidth(2.3),
                                      },
                                      children: [
                                        TableRow(
                                          children: [
                                            Text(data['course_name'] ?? 'N/A', 
                                              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF455A64)),
                                              overflow: TextOverflow.ellipsis),
                                            Text("${data['total_attended']}/16", 
                                              style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF2D3142))),
                                            _buildWeekGrid(data['attended_weeks']),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _headerText(String text) {
    return Text(text, 
      style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF673AB7), letterSpacing: 1));
  }
}