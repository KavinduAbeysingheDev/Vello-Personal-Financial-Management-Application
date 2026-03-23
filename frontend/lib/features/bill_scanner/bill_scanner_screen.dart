import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/app_provider.dart';
import '../../models/app_models.dart';
import 'bill_scanner_service.dart';
import '../../widgets/vello_top_bar.dart';
import '../../widgets/vello_drawer.dart';
import 'package:uuid/uuid.dart';
import '../../screens/setting_screen_backend.dart';

class _ThemeColors {
  final bool isDark;
  _ThemeColors(this.isDark);

  Color get primary => const Color(0xFF00674F);
  Color get background => isDark ? const Color(0xFF111827) : const Color(0xFFF0FDF4);
  Color get mutedForeground => isDark ? Colors.white70 : const Color(0xFF6B7280);
  Color get card => isDark ? const Color(0xFF1F2937) : const Color(0xFFFFFFFF);
  Color get cardForeground => isDark ? Colors.white : const Color(0xFF111111);
  Color get border => isDark ? const Color(0xFF374151) : const Color(0x1A00674F);
  Color get foreground => isDark ? Colors.white : const Color(0xFF111111);
  Color get destructive => const Color(0xFFDC2626);
  Color get infoBg => isDark ? const Color(0xFF1E3A8A).withOpacity(0.2) : const Color(0xFFEEF2FF);
  Color get infoDot => const Color(0xFF3B5BDB);
  Color get infoText => isDark ? Colors.white : const Color(0xFF3B5BDB);
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
  String? _scannedAmount;

  @override
  void dispose() {
    _scannerService.dispose();
    super.dispose();
  }


  Future<bool?> _showInstructionsDialog({
    required String title,
    required List<String> instructions,
    required String buttonText,
    required SettingsProvider settings,
  }) {
    final isDark = settings.isDarkMode;
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              settings.t(title),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 20),
            ...instructions.map((text) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: Icon(Icons.circle, size: 6, color: Color(0xFF00674F)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          settings.t(text),
                          style: TextStyle(
                            fontSize: 15,
                            color: isDark ? Colors.white70 : const Color(0xFF4B5563),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00674F),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  settings.t(buttonText),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnack(String msg, {bool isError = false, required SettingsProvider settings}) {
    final isDark = settings.isDarkMode;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? const Color(0xFFDC2626) : const Color(0xFF00674F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        final c = _ThemeColors(settings.isDarkMode);
        return Scaffold(
          backgroundColor: c.background,
          body: SafeArea(child: _buildBody(settings, c)),
        );
      },
    );
  }

  Widget _buildBody(SettingsProvider settings, _ThemeColors c) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              settings.t('Smart Bill Scanner'),
              style: TextStyle(
                color: c.foreground,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              settings.t('Scan bills with your camera and automatically add items'),
              style: TextStyle(
                color: c.mutedForeground,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            _buildCaptureCard(settings, c),
            const SizedBox(height: 14),
            _buildInfoCard(settings, c),
            if (_scannedAmount != null) ...[
              const SizedBox(height: 20),
              _buildScannedTotalCard(settings, c),
            ],
          ],
        ),
      );

