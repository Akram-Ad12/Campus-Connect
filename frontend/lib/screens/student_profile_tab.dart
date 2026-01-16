// ignore_for_file: unused_import, use_build_context_synchronously, deprecated_member_use
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import '../globals.dart' as globals;

class StudentProfileTab extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final VoidCallback onRefresh;

  const StudentProfileTab({super.key, this.userData, required this.onRefresh});

  @override
  State<StudentProfileTab> createState() => _StudentProfileTabState();
}

class _StudentProfileTabState extends State<StudentProfileTab> {
  Future<void> _updateProfile(String field, String value) async {
    try {
      final response = await http.post(
        Uri.parse('http://${globals.serverIP}:8000/api/student/update-profile'),
        headers: {
          'Authorization': 'Bearer ${globals.userToken}',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'column': field, 'val': value}),
      );

      if (response.statusCode == 200) {
        widget.onRefresh();
      }
    } catch (e) {
      debugPrint("Update error: $e");
    }
  }

  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://${globals.serverIP}:8000/api/student/upload-avatar'),
      );
      request.headers['Authorization'] = 'Bearer ${globals.userToken}';
      request.files.add(await http.MultipartFile.fromPath('avatar', image.path));

      var response = await request.send();
      if (response.statusCode == 200) {
        widget.onRefresh();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.userData;
    final String name = data?['name'] ?? "Student Name";
    final String email = data?['email'] ?? "email@univ.dz";
    final String group = data?['group_name'] ?? "Not Assigned";
    final String sex = data?['sex'] ?? "Not specified";
    final String dob = data?['dob'] ?? "--/--/----";
    final String pob = data?['pob'] ?? "/";
    final String? profilePic = data?['profile_picture'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Row(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF673AB7).withOpacity(0.1), width: 4),
                      ),
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: const Color(0xFFF5F3FF),
                        backgroundImage: profilePic != null
                            ? NetworkImage('http://${globals.serverIP}:8000/storage/$profilePic')
                            : const AssetImage('assets/user.png') as ImageProvider,
                      ),
                    ),
                    GestureDetector(
                      onTap: _pickAndUploadImage,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(color: Color(0xFF673AB7), shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1A1A1A),
                          )),
                      Text(email,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.black45,
                          )),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.verified_user_rounded, size: 14, color: Colors.blue.shade400),
                          const SizedBox(width: 4),
                          Text("Verified Student", 
                            style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.blue.shade400)),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          
          const SizedBox(height: 35),
          Text("Academic Information", 
            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black38, letterSpacing: 0.5)),
          const SizedBox(height: 15),

          _buildLockedTile(Icons.groups_rounded, "Group", group),

          const SizedBox(height: 30),
          Text("Personal Information", 
            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black38, letterSpacing: 0.5)),
          const SizedBox(height: 15),

          _buildEditableTile(Icons.wc_rounded, "Sex", sex, () => _showSexPicker(sex)),
          const SizedBox(height: 12),
          _buildEditableTile(Icons.cake_rounded, "Date of Birth", dob, () => _showDatePicker(dob)),
          const SizedBox(height: 12),
          _buildEditableTile(Icons.location_on_rounded, "Place of Birth", pob, () => _showTextEdit("Place of Birth", pob, 'pob')),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildEditableTile(IconData icon, String label, String value, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.02)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: const Color(0xFF673AB7).withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: const Color(0xFF673AB7), size: 22),
        ),
        title: Text(label, style: GoogleFonts.poppins(fontSize: 11, color: Colors.black45, fontWeight: FontWeight.w500)),
        subtitle: Text(value, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF455A64))),
        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.black26),
      ),
    );
  }

  Widget _buildLockedTile(IconData icon, String label, String value) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: Colors.black26, size: 22),
        ),
        title: Text(label, style: GoogleFonts.poppins(fontSize: 11, color: Colors.black38, fontWeight: FontWeight.w500)),
        subtitle: Text(value, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black38)),
        trailing: const Icon(Icons.lock_outline_rounded, size: 18, color: Colors.black26),
      ),
    );
  }

  void _showSexPicker(String currentSex) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Select Sex", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 15),
            ListTile(
                title: Center(child: Text("Male", style: GoogleFonts.poppins())),
                onTap: () {
                  _updateProfile('sex', 'Male');
                  Navigator.pop(context);
                }),
            ListTile(
                title: Center(child: Text("Female", style: GoogleFonts.poppins())),
                onTap: () {
                  _updateProfile('sex', 'Female');
                  Navigator.pop(context);
                }),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _showDatePicker(String currentDob) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF673AB7)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      _updateProfile('dob', "${picked.day}/${picked.month}/${picked.year}");
    }
  }

  void _showTextEdit(String title, String current, String field) {
    TextEditingController controller = TextEditingController(text: current);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Edit $title", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
        content: TextField(
          controller: controller, 
          style: GoogleFonts.poppins(),
          decoration: InputDecoration(
            hintText: "Enter $title",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          )
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel", style: GoogleFonts.poppins(color: Colors.grey))),
          TextButton(
              onPressed: () {
                _updateProfile(field, controller.text);
                Navigator.pop(context);
              },
              child: Text("Save", style: GoogleFonts.poppins(color: const Color(0xFF673AB7), fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}