// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, deprecated_member_use
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../globals.dart' as globals;

class GroupDetailsPage extends StatefulWidget {
  final String groupName;
  final String courseName;

  const GroupDetailsPage({super.key, required this.groupName, required this.courseName});

  @override
  State<GroupDetailsPage> createState() => _GroupDetailsPageState();
}

class _GroupDetailsPageState extends State<GroupDetailsPage> {
  List<dynamic> studentData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDetails();
  }

  Future<void> fetchDetails() async {
    final url = Uri.parse('http://${globals.serverIP}:8000/api/teacher/group-details').replace(
      queryParameters: {
        'group_name': widget.groupName,
        'course_name': widget.courseName,
      },
    );

    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer ${globals.userToken}',
        'Accept': 'application/json',
      });

      if (response.statusCode == 200) {
        setState(() {
          studentData = jsonDecode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.groupName} - ${widget.courseName}"),
        backgroundColor: const Color(0xFF673AB7),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Full Name')),
                    DataColumn(label: Text('CC')),
                    DataColumn(label: Text('Control')),
                    DataColumn(label: Text('Attendance')),
                  ],
                  // Update the rows section in group_details_page.dart
rows: studentData.map((student) {
  return DataRow(cells: [
    DataCell(Text(student['name'] ?? "Unknown")),
    
    // FIX: Change 'cc_mark' to 'cc' to match your DB
    DataCell(Text(
      (student['cc'] == null || student['cc'] == "") ? "-" : student['cc'].toString()
    )),
    
    // FIX: Change 'control_mark' to 'control' to match your DB
    DataCell(Text(
      (student['control'] == null || student['control'] == "") ? "-" : student['control'].toString()
    )),
    
    DataCell(Text("${student['attendance']}/16")),
  ]);
}).toList(),
                ),
              ),
            ),
    );
  }
}