  Widget _buildScannedTotalCard(SettingsProvider settings, _ThemeColors c) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: _R.lg,
        border: Border.all(color: c.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_long_outlined, color: c.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                settings.t('Scanned Total'),
                style: TextStyle(
                  color: c.cardForeground,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          Center(
            child: Column(
              children: [
                Text(
                  '${settings.t('Rs.')} $_scannedAmount',
                  style: TextStyle(
                    color: c.primary,
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  settings.t('Total payable amount'),
                  style: TextStyle(
                    color: c.mutedForeground,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : () => _saveScannedTransaction(settings),
                    icon: const Icon(Icons.add_circle_outline, size: 18),
                    label: Text(
                      settings.t('Add Transaction'),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: c.primary,
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
                  child: OutlinedButton(
                    onPressed: () => setState(() => _scannedAmount = null),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: c.mutedForeground,
                      side: BorderSide(color: settings.isDarkMode ? Colors.white24 : Colors.grey.shade300),
                      shape: RoundedRectangleBorder(borderRadius: _R.md),
                    ),
                    child: Text(settings.t('Cancel')),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _saveScannedTransaction(SettingsProvider settings) async {
    if (_scannedAmount == null) return;
    final amount = double.tryParse(_scannedAmount!) ?? 0;
    if (amount <= 0) {
      _showSnack(settings.t('Invalid scanned amount found.'), isError: true, settings: settings);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final provider = Provider.of<AppProvider>(context, listen: false);
      
      final newTx = AppTransaction(
        id: const Uuid().v4(),
        title: '${settings.t('Bill Scan')}: ${DateTime.now().day}/${DateTime.now().month}',
        amount: amount,
        category: 'Shopping', 
        date: DateTime.now(),
        type: TransactionType.expense,
        icon: Icons.receipt_long,
      );

      await provider.addTransaction(newTx);
      
      if (!mounted) return;
      _showSnack('${settings.t('Transaction of Rs.')} $amount ${settings.t('added successfully!')}', settings: settings);
      setState(() => _scannedAmount = null);
    } catch (e) {
      if (!mounted) return;
      _showSnack('${settings.t('Failed to save')}: $e', isError: true, settings: settings);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildCaptureCard(SettingsProvider settings, _ThemeColors c) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: _R.lg,
          border: Border.all(color: c.border, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              settings.t('Capture Bill'),
              style: TextStyle(
                color: c.cardForeground,
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
                      onPressed: _isLoading ? null : () => _takePhotoWrap(settings),
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
                            ? settings.t('Scanning...')
                            : _isMultiPhotoMode
                                ? settings.t('Multi Scan')
                                : settings.t('Take Photo'),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: c.primary,
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
                      onPressed: _isLoading ? null : () => _uploadPhotoWrap(settings),
                      icon: const Icon(Icons.upload_rounded, size: 18),
                      label: Text(
                        settings.t('Upload'),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: c.card,
                        foregroundColor: c.cardForeground,
                        side: BorderSide(
                            color: c.border.withOpacity(0.6), width: 1.5),
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

  Future<void> _takePhotoWrap(SettingsProvider settings) async {
    final confirmed = await _showInstructionsDialog(
      title: settings.t('Tips for Best Results'),
      instructions: [
        settings.t('Ensure good lighting — avoid shadows on the bill'),
        settings.t('Hold the camera steady and close to the bill'),
        settings.t('Make sure all text is clearly visible'),
        settings.t('Keep the bill flat and unwrinkled'),
      ],
      buttonText: settings.t('OK, Take Photo'),
      settings: settings,
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);
    try {
      String? amount;
      if (_isMultiPhotoMode) {
        amount = await _scannerService.scanMultiplePhotos(context);
      } else {
        amount = await _scannerService.scanAndGetAmount();
      }
      if (!mounted) return;
      if (amount != null) {
        setState(() => _scannedAmount = amount);
      }
    } catch (e) {
      if (!mounted) return;
      _showSnack(settings.t('Error') + ': $e', isError: true, settings: settings);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _uploadPhotoWrap(SettingsProvider settings) async {
    final confirmed = await _showInstructionsDialog(
      title: settings.t('Tips for Best Upload'),
      instructions: [
        settings.t('Use a clear, well-lit photo of the bill'),
        settings.t('Make sure all text is readable'),
        settings.t('Avoid blurry or dark images'),
        settings.t('The bill should fill most of the image'),
      ],
      buttonText: settings.t('OK, Upload'),
      settings: settings,
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);
    try {
      final amount = await _scannerService.scanFromGallery();
      if (!mounted) return;
      if (amount != null) {
        setState(() => _scannedAmount = amount);
      } else {
        _showSnack(settings.t('Gallery access denied or no image selected.'), isError: true, settings: settings);
      }
    } catch (e) {
      if (!mounted) return;
      _showSnack(settings.t('Error') + ': $e', isError: true, settings: settings);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }


  Widget _buildInfoCard(SettingsProvider settings, _ThemeColors c) => GestureDetector(
        onTap: () {
          setState(() => _isMultiPhotoMode = !_isMultiPhotoMode);
          _showSnack(
            _isMultiPhotoMode
                ? settings.t('Multi-photo mode enabled!')
                : settings.t('Multi-photo mode disabled.'),
            settings: settings,
          );
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: _isMultiPhotoMode
                ? c.infoDot.withOpacity(0.12)
                : c.infoBg,
            borderRadius: _R.lg,
            border: Border.all(
                color: c.infoDot.withOpacity(0.18), width: 1),
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
                        ? c.infoDot
                        : c.infoDot.withOpacity(0.4),
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
                        text: '${settings.t('Multi-photo support')}: ',
                        style: TextStyle(
                          color: _isMultiPhotoMode ? c.infoDot : c.infoText,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          height: 1.5,
                        ),
                      ),
                      TextSpan(
                        text: _isMultiPhotoMode
                            ? settings.t('Enabled! Tap camera to scan multiple photos.')
                            : settings.t("Tap here to enable multi-photo mode for long bills!"),
                        style: TextStyle(
                          color: _isMultiPhotoMode ? c.infoDot : c.infoText,
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
                    ? c.infoDot
                    : c.infoDot.withOpacity(0.4),
                size: 20,
              ),
            ],
          ),
        ),
      );
}