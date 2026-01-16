// ignore_for_file: unused_import, use_build_context_synchronously, deprecated_member_use
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:frontend/globals.dart' as globals;

class StudentCardTab extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const StudentCardTab({super.key, this.userData});

  @override
  State<StudentCardTab> createState() => _StudentCardTabState();
}

class _StudentCardTabState extends State<StudentCardTab> {
  double _rotationX = 0;
  double _rotationY = 0;
  bool _isFlipped = false; // Track flip state

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () => setState(() => _isFlipped = !_isFlipped),
        child: MouseRegion(
          onHover: (event) {
            setState(() {
              // Subtle 3D tilt effect on hover
              _rotationY = (event.localPosition.dx / 300) - 0.5;
              _rotationX = (event.localPosition.dy / 500) - 0.5;
            });
          },
          onExit: (_) => setState(() {
            _rotationX = 0;
            _rotationY = 0;
          }),
          child: TweenAnimationBuilder(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOutBack,
            tween: Tween<double>(begin: 0, end: _isFlipped ? math.pi : 0),
            builder: (context, double value, child) {
              return Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001) // Perspective
                  ..rotateX(_rotationX)
                  ..rotateY(_rotationY + value),
                alignment: Alignment.center,
                child: value < math.pi / 2
                    ? _buildPhysicalCard(isFront: true)
                    : Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()..rotateY(math.pi),
                        child: _buildPhysicalCard(isFront: false),
                      ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPhysicalCard({required bool isFront}) {
    return Container(
      width: 320, // Slightly narrowed to ensure no side clipping
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
            // Texture Layer
            Positioned.fill(
              child: Opacity(
                opacity: 0.1,
                child: CustomPaint(painter: CardTexturePainter()),
              ),
            ),
            // Header (Always visible on both sides)
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("STUDENT ID",
                          style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2)),
                      Image.asset('assets/campus_connect_logo3.png',
                          height: 30),
                    ],
                  ),
                  Expanded(
                    child: isFront ? _buildFrontContent() : _buildBackContent(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrontContent() {
    final name = widget.userData?['name'] ?? "Loading...";
    final email = widget.userData?['email'] ?? "Email not found";
    final group = widget.userData?['group_name'] ?? "No Group";
    final sex = widget.userData?['sex'] ?? "Not specified";
    final dob = widget.userData?['dob'] ?? "--/--/----";
    final pob = widget.userData?['pob'] ?? "/";
    final profilePic = widget.userData?['profile_picture'];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(4),
          decoration:
              const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: CircleAvatar(
            radius: 55, // Reduced slightly to save space
            backgroundImage: profilePic != null
                ? NetworkImage(
                    'http://${globals.serverIP}:8000/storage/$profilePic')
                : const AssetImage('assets/user.png') as ImageProvider,
          ),
        ),
        const SizedBox(height: 15),
        Text(name,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold)),
        Text(email,
            style: const TextStyle(color: Colors.white60, fontSize: 12)),
        const SizedBox(height: 25), // Replaced Spacer with fixed size
        _buildDetailRow("GROUP", group),
        const Divider(color: Colors.white24, height: 12),
        _buildDetailRow("SEX", sex),
        const Divider(color: Colors.white24, height: 12),
        _buildDetailRow("Date of Birth", dob),
        const Divider(color: Colors.white24, height: 12),
        _buildDetailRow("Place of Birth", pob),
        const SizedBox(height: 25),
        // Barcode
        Container(
          height: 35,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.line_weight_rounded,
              color: Colors.black, size: 30),
        ),
      ],
    );
  }

  Widget _buildBackContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "SCAN FOR VERIFICATION",
          style: TextStyle(
              color: Colors.white54,
              fontSize: 10,
              letterSpacing: 1.5,
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.qr_code_2, color: Colors.black, size: 150),
        ),
        const SizedBox(height: 20),
        const Text(
          "This card is property of Campus Connect.\nIf found, please return to administration.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Color.fromARGB(150, 255, 255, 255), fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.white38,
                fontSize: 10,
                fontWeight: FontWeight.bold)),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class CardTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (var i = -50; i < size.width; i += 20) {
      canvas.drawLine(
          Offset(i.toDouble(), 0), Offset(i.toDouble() + 100, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}