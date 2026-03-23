import 'package:flutter/material.dart';
import '../widgets/vello_drawer.dart';
import '../screens/setting_screen_backend.dart';
import 'package:provider/provider.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  bool _isScanning = false;

  void _simulateScan(SettingsProvider settings) {
    setState(() => _isScanning = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isScanning = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(settings.t('Receipt successfully scanned! $34.50 added.🎯'))),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    return Scaffold(
      backgroundColor: Colors.black,
      endDrawer: const VelloDrawer(),
      body: Stack(
        children: [
          _buildCameraView(settings),
          if (_isScanning) _buildScanningOverlay(settings),
          _buildBottomControls(settings),
        ],
      ),
    );
  }

  Widget _buildCameraView(SettingsProvider settings) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: Center(
        child: Container(
          width: 300,
          height: 400,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF0DBE82).withOpacity(0.5), width: 2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               Icon(Icons.receipt_long, color: Colors.white.withOpacity(0.5), size: 100),
               const SizedBox(height: 16),
               Text(
                 settings.t("Align receipt within the frame"),
                 style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16),
               ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScanningOverlay(SettingsProvider settings) {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Color(0xFF0DBE82)),
            const SizedBox(height: 20),
            Text(
              settings.t("Analyzing Receipt..."),
              style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls(SettingsProvider settings) {
    final isDark = settings.isDarkMode;
    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2937) : Colors.white,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: Icon(Icons.flash_on, size: 28, color: isDark ? Colors.white70 : Colors.black54),
              onPressed: () {},
            ),
            GestureDetector(
              onTap: () => _simulateScan(settings),
              child: Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF0DBE82), width: 4),
                ),
                child: Center(
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      color: Color(0xFF0DBE82),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.photo_library, size: 28, color: isDark ? Colors.white70 : Colors.black54),
              onPressed: () => _simulateScan(settings),
            ),
          ],
        ),
      ),
    );
  }
}
