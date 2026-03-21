import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'bill_parser.dart';

// Re-export model types so callers only need this one import.
export 'bill_parser.dart' show BillItem, BillScanResult;

class BillScannerService {
  final ImagePicker _picker = ImagePicker();
  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  final BillParser _parser = BillParser();
  final http.Client _httpClient;

  static String get _groqApiKey => dotenv.env['GROQ_API_KEY'] ?? '';

  BillScannerService({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  // ─── Camera Scan (Single) ──────────────────────────────────────
  Future<BillScanResult?> scanAndGetAmount() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 100,
    );
    if (image == null) return null;
    return _processImage(image.path, source: 'Camera');
  }

  // ─── Camera Scan (Multi-photo) ─────────────────────────────────
  Future<BillScanResult?> scanMultiplePhotos({
    required Future<bool?> Function(int photoCount) onAddMore,
  }) async {
    final List<String> imagePaths = [];

    while (true) {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 100,
      );
      if (image == null) break;

      imagePaths.add(image.path);

      final addMore = await onAddMore(imagePaths.length);
      if (addMore != true) break;
    }

    if (imagePaths.isEmpty) return null;
    return _processMultipleImages(imagePaths);
  }

  // ─── Gallery Upload ────────────────────────────────────────────
  Future<BillScanResult?> scanFromGallery() async {
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
    return _processImage(image.path, source: 'Gallery');
  }

  // ─── Process Multiple Images ───────────────────────────────────
  Future<BillScanResult?> _processMultipleImages(
      List<String> imagePaths) async {
    final mergedBuffer = StringBuffer();
    for (int i = 0; i < imagePaths.length; i++) {
      final inputImage = InputImage.fromFilePath(imagePaths[i]);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      for (final block in recognizedText.blocks) {
        for (final line in block.lines) {
          mergedBuffer.write(line.text);
          mergedBuffer.write('\n');
        }
      }
    }
    final mergedText = mergedBuffer.toString();
    if (mergedText.trim().isEmpty) return null;
    return _extractItemsWithGroq(mergedText);
  }

  // ─── Shared Image Processing ───────────────────────────────────
  Future<BillScanResult?> _processImage(String imagePath,
      {String source = ''}) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final recognizedText = await _textRecognizer.processImage(inputImage);

    final rawBuffer = StringBuffer();
    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        rawBuffer.write(line.text);
        rawBuffer.write('\n');
      }
    }
    final rawText = rawBuffer.toString();

    debugPrint('---------- OCR RAW OUTPUT ($source) ----------');
    debugPrint(rawText);
    debugPrint('----------------------------------------------');

    if (rawText.trim().isEmpty) return null;
    return _extractItemsWithGroq(rawText);
  }

  // ─── Groq Extraction ───────────────────────────────────────────
  Future<BillScanResult?> _extractItemsWithGroq(String ocrText) async {
    try {
      final response = await _httpClient.post(
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
              'content': '''You are a Sri Lankan bill/receipt parser. Extract all individual line items and the final payable total.

IMPORTANT: OCR text may have garbled Sinhala labels. Numbers will still be present.

Return ONLY a valid JSON object — no markdown, no explanation:
{"items": [{"name": "Item Name", "price": 99.99}], "total": 123.45}

Rules for items:
- Only individual purchased items (product name + its unit price)
- Skip rows like TOTAL, SUBTOTAL, TAX, DISCOUNT, CASH GIVEN, BALANCE, CHANGE
- Use clean readable names (fix obvious OCR garbling)
- Prices must be positive numbers

Rules for total:
- total = the final NET PAYABLE amount the customer paid
- NOT the cash given amount, NOT the balance/change
- If unsure, compute sum of item prices

OCR TEXT:
$ocrText

Respond with ONLY the JSON object.''',
            }
          ],
          'max_tokens': 600,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final content =
            (data['choices'][0]['message']['content'] as String).trim();
        debugPrint('Groq Response: $content');
        return _parser.parseGroqResponse(content, ocrText);
      } else {
        debugPrint('Groq Error: ${response.body}');
        return _parser.ocrFallback(ocrText);
      }
    } catch (e) {
      debugPrint('Groq Error: $e');
      return _parser.ocrFallback(ocrText);
    }
  }

  /// Bypasses OCR and feeds [ocrText] directly to the Groq extraction path.
  /// Only for use in unit tests.
  @visibleForTesting
  Future<BillScanResult?> extractItemsFromText(String ocrText) =>
      _extractItemsWithGroq(ocrText);

  // ─── Dispose ───────────────────────────────────────────────────
  void dispose() {
    // close() returns Future<void> via a MethodChannel; swallow async errors
    // that arise in environments where the Flutter binding is not initialised
    // (e.g. plain unit tests).
    _textRecognizer.close().catchError((_) {});
    _httpClient.close();
  }
}
