// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../globals.dart' as globals;

class StudentGradesPage extends StatefulWidget {
  const StudentGradesPage({super.key});

  @override
  _StudentGradesPageState createState() => _StudentGradesPageState();
}

class _StudentGradesPageState extends State<StudentGradesPage> {
  List<dynamic> _grades = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchGrades();
  }

  double? _calculateRawAvg(dynamic cc, dynamic control) {
    if (cc == null || control == null) return null;
    double ccVal = double.tryParse(cc.toString()) ?? 0;
    double ctrlVal = double.tryParse(control.toString()) ?? 0;
    return (ccVal * 0.3) + (ctrlVal * 0.7);
  }

  Future<void> _fetchGrades() async {
    try {
      final response = await http.get(
        Uri.parse('http://${globals.serverIP}:8000/api/student/grades'),
        headers: {
          'Authorization': 'Bearer ${globals.userToken}',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          _grades = jsonDecode(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      appBar: AppBar(
        title: Text("Academic Grades", 
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
                              // Header Section
                              Container(
                                color: const Color(0xFFFBFBFF),
                                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                                child: Table(
                                  columnWidths: const {
                                    0: FlexColumnWidth(3), // Course name gets more space
                                    1: FlexColumnWidth(1),
                                    2: FlexColumnWidth(1),
                                    3: FlexColumnWidth(1.5), // Avg badge needs a bit more
                                  },
                                  children: [
                                    TableRow(
                                      children: [
                                        _headerText('COURSE'),
                                        _headerText('CC'),
                                        _headerText('CTRL'),
                                        Center(child: _headerText('AVG')),
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
                                itemCount: _grades.length,
                                separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F1F1)),
                                itemBuilder: (context, index) {
                                  final grade = _grades[index];
                                  double? rawAvg = _calculateRawAvg(grade['cc'], grade['control']);
                                  bool isPassed = (rawAvg ?? 0) >= 10;

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                                    child: Table(
                                      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                      columnWidths: const {
                                        0: FlexColumnWidth(3),
                                        1: FlexColumnWidth(1),
                                        2: FlexColumnWidth(1),
                                        3: FlexColumnWidth(1.5),
                                      },
                                      children: [
                                        TableRow(
                                          children: [
                                            Text(grade['course_name'] ?? 'N/A', 
                                              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF455A64)),
                                              overflow: TextOverflow.ellipsis),
                                            _cellText(grade['cc']?.toString() ?? '--'),
                                            _cellText(grade['control']?.toString() ?? '--'),
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: _buildAverageBadge(rawAvg, isPassed),
                                            ),
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

  Widget _cellText(String text) {
    return Text(text, 
      style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF2D3142)));
  }

  Widget _buildAverageBadge(double? rawAvg, bool isPassed) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: rawAvg == null 
            ? Colors.grey.shade50 
            : (isPassed ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE)),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: rawAvg == null 
              ? Colors.grey.shade200 
              : (isPassed ? Colors.green.shade100 : Colors.red.shade100)
        ),
      ),
      child: Text(
        rawAvg?.toStringAsFixed(2) ?? '--',
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: rawAvg == null 
              ? Colors.grey 
              : (isPassed ? Colors.green.shade700 : Colors.red.shade700)
        ),
      ),
    );
  }
}