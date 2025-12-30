// ignore_for_file: unused_import, use_build_context_synchronously, deprecated_member_use, library_private_types_in_public_api, avoid_print
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import '../globals.dart' as globals;

class UploadSchedulePage extends StatefulWidget {
  // Removed 'final List<dynamic> groups' from here to stop the dashboard error
  const UploadSchedulePage({super.key});

  @override
  _UploadSchedulePageState createState() => _UploadSchedulePageState();
}

class _UploadSchedulePageState extends State<UploadSchedulePage> {
  List<dynamic> groups = []; // Page now manages its own group list
  Uint8List? _webImage;
  XFile? _selectedImage;
  int? _selectedGroupId;
  bool _isLoading = true;
  bool _isUploading = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    fetchGroups(); // Fetch groups as soon as the page opens
  }

  Map<String, String> get _headers => {
    'Authorization': 'Bearer ${globals.userToken}',
    'Accept': 'application/json',
  };

  Future<void> fetchGroups() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/admin/groups'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        setState(() {
          groups = jsonDecode(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching groups: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      if (kIsWeb) {
        // For Chrome/Web: Read bytes to show the preview
        final bytes = await image.readAsBytes();
        setState(() {
          _webImage = bytes;
          _selectedImage = image;
        });
      } else {
        // For Mobile
        setState(() => _selectedImage = image);
      }
    }
  }

  Future<void> _upload() async {
  print("Starting upload process...");
  if (_selectedImage == null || _selectedGroupId == null) {
    print("Error: Image or Group ID is null");
    return;
  }

  setState(() => _isUploading = true);

  try {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://127.0.0.1:8000/api/admin/upload-schedule'),
    );

    request.headers.addAll({
      'Authorization': 'Bearer ${globals.userToken}',
      'Accept': 'application/json',
    });

    request.fields['group_id'] = _selectedGroupId.toString();

    // WEB FIX: Use fromBytes for Chrome instead of fromPath
    final bytes = await _selectedImage!.readAsBytes();
    final multipartFile = http.MultipartFile.fromBytes(
      'image', 
      bytes,
      filename: _selectedImage!.name,
    );
    
    request.files.add(multipartFile);

    print("Sending request to server...");
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    print("Server Response: ${response.body}");

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Uploaded!")));
      Navigator.pop(context);
    } else {
      print("Upload failed with status: ${response.statusCode}");
    }
  } catch (e) {
    print("CRITICAL ERROR during upload: $e");
  } finally {
    setState(() => _isUploading = false);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Schedule")),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: "Select Group"),
                  items: groups.map((g) {
                    return DropdownMenuItem<int>(
                      value: g['id'], 
                      child: Text(g['name']),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedGroupId = val),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 250,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.grey.shade50,
                    ),
                    child: _selectedImage == null
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.cloud_upload_outlined, size: 50, color: Colors.grey),
                              Text("Tap to select schedule image", style: TextStyle(color: Colors.grey)),
                            ],
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: kIsWeb 
                              ? Image.memory(_webImage!, fit: BoxFit.contain) // Web uses bytes
                              : Image.file(File(_selectedImage!.path), fit: BoxFit.contain), // Mobile uses path
                          ),
                  ),
                ),
                const SizedBox(height: 30),
                _isUploading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () {
                          print("Upload button clicked!");
                          _upload();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF673AB7),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("Upload Schedule", style: TextStyle(color: Colors.white)),
                      ),
              ],
            ),
          ),
    );
  }
}