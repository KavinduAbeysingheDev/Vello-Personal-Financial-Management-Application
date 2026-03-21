import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/finance_service.dart';
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
  static const divider         = Color(0xFFE5E7EB);
  static const amountGreen     = Color(0xFF00674F);
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
  bool _isSaving = false;
  bool _isMultiPhotoMode = false;
  BillScanResult? _scanResult;

  @override
  void dispose() {
    _scannerService.dispose();
    super.dispose();
  }

  Future<bool> _showTipsDialog({
    required String title,
    required List<String> tips,
    required String confirmLabel,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: tips
              .map(
                (tip) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ',
                          style: TextStyle(
                              color: _C.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 15)),
                      Expanded(
                        child: Text(
                          tip,
                          style: const TextStyle(
                              fontSize: 13,
                              color: _C.cardForeground,
                              height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: _C.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(confirmLabel,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
    return confirmed == true;
  }

  Future<void> _takePhoto() async {
    final proceed = await _showTipsDialog(
      title: 'Tips for Best Results',
      tips: const [
        'Ensure good lighting — avoid shadows on the bill',
        'Hold the camera steady and close to the bill',
        'Make sure all text is clearly visible',
        'Keep the bill flat and unwrinkled',
      ],
      confirmLabel: 'OK, Take Photo',
    );
    if (!proceed) return;
    setState(() => _isLoading = true);
    try {
      final result = _isMultiPhotoMode
          ? await _scannerService.scanMultiplePhotos(
              onAddMore: (photoCount) async {
                if (!mounted) return false;
                return showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    title: const Text('Photo Added!',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    content: Text('$photoCount photo(s) captured. Add another?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Done'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _C.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Add Photo'),
                      ),
                    ],
                  ),
                );
              },
            )
          : await _scannerService.scanAndGetAmount();
      if (!mounted) return;
      if (result != null) {
        setState(() => _scanResult = result);
      } else {
        _showSnack('Could not read bill. Try again.', isError: true);
      }
    } catch (e) {
      if (!mounted) return;
      _showSnack('Error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _uploadPhoto() async {
    final proceed = await _showTipsDialog(
      title: 'Tips for Best Upload',
      tips: const [
        'Use a clear, well-lit photo of the bill',
        'Make sure all text is readable',
        'Avoid blurry or dark images',
        'The bill should fill most of the image',
      ],
      confirmLabel: 'OK, Upload',
    );
    if (!proceed) return;
    setState(() => _isLoading = true);
    try {
      final result = await _scannerService.scanFromGallery();
      if (!mounted) return;
      if (result != null) {
        setState(() => _scanResult = result);
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

  Future<void> _saveTransaction() async {
    final result = _scanResult;
    if (result == null) return;

    setState(() => _isSaving = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? 'test_user';

      await FinanceService().addTransaction(
        userId: uid,
        title: 'Bill Scanner',
        amount: result.total,
        category: 'Shopping',
        type: 'expense',
        date: DateTime.now(),
      );

      if (!mounted) return;
      setState(() => _scanResult = null);
      _showSnack('Transaction saved successfully!');
    } catch (e) {
      if (!mounted) return;
      _showSnack('Failed to save: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
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
      body: _buildBody(),
    );
  }

  Widget _buildBody() => SafeArea(
        child: SingleChildScrollView(
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
              if (_scanResult != null) ...[
                const SizedBox(height: 20),
                _buildResultsCard(_scanResult!),
              ],
            ],
          ),
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
          _showSnack(_isMultiPhotoMode
              ? 'Multi-photo mode enabled!'
              : 'Multi-photo mode disabled.');
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
                            : 'Tap here to enable multi-photo mode for long bills!',
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

  Widget _buildResultsCard(BillScanResult result) => Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: _C.card,
          borderRadius: _R.lg,
          border: Border.all(color: _C.border, width: 1),
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
              child: Row(
                children: [
                  const Icon(Icons.receipt_rounded, color: _C.primary, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Scanned Total',
                    style: TextStyle(
                      color: _C.cardForeground,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: _C.divider),

            // Total amount
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 28),
              child: Column(
                children: [
                  Text(
                    'Rs. ${result.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: _C.amountGreen,
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Total payable amount',
                    style: TextStyle(
                      color: _C.mutedForeground,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: _C.divider),

            // Action buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _isSaving ? null : _saveTransaction,
                        icon: _isSaving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : const Icon(Icons.add_circle_outline_rounded, size: 18),
                        label: Text(
                          _isSaving ? 'Saving...' : 'Add Transaction',
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600),
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
                  SizedBox(
                    height: 50,
                    child: OutlinedButton(
                      onPressed: _isSaving
                          ? null
                          : () => setState(() => _scanResult = null),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _C.mutedForeground,
                        side: BorderSide(
                            color: _C.border.withValues(alpha: 0.6), width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: _R.md),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}
