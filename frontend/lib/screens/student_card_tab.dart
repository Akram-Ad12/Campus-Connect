// ignore_for_file: unused_import, use_build_context_synchronously, deprecated_member_use
import 'package:flutter/material.dart';
import 'dart:math' as math;

class StudentCardTab extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const StudentCardTab({super.key, this.userData});

  @override
  State<StudentCardTab> createState() => _StudentCardTabState();
}

class _StudentCardTabState extends State<StudentCardTab> {
  double _rotationX = 0;
  double _rotationY = 0;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: MouseRegion(
        onHover: (event) {
          setState(() {
            // Creates a subtle 3D tilt effect
            _rotationY = (event.localPosition.dx / 300) - 0.5;
            _rotationX = (event.localPosition.dy / 500) - 0.5;
          });
        },
        onExit: (_) => setState(() { _rotationX = 0; _rotationY = 0; }),
        child: Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001) // Perspective
            ..rotateX(_rotationX)
            ..rotateY(_rotationY),
          alignment: FractionalOffset.center,
          child: _buildPhysicalCard(),
        ),
      ),
    );
  }

  Widget _buildPhysicalCard() {
    final name = widget.userData?['name'] ?? "Loading...";
    final email = widget.userData?['email'] ?? "Email not found";
    final group = widget.userData?['group_name'] ?? "No Group";
    final sex = widget.userData?['sex'] ?? "Not specified";
    final dob = widget.userData?['dob'] ?? "--/--/----";
    final pob = widget.userData?['pob'] ?? "/";
    final profilePic = widget.userData?['profile_picture'];
    return Container(
      width: 340,
      height: 500,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [Color(0xFF311B92), Color(0xFF673AB7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF673AB7).withOpacity(0.4),
            blurRadius: 30,
            offset: const Offset(0, 15),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack(
          children: [
            // 1. Texture Layer (Geometric pattern)
            Positioned.fill(
              child: Opacity(
                opacity: 0.1,
                child: CustomPaint(painter: CardTexturePainter()),
              ),
            ),
            
            // 2. Card Content
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                children: [
                  // Logo & Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("STUDENT ID", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, letterSpacing: 2)),
                      Image.asset('assets/campus_connect_logo.png', height: 30, color: Colors.white),
                    ],
                  ),
                  const SizedBox(height: 40),
                  
                  // Profile Image with unique Border
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: profilePic != null
                      ? NetworkImage('http://127.0.0.1:8000/storage/$profilePic')
                      : const AssetImage('user.png') as ImageProvider,
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(name, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  Text(email, style: const TextStyle(color: Colors.white60, fontSize: 13)),
                  
                  const Spacer(),
                  
                  _buildDetailRow("GROUP", group),
                  const Divider(color: Colors.white24),
                  _buildDetailRow("SEX", sex),
                  const Divider(color: Colors.white24),
                  _buildDetailRow("DOB", dob),
                  const Divider(color: Colors.white24),
                  _buildDetailRow("POB", pob),
                  
                  const SizedBox(height: 30),
                  
                  // Barcode Placeholder
                  Container(
                    height: 40,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.line_weight_rounded, color: Colors.black, size: 30),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// Custom Painter for the "Textured" background look
class CardTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 1;
    for (var i = 0; i < size.width; i += 20) {
      canvas.drawLine(Offset(i.toDouble(), 0), Offset(i.toDouble() + 50, size.height), paint);
    }
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}