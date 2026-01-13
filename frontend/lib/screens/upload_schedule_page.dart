// ignore_for_file: use_build_context_synchronously, avoid_print, deprecated_member_use
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import '../globals.dart' as globals;

class UploadSchedulePage extends StatefulWidget {
  const UploadSchedulePage({super.key});

  @override
  State<UploadSchedulePage> createState() => _UploadSchedulePageState();
}

class _UploadSchedulePageState extends State<UploadSchedulePage> {
  List<dynamic> groups = [];
  Uint8List? _webImage;
  XFile? _selectedImage;
  int? _selectedGroupId;
  bool _isLoading = true;
  bool _isUploading = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    fetchGroups();
  }

  Map<String, String> get _headers => {
        'Authorization': 'Bearer ${globals.userToken}',
        'Accept': 'application/json',
      };

  Future<void> fetchGroups() async {
    try {
      final response = await http.get(
        Uri.parse('http://${globals.serverIP}:8000/api/admin/groups'),
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
        final bytes = await image.readAsBytes();
        setState(() {
          _webImage = bytes;
          _selectedImage = image;
        });
      } else {
        setState(() => _selectedImage = image);
      }
    }
  }

  Future<void> _upload() async {
    if (_selectedImage == null || _selectedGroupId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a group and an image")),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://${globals.serverIP}:8000/api/admin/upload-schedule'),
      );

      request.headers.addAll(_headers);
      request.fields['group_id'] = _selectedGroupId.toString();

      final bytes = await _selectedImage!.readAsBytes();
      final multipartFile = http.MultipartFile.fromBytes(
        'image',
        bytes,
        filename: _selectedImage!.name,
      );

      request.files.add(multipartFile);

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Schedule uploaded successfully!"), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Upload failed."), backgroundColor: Colors.redAccent),
        );
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: Text(
          "Upload Schedule",
          style: GoogleFonts.poppins(color: const Color(0xFF311B92), fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF311B92), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF673AB7)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Target Group", 
                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black54)),
                  const SizedBox(height: 10),
                  // Styled Group Selector
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButtonFormField<int>(
                        decoration: const InputDecoration(border: InputBorder.none),
                        hint: Text("Select Group", style: GoogleFonts.poppins(fontSize: 14)),
                        value: _selectedGroupId,
                        items: groups.map((g) {
                          return DropdownMenuItem<int>(
                            value: g['id'],
                            child: Text(g['name'], style: GoogleFonts.poppins(fontSize: 14)),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedGroupId = val),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text("Schedule Image", 
                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black54)),
                  const SizedBox(height: 10),
                  // Upload Area
                  GestureDetector(
                    onTap: _pickImage,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 300,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        // Purple border if image is selected, otherwise light grey
                        border: Border.all(
                          color: _selectedImage != null ? const Color(0xFF673AB7) : Colors.grey.shade300,
                          width: _selectedImage != null ? 3 : 1,
                        ),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: _selectedImage == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.add_photo_alternate_rounded, size: 60, color: Color(0xFF673AB7)),
                                const SizedBox(height: 10),
                                Text("Tap to select image", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13)),
                              ],
                            )
                          : Padding(
                              padding: const EdgeInsets.all(5),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: kIsWeb
                                    ? Image.memory(_webImage!, fit: BoxFit.contain)
                                    : Image.file(File(_selectedImage!.path), fit: BoxFit.contain),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  _isUploading
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF673AB7)))
                      : ElevatedButton(
                          onPressed: _upload,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF673AB7),
                            minimumSize: const Size(double.infinity, 55),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            elevation: 0,
                          ),
                          child: Text(
                            "Confirm & Upload",
                            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                ],
              ),
            ),
    );
  }
}