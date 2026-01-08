// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../globals.dart' as globals;

class CourseDetailsPage extends StatefulWidget {
  final String courseName;
  final bool isTeacher;

  const CourseDetailsPage({super.key, required this.courseName, required this.isTeacher});

  @override
  _CourseDetailsPageState createState() => _CourseDetailsPageState();
}

class _CourseDetailsPageState extends State<CourseDetailsPage> {
  List<dynamic> files = [];

  @override
  void initState() {
    super.initState();
    fetchFiles();
  }

  Future<void> fetchFiles() async {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/api/course/files/${widget.courseName}'),
      headers: {'Authorization': 'Bearer ${globals.userToken}'},
    );
    if (response.statusCode == 200) {
      setState(() => files = jsonDecode(response.body));
    }
  }

  Future<void> deleteFile(int fileId) async {
  final url = Uri.parse('http://127.0.0.1:8000/api/teacher/delete-file/$fileId');

  try {
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer ${globals.userToken}',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      // Refresh the UI list
      fetchFiles(); 
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("File deleted successfully")),
      );
    } else {
      print("Delete failed: ${response.body}");
    }
  } catch (e) {
    print("Error during delete: $e");
  }
}

  Future<void> pickAndUpload() async {
  try {
    // 1. Picking the file - specific for Web bytes
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png', 'jpeg'],
      withData: true, // Required for Web
    ).timeout(const Duration(seconds: 10)); // Prevent infinite hang

    if (result != null && result.files.first.bytes != null) {
      final file = result.files.first;

      // 2. Prepare the Multipart Request
      var request = http.MultipartRequest(
        'POST', 
        Uri.parse('http://127.0.0.1:8000/api/teacher/upload-file')
      );
      
      request.headers['Authorization'] = 'Bearer ${globals.userToken}';
      request.headers['Accept'] = 'application/json';
      request.fields['course_name'] = widget.courseName;

      // 3. Add bytes directly
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        file.bytes!,
        filename: file.name,
      ));

      var response = await request.send();
      
      if (response.statusCode == 200) {
        fetchFiles(); // Refresh list
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Upload Successful!")),
        );
      } else {
        print("Upload failed: ${response.statusCode}");
      }
    }
  } catch (e) {
    print("Error: $e");
    // If the '_instance' error persists, it's a compilation/caching issue
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Browser error: Please try a Hard Refresh (Ctrl+F5)")),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.courseName), backgroundColor: const Color(0xFF673AB7)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.isTeacher) 
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton.icon(
                onPressed: pickAndUpload,
                icon: const Icon(Icons.upload_file),
                label: const Text("Upload files to the course"),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF673AB7), foregroundColor: Colors.white),
              ),
            ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text("Course Materials", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: files.length,
              itemBuilder: (context, index) {
                final file = files[index];
                return _buildFileContainer(file);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileContainer(dynamic file) {
  String baseUrl = "http://127.0.0.1:8000/storage/";
  
  if (file['file_type'] == 'image') {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.all(15),
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            image: DecorationImage(
              image: NetworkImage(baseUrl + file['file_path']), 
              fit: BoxFit.cover
            ),
          ),
        ),
        // Delete button for Teacher only
        if (widget.isTeacher)
          Positioned(
            top: 20,
            right: 20,
            child: CircleAvatar(
              backgroundColor: Colors.red.withOpacity(0.8),
              child: IconButton(
                icon: const Icon(Icons.delete, color: Colors.white),
                onPressed: () => deleteFile(file['id']),
              ),
            ),
          ),
      ],
    );
  } else {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(10), 
        border: Border.all(color: Colors.grey.shade200)
      ),
      child: Row(
        children: [
          const Icon(Icons.picture_as_pdf, color: Colors.red),
          const SizedBox(width: 10),
          Expanded(child: Text(file['file_name'], overflow: TextOverflow.ellipsis)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.download, color: Colors.blue)),
          // Delete button for Teacher only
          if (widget.isTeacher)
            IconButton(
              onPressed: () => deleteFile(file['id']), 
              icon: const Icon(Icons.delete_outline, color: Colors.red)
            ),
        ],
      ),
    );
  }
}
}