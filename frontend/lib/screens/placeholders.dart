import 'package:flutter/material.dart';
import '../widgets/vello_top_bar.dart';
import '../widgets/vello_drawer.dart';

class ScanPlaceholderScreen extends StatelessWidget {
  const ScanPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const VelloTopBar(),
      endDrawer: const VelloDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Smart Bill Scanner",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              "Scan bills with your camera and automatically add items",
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Capture Bill",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _button(
                          Icons.camera_alt_outlined,
                          "Take Photo",
                          const Color(0xFF006D5B),
                          Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _button(
                          Icons.upload_outlined,
                          "Upload",
                          const Color(0xFFEAF9F3),
                          const Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _button(IconData icon, String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: bg == const Color(0xFFEAF9F3)
            ? Border.all(color: const Color(0xFFD1FAE5))
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: fg, size: 18),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(color: fg, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class AddPlaceholderScreen extends StatelessWidget {
  const AddPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const VelloTopBar(),
      endDrawer: const VelloDrawer(),
      body: const Center(
        child: Text(
          "Add Transaction Page\n(Connect your real form here)",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

class AIPlaceholderScreen extends StatelessWidget {
  const AIPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const VelloTopBar(),
      endDrawer: const VelloDrawer(),
      body: const Center(
        child: Text(
          "AI Assistant",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
