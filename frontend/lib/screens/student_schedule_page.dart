// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class StudentSchedulePage extends StatelessWidget {
  final String? schedulePath;

  const StudentSchedulePage({super.key, this.schedulePath});

  Future<void> _downloadSchedule(BuildContext context) async {
    if (schedulePath == null) return;
    
    final String url = 'http://127.0.0.1:8000/storage/$schedulePath';
    final Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not launch download link")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Group Schedule", style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          if (schedulePath != null && schedulePath!.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.download_rounded, color: Color(0xFF673AB7)),
              onPressed: () => _downloadSchedule(context),
              tooltip: "Download Schedule",
            ),
        ],
      ),
      body: Center(
        child: schedulePath == null || schedulePath!.isEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today_outlined, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text("No schedule uploaded yet for your group.", 
                    style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              )
            : Column(
                children: [
                  Expanded(
                    child: InteractiveViewer(
                      panEnabled: true,
                      minScale: 0.5,
                      maxScale: 4.0,
                      child: Image.network(
                        'http://127.0.0.1:8000/storage/$schedulePath',
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(child: CircularProgressIndicator());
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ElevatedButton.icon(
                      onPressed: () => _downloadSchedule(context),
                      icon: const Icon(Icons.file_download),
                      label: const Text("Download to Device"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF673AB7),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}