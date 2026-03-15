import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

class BillScannerService {
  final ImagePicker _picker = ImagePicker();
  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  static const String _groqApiKey = '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';

  Future<String?> scanAndGetAmount() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 100,
    );
    if (image == null) return null;
    return await _processImage(image.path, source: 'Camera');
  }

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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Photo Added!', style: TextStyle(fontWeight: FontWeight.w700)),
          content: Text('${imagePaths.length} photo(s) captured. Add another?'),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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

  Future<String?> scanFromGallery() async {
    final status = await Permission.photos.request();
    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return null;
    }
    if (status.isDenied) return null;

    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
    );
    if (image == null) return null;
    return await _processImage(image.path, source: 'Gallery');
  }

  Future<String?> _processMultipleImages(List<String> imagePaths) async {
    String mergedText = '';
    for (int i = 0; i < imagePaths.length; i++) {
      final inputImage = InputImage.fromFilePath(imagePaths[i]);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      String pageText = '';
      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          pageText += '${line.text}\n';
        }
      }
      mergedText += pageText;
    }
    if (mergedText.trim().isEmpty) return "Could not read bill";
    return await _extractAmountWithDeepseek(mergedText);
  }

  Future<String?> _processImage(String imagePath, {String source = ''}) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

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
    return await _extractAmountWithDeepseek(rawText);
  }

  Future<String?> _extractAmountWithDeepseek(String ocrText) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_groqApiKey',
        },
        body: jsonEncode({
          'model': 'llama-3.3-70b-versatile',
          'messages': [
            {
              'role': 'user',
              'content': '''
You are a Sri Lankan bill/receipt parser. Extract the final net payable amount.

IMPORTANT: OCR text may have garbled Sinhala labels. Numbers will still be present.

=== KEYWORDS TO LOOK FOR ===
English: NET AMOUNT, NET TOTAL, TOTAL, GRAND TOTAL, AMOUNT DUE, PAYABLE
Sinhala: මුළු මුදල, මුලු, එකතුව, ගෙවිය යුතු, සම්පූර්ණ මුදල

=== POSITION PATTERN (if keywords missing) ===
Sri Lankan receipts:
  [item prices...]
  TOTAL AMOUNT   <- amount customer pays
  CASH GIVEN     <- round number (500, 1000, 2000, 5000)
  BALANCE/CHANGE <- difference

=== RULES ===
- Return ONLY the numeric value. Example: 593.36
- Do NOT return cash given or balance/change
- Remove commas (1,000.00 -> 1000.00)
- If cannot determine: return NOT_FOUND

=== OCR TEXT ===
$ocrText

Respond with ONLY the number or NOT_FOUND.
'''
            }
          ],
          'max_tokens': 50,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String? result = data['choices'][0]['message']['content']?.trim();
        debugPrint("Groq Response: $result");

        if (result == null || result == 'NOT_FOUND') return "Amount not found";
        result = result.replaceAll(',', '').replaceAll(' ', '');
        double? amount = double.tryParse(result);
        if (amount == null || amount <= 0) return "Amount not found";
        return amount.toStringAsFixed(2);
      } else {
        debugPrint("Groq Error: ${response.body}");
        return _ocrFallback(ocrText);
      }
    } catch (e) {
      debugPrint("Groq Error: $e");
      return _ocrFallback(ocrText);
    }
  }

  String _ocrFallback(String text) {
    RegExp amountRegExp = RegExp(r'\d{1,3}(?:,\s*\d{3})*(?:\.\s*\d{1,2})?');
    List<String> lines = text.split('\n');
    List<String> keywords = [
      'net amount', 'net total', 'grand total', 'total', 'payable',
      'card -', 'card-', 'cash -', 'cash-',
      'මුළු', 'මුලු', 'එකතුව', 'ගෙවිය යුතු', 'සේවිය යුතු'
    ];

    for (int i = 0; i < lines.length; i++) {
      String lower = lines[i].toLowerCase();
      if (keywords.any((kw) => lower.contains(kw))) {
        for (var m in amountRegExp.allMatches(lines[i])) {
          double? val = double.tryParse(m.group(0)!.replaceAll(' ', '').replaceAll(',', ''));
          if (val != null && val > 10) return val.toStringAsFixed(2);
        }
        for (int j = i + 1; j < lines.length && j <= i + 3; j++) {
          for (var m in amountRegExp.allMatches(lines[j])) {
            double? val = double.tryParse(m.group(0)!.replaceAll(' ', '').replaceAll(',', ''));
            if (val != null && val > 10) return val.toStringAsFixed(2);
          }
        }
      }
    }

    List<double> allAmounts = [];
    for (String line in lines) {
      for (var m in amountRegExp.allMatches(line)) {
        double? val = double.tryParse(m.group(0)!.replaceAll(' ', '').replaceAll(',', ''));
        if (val != null && val > 10) allAmounts.add(val);
      }
    }

    List<double> roundNumbers = allAmounts.where((v) => v % 100 == 0 && v >= 100).toList();
    if (roundNumbers.isNotEmpty && allAmounts.length >= 2) {
      double cashGiven = roundNumbers.reduce((a, b) => a > b ? a : b);
      int idx = allAmounts.lastIndexOf(cashGiven);
      if (idx > 0) return allAmounts[idx - 1].toStringAsFixed(2);
    }

    double largest = allAmounts.isNotEmpty ? allAmounts.reduce((a, b) => a > b ? a : b) : 0;
    return largest > 0 ? largest.toStringAsFixed(2) : "Amount not found";
  }

  void dispose() {
    _textRecognizer.close();
  }
}