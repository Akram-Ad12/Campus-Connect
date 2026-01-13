// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, deprecated_member_use
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../globals.dart' as globals;
import 'package:url_launcher/url_launcher.dart';

class CourseDetailsPage extends StatefulWidget {
  final String courseName;
  final bool isTeacher;

  const CourseDetailsPage({super.key, required this.courseName, required this.isTeacher});

  @override
  _CourseDetailsPageState createState() => _CourseDetailsPageState();
}

class _CourseDetailsPageState extends State<CourseDetailsPage> {
  List<dynamic> files = [];
  bool isPageLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFiles();
  }

  Future<void> fetchFiles() async {
    try {
      final response = await http.get(
        Uri.parse('http://${globals.serverIP}:8000/api/course/files/${widget.courseName}'),
        headers: {'Authorization': 'Bearer ${globals.userToken}'},
      );
      if (response.statusCode == 200) {
        setState(() {
          files = jsonDecode(response.body);
          isPageLoading = false;
        });
      }
    } catch (e) {
      setState(() => isPageLoading = false);
    }
  }

  Future<void> deleteFile(int fileId) async {
    final url = Uri.parse('http://${globals.serverIP}:8000/api/teacher/delete-file/$fileId');
    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer ${globals.userToken}',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        fetchFiles();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Material removed"), behavior: SnackBarBehavior.floating),
        );
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> pickAndUpload() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'png', 'jpeg'],
        withData: true,
      ).timeout(const Duration(seconds: 15));

      if (result != null && result.files.first.bytes != null) {
        final file = result.files.first;

        var request = http.MultipartRequest(
            'POST', Uri.parse('http://${globals.serverIP}:8000/api/teacher/upload-file'));

        request.headers['Authorization'] = 'Bearer ${globals.userToken}';
        request.headers['Accept'] = 'application/json';
        request.fields['course_name'] = widget.courseName;

        request.files.add(http.MultipartFile.fromBytes(
          'file',
          file.bytes!,
          filename: file.name,
        ));

        var response = await request.send();

        if (response.statusCode == 200) {
          fetchFiles();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Upload Successful!"), backgroundColor: Colors.green),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Upload failed")));
    }
  }

  Future<void> _downloadFile(String filePath) async {
    final String fullUrl = "http://${globals.serverIP}:8000/storage/$filePath";
    final Uri uri = Uri.parse(fullUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: Text(widget.courseName, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF1A1A1A),
        centerTitle: true,
      ),
      body: isPageLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF673AB7)))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.isTeacher) _buildUploadZone(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                  child: Row(
                    children: [
                      const Icon(Icons.folder_open_rounded, color: Color(0xFF673AB7), size: 20),
                      const SizedBox(width: 8),
                      Text("Course Materials",
                          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A1A))),
                      const Spacer(),
                      Text("${files.length} items", style: GoogleFonts.poppins(fontSize: 12, color: Colors.black38)),
                    ],
                  ),
                ),
                Expanded(
                  child: files.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 30),
                          itemCount: files.length,
                          itemBuilder: (context, index) => _buildFileCard(files[index]),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildUploadZone() {
    return GestureDetector(
      onTap: pickAndUpload,
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.symmetric(vertical: 30),
        decoration: BoxDecoration(
          color: const Color(0xFF673AB7).withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF673AB7).withOpacity(0.2), width: 2, style: BorderStyle.solid),
        ),
        child: Column(
          children: [
            const Icon(Icons.cloud_upload_outlined, size: 40, color: Color(0xFF673AB7)),
            const SizedBox(height: 10),
            Text("Tap to upload documents",
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF673AB7))),
            Text("PDF, JPG, PNG up to 10MB", style: GoogleFonts.poppins(fontSize: 11, color: Colors.black38)),
          ],
        ),
      ),
    );
  }

  Widget _buildFileCard(dynamic file) {
    bool isImage = file['file_type'] == 'image';
    String baseUrl = "http://${globals.serverIP}:8000/storage/";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isImage)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              child: Image.network(
                baseUrl + file['file_path'],
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(height: 100, color: Colors.grey[200]),
              ),
            ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isImage ? Colors.blue.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isImage ? Icons.image_rounded : Icons.picture_as_pdf_rounded,
                color: isImage ? Colors.blue : Colors.red,
                size: 24,
              ),
            ),
            title: Text(
              file['file_name'],
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: const Color(0xFF2D3436)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(isImage ? "Image File" : "PDF Document", style: GoogleFonts.poppins(fontSize: 11)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => _downloadFile(file['file_path']),
                  icon: const Icon(Icons.download_rounded, color: Color(0xFF673AB7)),
                ),
                if (widget.isTeacher)
                  IconButton(
                    onPressed: () => deleteFile(file['id']),
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                  ),
              ],
            ),
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
          Icon(Icons.description_outlined, size: 60, color: Colors.black.withOpacity(0.05)),
          const SizedBox(height: 15),
          Text("No materials uploaded yet", style: GoogleFonts.poppins(color: Colors.black26, fontSize: 14)),
        ],
      ),
    );
  }
}