import 'package:flutter/material.dart';
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

  // Formula: (CC * 0.3) + (Control * 0.7)
  double? _calculateRawAvg(dynamic cc, dynamic control) {
    if (cc == null || control == null) return null;
    double ccVal = double.tryParse(cc.toString()) ?? 0;
    double ctrlVal = double.tryParse(control.toString()) ?? 0;
    return (ccVal * 0.3) + (ctrlVal * 0.7);
  }

  Future<void> _fetchGrades() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/student/grades'),
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
      backgroundColor: const Color(0xFFF5F5F7), 
      appBar: AppBar(
        title: const Text("My Grades", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF673AB7),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF673AB7)))
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
              child: Container(
                width: double.infinity, // Ensures container takes full width
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.grey.shade200),
                    child: DataTable(
                      columnSpacing: 15, // Reduced spacing to fit 4 columns better
                      headingRowHeight: 56,
                      dataRowHeight: 60,
                      headingRowColor: MaterialStateProperty.all(const Color(0xFFF3E5F5)),
                      columns: const [
                        DataColumn(label: Text('Course', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('CC', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Ctrl', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('AVG', style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                      rows: _grades.map((grade) {
                        double? rawAvg = _calculateRawAvg(grade['cc'], grade['control']);
                        bool isPassed = (rawAvg ?? 0) >= 10;
                        
                        return DataRow(cells: [
                          DataCell(Text(grade['course_name'] ?? 'N/A', style: const TextStyle(fontSize: 13))),
                          DataCell(Text(grade['cc']?.toString() ?? '--')),
                          DataCell(Text(grade['control']?.toString() ?? '--')),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: rawAvg == null 
                                    ? Colors.grey.shade100 
                                    : (isPassed ? Colors.green.shade50 : Colors.red.shade50),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: rawAvg == null 
                                      ? Colors.grey.shade300 
                                      : (isPassed ? Colors.green.shade200 : Colors.red.shade200)
                                ),
                              ),
                              child: Text(
                                rawAvg?.toStringAsFixed(2) ?? '--',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: rawAvg == null 
                                      ? Colors.grey 
                                      : (isPassed ? Colors.green.shade700 : Colors.red.shade700)
                                ),
                              ),
                            ),
                          ),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}