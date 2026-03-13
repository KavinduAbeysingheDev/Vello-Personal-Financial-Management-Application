import 'package:flutter/material.dart';
import 'bill_scanner_service.dart';

class _C {
  static const primary         = Color(0xFF00674F);
  static const background      = Color(0xFFF0FDF4);
  static const mutedForeground = Color(0xFF6B7280);
  static const card            = Color(0xFFFFFFFF);
  static const cardForeground  = Color(0xFF111111);
  static const border          = Color(0x1A00674F);
  static const foreground      = Color(0xFF111111);
  static const destructive     = Color(0xFFDC2626);
  static const infoBg          = Color(0xFFEEF2FF);
  static const infoDot         = Color(0xFF3B5BDB);
  static const infoText        = Color(0xFF3B5BDB);
}

class _R {
  static const md = BorderRadius.all(Radius.circular(12));
  static const lg = BorderRadius.all(Radius.circular(16));
}

class BillScannerScreen extends StatefulWidget {
  const BillScannerScreen({super.key});

  @override
  State<BillScannerScreen> createState() => _BillScannerScreenState();
}

class _BillScannerScreenState extends State<BillScannerScreen> {
  final BillScannerService _scannerService = BillScannerService();
  bool _isLoading = false;
  bool _isMultiPhotoMode = false;

  @override
  void dispose() {
    _scannerService.dispose();
    super.dispose();
  }

  Future<void> _takePhoto() async {
    setState(() => _isLoading = true);
    try {
      String? amount;
      if (_isMultiPhotoMode) {
        amount = await _scannerService.scanMultiplePhotos(context);
      } else {
        amount = await _scannerService.scanAndGetAmount();
      }
      if (!mounted) return;
      if (amount != null) _showSnack('Scanned: Rs. $amount');
    } catch (e) {
      if (!mounted) return;
      _showSnack('Error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _uploadPhoto() async {
    setState(() => _isLoading = true);
    try {
      final amount = await _scannerService.scanFromGallery();
      if (!mounted) return;
      if (amount != null) {
        _showSnack('Scanned: Rs. $amount');
      } else {
        _showSnack('Gallery access denied or no image selected.', isError: true);
      }
    } catch (e) {
      if (!mounted) return;
      _showSnack('Error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? _C.destructive : _C.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: _R.md),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.background,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() => AppBar(
        backgroundColor: _C.primary,
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: 12),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.eco_rounded, color: Colors.amber, size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              'Vello',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 24),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded, color: Colors.white, size: 22),
            onPressed: () {},
          ),
          const SizedBox(width: 4),
        ],
      );

  Widget _buildBody() => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Smart Bill Scanner',
              style: TextStyle(
                color: _C.foreground,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Scan bills with your camera and automatically add items',
              style: TextStyle(
                color: _C.mutedForeground,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            _buildCaptureCard(),
            const SizedBox(height: 14),
            _buildInfoCard(),
          ],
        ),
      );

  Widget _buildCaptureCard() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _C.card,
          borderRadius: _R.lg,
          border: Border.all(color: _C.border, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Capture Bill',
              style: TextStyle(
                color: _C.cardForeground,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _takePhoto,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.camera_alt_rounded, size: 18),
                      label: Text(
                        _isLoading
                            ? 'Scanning...'
                            : _isMultiPhotoMode
                                ? 'Multi Scan'
                                : 'Take Photo',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _C.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: _R.md),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: _isLoading ? null : _uploadPhoto,
                      icon: const Icon(Icons.upload_rounded, size: 18),
                      label: const Text(
                        'Upload',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: _C.card,
                        foregroundColor: _C.cardForeground,
                        side: BorderSide(
                            color: _C.border.withValues(alpha: 0.6), width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: _R.md),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  Widget _buildInfoCard() => GestureDetector(
        onTap: () {
          setState(() => _isMultiPhotoMode = !_isMultiPhotoMode);
          _showSnack(
            _isMultiPhotoMode
                ? 'Multi-photo mode enabled!'
                : 'Multi-photo mode disabled.',
          );
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: _isMultiPhotoMode
                ? _C.infoDot.withValues(alpha: 0.12)
                : _C.infoBg,
            borderRadius: _R.lg,
            border: Border.all(
                color: _C.infoDot.withValues(alpha: 0.18), width: 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: _isMultiPhotoMode
                        ? _C.infoDot
                        : _C.infoDot.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Multi-photo support: ',
                        style: TextStyle(
                          color: _isMultiPhotoMode ? _C.infoDot : _C.infoText,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          height: 1.5,
                        ),
                      ),
                      TextSpan(
                        text: _isMultiPhotoMode
                            ? 'Enabled! Tap camera to scan multiple photos.'
                            : "Tap here to enable multi-photo mode for long bills!",
                        style: TextStyle(
                          color: _isMultiPhotoMode ? _C.infoDot : _C.infoText,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Icon(
                _isMultiPhotoMode
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: _isMultiPhotoMode
                    ? _C.infoDot
                    : _C.infoDot.withValues(alpha: 0.4),
                size: 20,
              ),
            ],
          ),
        ),
      );
}