// ignore_for_file: unused_import, use_build_context_synchronously, deprecated_member_use
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../globals.dart' as globals;

class StudentProfileTab extends StatefulWidget {
  const StudentProfileTab({super.key});

  @override
  State<StudentProfileTab> createState() => _StudentProfileTabState();
}

class _StudentProfileTabState extends State<StudentProfileTab> {
  // Mock data - replace with globals.userData or fetch from API
  String sex = "Not specified";
  String dob = "--/--/----";
  String pob = "/";

  Future<void> _updateProfile(String field, String value) async {
    // Implement your API call here to update the DB
    // Update local state on success
    setState(() {
      if (field == 'sex') sex = value;
      if (field == 'dob') dob = value;
      if (field == 'pob') pob = value;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                      child: const CircleAvatar(
                        radius: 45,
                        backgroundImage: AssetImage('user.png'),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => print("Trigger Image Picker"),
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
                      const Text(
                        "Akram Adoui", // From DB
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF311B92)),
                      ),
                      Text(
                        "akram.adoui@univ-dz.com",
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () {}, // Trigger upload logic
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

          // 2. Editable Information Section
          const Align(
            alignment: Alignment.centerLeft,
            child: Text("  Personal Information", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          const SizedBox(height: 15),
          
          _buildEditableTile(Icons.wc_rounded, "Sex", sex, () => _showSexPicker()),
          const SizedBox(height: 12),
          _buildEditableTile(Icons.cake_rounded, "Date of Birth", dob, () => _showDatePicker()),
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

  // Helper pickers for the creative UI
  void _showSexPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(title: const Center(child: Text("Male")), onTap: () { _updateProfile('sex', 'Male'); Navigator.pop(context); }),
          ListTile(title: const Center(child: Text("Female")), onTap: () { _updateProfile('sex', 'Female'); Navigator.pop(context); }),
        ],
      ),
    );
  }

  void _showDatePicker() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) _updateProfile('dob', "${picked.day}/${picked.month}/${picked.year}");
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
          TextButton(onPressed: () { _updateProfile(field, controller.text); Navigator.pop(context); }, child: const Text("Save")),
        ],
      ),
    );
  }
}