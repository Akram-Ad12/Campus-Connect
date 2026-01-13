// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, deprecated_member_use
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  List<dynamic> filteredData = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();

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
          // Sort alphabetically by name
          studentData.sort((a, b) => (a['name'] ?? "").compareTo(b['name'] ?? ""));
          filteredData = studentData;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
      setState(() => isLoading = false);
    }
  }

  void _filterStudents(String query) {
    setState(() {
      filteredData = studentData
          .where((s) => s['name'].toString().toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: Column(
          children: [
            Text(widget.groupName, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
            Text(widget.courseName, style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70)),
          ],
        ),
        backgroundColor: const Color(0xFF673AB7),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF673AB7)))
                : filteredData.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        itemCount: filteredData.length,
                        itemBuilder: (context, index) => _buildStudentCard(filteredData[index]),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(15),
      color: const Color(0xFF673AB7),
      child: TextField(
        controller: _searchController,
        onChanged: _filterStudents,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "Search students...",
          hintStyle: const TextStyle(color: Colors.white60),
          prefixIcon: const Icon(Icons.search, color: Colors.white60),
          filled: true,
          fillColor: Colors.white.withOpacity(0.15),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildStudentCard(dynamic student) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF673AB7).withOpacity(0.1),
                  child: Text(
                    student['name']?[0] ?? "?",
                    style: const TextStyle(color: Color(0xFF673AB7), fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    student['name'] ?? "Unknown",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15, color: const Color(0xFF2D3436)),
                  ),
                ),
                _buildAttendanceBadge(student['attendance'] ?? 0),
              ],
            ),
            const Divider(height: 24, thickness: 0.5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildGradeStat("CC Mark", student['cc']),
                _buildGradeStat("Control", student['control']),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradeStat(String label, dynamic value) {
    String displayValue = (value == null || value == "") ? "-" : value.toString();
    return Column(
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 11, color: Colors.black38)),
        const SizedBox(height: 4),
        Text(
          displayValue,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: displayValue == "-" ? Colors.black26 : const Color(0xFF673AB7),
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceBadge(int count) {
    // Color coded based on attendance
    Color badgeColor = count > 12 ? Colors.green : (count > 8 ? Colors.orange : Colors.red);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today_rounded, size: 12, color: badgeColor),
          const SizedBox(width: 5),
          Text(
            "$count/16",
            style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: badgeColor),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off_outlined, size: 60, color: Colors.black12),
          const SizedBox(height: 10),
          Text("No students found", style: GoogleFonts.poppins(color: Colors.black38)),
        ],
      ),
    );
  }
}