// ignore_for_file: unused_import, use_build_context_synchronously, deprecated_member_use
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart'; // Ensure this is in pubspec.yaml
import '../globals.dart' as globals;

class StudentProfileTab extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final VoidCallback onRefresh;

  const StudentProfileTab({super.key, this.userData, required this.onRefresh});

  @override
  State<StudentProfileTab> createState() => _StudentProfileTabState();
}

class _StudentProfileTabState extends State<StudentProfileTab> {
  // Logic to handle database updates for sex, dob, and pob
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
        widget.onRefresh(); // Refresh the source of truth in StudentHome
      }
    } catch (e) {
      debugPrint("Update error: $e");
    }
  }

  // Logic to handle profile picture upload
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
        widget.onRefresh(); // Refresh to show new image across all tabs
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mapping data from the 'source of truth' passed from StudentHome
    final data = widget.userData;
    final String name = data?['name'] ?? "Student Name";
    final String email = data?['email'] ?? "email@univ.dz";
    final String group = data?['group_name'] ?? "Not Assigned";
    final String sex = data?['sex'] ?? "Not specified";
    final String dob = data?['dob'] ?? "--/--/----";
    final String pob = data?['pob'] ?? "/";
    final String? profilePic = data?['profile_picture'];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Column(
        children: [
          // 1. Premium Profile Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
            ),
            child: Row(
              children: [
                Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(color: Color(0xFF673AB7), shape: BoxShape.circle),
                      child: CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: profilePic != null
                            ? NetworkImage('http://${globals.serverIP}:8000/storage/$profilePic')
                            : const AssetImage('assets/user.png') as ImageProvider,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickAndUploadImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(color: Color(0xFF673AB7), shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF311B92)),
                      ),
                      Text(
                        email,
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: _pickAndUploadImage,
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFF673AB7).withOpacity(0.1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text("Upload Picture", style: TextStyle(color: Color(0xFF673AB7), fontSize: 12)),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 30),

          const Align(
            alignment: Alignment.centerLeft,
            child: Text("  Academic Information", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          const SizedBox(height: 10),

          // LOCKED FIELD: Group
          _buildLockedTile(Icons.groups_rounded, "Group", group),

          const SizedBox(height: 25),

          const Align(
            alignment: Alignment.centerLeft,
            child: Text("  Personal Information", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          const SizedBox(height: 15),

          _buildEditableTile(Icons.wc_rounded, "Sex", sex, () => _showSexPicker(sex)),
          const SizedBox(height: 12),
          _buildEditableTile(Icons.cake_rounded, "Date of Birth", dob, () => _showDatePicker(dob)),
          const SizedBox(height: 12),
          _buildEditableTile(Icons.location_on_rounded, "Place of Birth", pob, () => _showTextEdit("Place of Birth", pob, 'pob')),
        ],
      ),
    );
  }

  Widget _buildEditableTile(IconData icon, String label, String value, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: const Color(0xFFF5F3FF), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: const Color(0xFF673AB7)),
        ),
        title: Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        subtitle: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
      ),
    );
  }

  Widget _buildLockedTile(IconData icon, String label, String value) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: Colors.grey),
        ),
        title: Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        subtitle: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black45)),
        trailing: const Icon(Icons.lock_outline_rounded, size: 18, color: Colors.grey),
      ),
    );
  }

  void _showSexPicker(String currentSex) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          ListTile(
              title: const Center(child: Text("Male")),
              onTap: () {
                _updateProfile('sex', 'Male');
                Navigator.pop(context);
              }),
          ListTile(
              title: const Center(child: Text("Female")),
              onTap: () {
                _updateProfile('sex', 'Female');
                Navigator.pop(context);
              }),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  void _showDatePicker(String currentDob) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
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
        title: Text("Edit $title"),
        content: TextField(controller: controller, decoration: InputDecoration(hintText: "Enter $title")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
              onPressed: () {
                _updateProfile(field, controller.text);
                Navigator.pop(context);
              },
              child: const Text("Save")),
        ],
      ),
    );
  }
}