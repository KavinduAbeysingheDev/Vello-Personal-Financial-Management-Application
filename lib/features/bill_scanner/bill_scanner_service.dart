import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:permission_handler/permission_handler.dart';

class BillScannerService {
  final ImagePicker _picker = ImagePicker();

  final _textRecognizer =
      TextRecognizer(script: TextRecognitionScript.latin);

  static const String _geminiApiKey = 'AIzaSyBp2LlglNcqIAtE1Uk1CFw9B8KjR4S3JDM';

  // ─── Camera Scan (Single) ─────────────────────────────────────
  Future<String?> scanAndGetAmount() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 100,
    );
    if (image == null) return null;

    return await _processImage(image.path, source: 'Camera');
  }

  // ─── Camera Scan (Multi-photo) ────────────────────────────────
  Future<String?> scanMultiplePhotos(BuildContext context) async {
    List<String> imagePaths = [];

    while (true) {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 100,
      );
      if (image == null) break;

      imagePaths.add(image.path);

      if (!context.mounted) break;

      final addMore = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Photo Added!',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          content: Text(
            '${imagePaths.length} photo(s) captured. Add another?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Done'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00674F),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Add Photo'),
            ),
          ],
        ),
      );

      if (addMore != true) break;
    }

    if (imagePaths.isEmpty) return null;

    return await _processMultipleImages(imagePaths);
  }

  // ─── Gallery Upload ───────────────────────────────────────────
  Future<String?> scanFromGallery() async {
    final status = await Permission.photos.request();

    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return null;
    }

    if (status.isDenied) {
      return null;
    }

    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
    );
    if (image == null) return null;

    return await _processImage(image.path, source: 'Gallery');
  }

  // ─── Process Multiple Images ──────────────────────────────────
  Future<String?> _processMultipleImages(List<String> imagePaths) async {
    String mergedText = '';

    for (int i = 0; i < imagePaths.length; i++) {
      final inputImage = InputImage.fromFilePath(imagePaths[i]);
      final RecognizedText recognizedText =
          await _textRecognizer.processImage(inputImage);

      String pageText = '';
      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          pageText += '${line.text}\n';
        }
      }

      debugPrint("---------- OCR PAGE ${i + 1} ----------");
      debugPrint(pageText);
      debugPrint("---------------------------------------");

      mergedText += pageText;
    }

    debugPrint("---------- MERGED OCR TEXT ----------");
    debugPrint(mergedText);
    debugPrint("-------------------------------------");

    if (mergedText.trim().isEmpty) return "Could not read bill";

    return await _extractAmountWithGemini(mergedText);
  }

  // ─── Shared Image Processing ──────────────────────────────────
  Future<String?> _processImage(String imagePath, {String source = ''}) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final RecognizedText recognizedText =
        await _textRecognizer.processImage(inputImage);

    String rawText = '';
    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        rawText += '${line.text}\n';
      }
    }

    debugPrint("---------- OCR RAW OUTPUT ($source) ----------");
    debugPrint(rawText);
    debugPrint("----------------------------------------------");

    if (rawText.trim().isEmpty) return "Could not read bill";

    return await _extractAmountWithGemini(rawText);
  }

  // ─── Gemini Extraction ────────────────────────────────────────
  Future<String?> _extractAmountWithGemini(String ocrText) async {
    try {
      final model = GenerativeModel(
        model: 'gemini-2.5-flash-lite',
        apiKey: _geminiApiKey,
      );

      final prompt = '''
You are a Sri Lankan bill/receipt parser. Your job is to extract the final net payable amount.

IMPORTANT: The OCR text may have MISSING or GARBLED Sinhala labels. Numbers will still be present.

=== STEP 1: Look for these keywords (English or Sinhala) ===
English  : NET AMOUNT, NET TOTAL, TOTAL, GRAND TOTAL, AMOUNT DUE, PAYABLE
Sinhala  : මුළු මුදල, මුලු, එකතුව, ගෙවිය යුතු, ගෙවිය යුතු මුදල, සේවිය යුතු මිල, සේවිය යුතු, සම්පූර්ණ මුදල

=== STEP 2: If Sinhala labels are MISSING, use POSITION PATTERN ===
Sri Lankan receipts follow this pattern:
  [item prices...]
  TOTAL AMOUNT   <- the amount customer must pay (appears before a round number)
  CASH GIVEN     <- round number like 500.00, 1000.00, 2000.00, 5000.00
  BALANCE/CHANGE <- difference (cash given - total)

Example:
  Numbers seen: 593.36, 1000.00, 406.64
  -> 1000.00 is CASH GIVEN (round number)
  -> 406.64 is BALANCE
  -> 593.36 is the TOTAL

=== RULES ===
- Return ONLY the numeric value. Example: 593.36
- Do NOT return the cash given amount or balance/change amount
- Remove spaces inside numbers (e.g. 4,590. 00 -> 4590.00)
- Remove commas (e.g. 1,000.00 -> 1000.00)
- If you truly cannot determine the total, return: NOT_FOUND

=== OCR TEXT ===
$ocrText

Respond with ONLY the number or NOT_FOUND. Nothing else.
''';

      final response = await model.generateContent([Content.text(prompt)]);
      String? result = response.text?.trim();

      debugPrint("Gemini Response: $result");

      if (result == null || result == 'NOT_FOUND') return "Amount not found";

      result = result.replaceAll(',', '').replaceAll(' ', '');
      double? amount = double.tryParse(result);
      if (amount == null || amount <= 0) return "Amount not found";

      return amount.toStringAsFixed(2);
    } catch (e) {
      debugPrint("Gemini Error: $e");
      return _ocrFallback(ocrText);
    }
  }

  // ─── OCR Fallback ─────────────────────────────────────────────
  String _ocrFallback(String text) {
    RegExp amountRegExp = RegExp(r'\d{1,3}(?:,\s*\d{3})*(?:\.\s*\d{1,2})?');
    List<String> lines = text.split('\n');
    List<String> keywords = [
      'net amount', 'net total', 'grand total', 'total', 'payable',
      'මුළු', 'මුලු', 'එකතුව', 'ගෙවිය යුතු', 'සේවිය යුතු'
    ];

    for (int i = 0; i < lines.length; i++) {
      String lower = lines[i].toLowerCase();
      if (keywords.any((kw) => lower.contains(kw))) {
        for (var m in amountRegExp.allMatches(lines[i])) {
          double? val = double.tryParse(
              m.group(0)!.replaceAll(' ', '').replaceAll(',', ''));
          if (val != null && val > 10) return val.toStringAsFixed(2);
        }
        for (int j = i + 1; j < lines.length && j <= i + 3; j++) {
          for (var m in amountRegExp.allMatches(lines[j])) {
            double? val = double.tryParse(
                m.group(0)!.replaceAll(' ', '').replaceAll(',', ''));
            if (val != null && val > 10) return val.toStringAsFixed(2);
          }
        }
      }
    }

    List<double> allAmounts = [];
    for (String line in lines) {
      for (var m in amountRegExp.allMatches(line)) {
        double? val = double.tryParse(
            m.group(0)!.replaceAll(' ', '').replaceAll(',', ''));
        if (val != null && val > 10) allAmounts.add(val);
      }
    }

    List<double> roundNumbers =
        allAmounts.where((v) => v % 100 == 0 && v >= 100).toList();

    if (roundNumbers.isNotEmpty && allAmounts.length >= 2) {
      double cashGiven = roundNumbers.reduce((a, b) => a > b ? a : b);
      int idx = allAmounts.lastIndexOf(cashGiven);
      if (idx > 0) {
        return allAmounts[idx - 1].toStringAsFixed(2);
      }
    }

    double largest = allAmounts.isNotEmpty
        ? allAmounts.reduce((a, b) => a > b ? a : b)
        : 0;
    return largest > 0 ? largest.toStringAsFixed(2) : "Amount not found";
  }

  // ─── Dispose ──────────────────────────────────────────────────
  void dispose() {
    _textRecognizer.close();
  }
}