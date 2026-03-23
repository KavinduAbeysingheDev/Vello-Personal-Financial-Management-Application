import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../services/app_provider.dart';
import '../../models/app_models.dart';

class VoiceExpenseScreen extends StatefulWidget {
  const VoiceExpenseScreen({super.key});

  @override
  State<VoiceExpenseScreen> createState() => _VoiceExpenseScreenState();
}

class _VoiceExpenseScreenState extends State<VoiceExpenseScreen> {
  bool _isRecording = false;
  String _statusText = 'Tap to speak';
  String? _detectedAmount;
  String? _detectedTitle;

  // Simulated recognition patterns
  final List<Map<String, dynamic>> _mockRecognitions = [
    {'title': 'Lunch', 'amount': 15.00, 'category': 'Food'},
    {'title': 'Coffee', 'amount': 5.50, 'category': 'Food'},
    {'title': 'Uber ride', 'amount': 12.00, 'category': 'Transport'},
    {'title': 'Groceries', 'amount': 45.00, 'category': 'Food'},
    {'title': 'Movie ticket', 'amount': 14.99, 'category': 'Entertainment'},
  ];

  void _toggleRecording() {
    if (_isRecording) return;
    setState(() {
      _isRecording = true;
      _statusText = 'Listening...';
      _detectedAmount = null;
      _detectedTitle = null;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _statusText = 'Processing...');

      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        // Pick a random mock recognition
        final now = DateTime.now();
        final mock = _mockRecognitions[now.millisecond % _mockRecognitions.length];
        setState(() {
          _isRecording = false;
          _statusText = 'Tap to speak';
          _detectedTitle = mock['title'];
          _detectedAmount = '\$${(mock['amount'] as double).toStringAsFixed(2)}';
        });
        _showConfirmDialog(mock['title'], mock['amount'], mock['category']);
      });
    });
  }

  void _showConfirmDialog(String title, double amount, String category) {
    final titleController = TextEditingController(text: title);
    final amountController = TextEditingController(text: amount.toStringAsFixed(2));

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.mic, color: Color(0xFF004D40)),
            SizedBox(width: 8),
            Text('Add Expense?', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF9F3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF0AA36C).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.record_voice_over, color: Color(0xFF0AA36C), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Detected: "$title" for \$${amount.toStringAsFixed(2)}',
                      style: const TextStyle(color: Color(0xFF004D40), fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount (\$)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Discard')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF004D40), foregroundColor: Colors.white),
            onPressed: () {
              final amt = double.tryParse(amountController.text) ?? 0;
              if (amt <= 0) return;
              final newTx = AppTransaction(
                id: const Uuid().v4(),
                title: titleController.text,
                category: category,
                amount: amt,
                date: DateTime.now(),
                type: TransactionType.expense,
                icon: Icons.mic,
              );
              Provider.of<AppProvider>(context, listen: false).addTransaction(newTx);
              Navigator.pop(dialogCtx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${titleController.text} — \$${amt.toStringAsFixed(2)} added to expenses!')),
              );
            },
            child: const Text('Add Expense'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Expense'),
        backgroundColor: const Color(0xFF004D40),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _isRecording ? 'Listening...' : _statusText,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF004D40)),
            ),
            const SizedBox(height: 10),
            Text(
              _isRecording
                  ? 'Say something like: "I spent \$15 on lunch"'
                  : 'Try: "I spent \$15 on lunch today"',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 60),
            GestureDetector(
              onTap: _toggleRecording,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: _isRecording ? 180 : 150,
                height: _isRecording ? 180 : 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isRecording
                      ? const Color(0xFFFF1744).withOpacity(0.15)
                      : const Color(0xFF004D40).withOpacity(0.08),
                ),
                child: Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isRecording ? const Color(0xFFFF1744) : const Color(0xFF004D40),
                      boxShadow: [
                        BoxShadow(
                          color: (_isRecording ? const Color(0xFFFF1744) : const Color(0xFF004D40)).withOpacity(0.35),
                          blurRadius: 24,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Icon(
                      _isRecording ? Icons.stop : Icons.mic,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Tap the microphone and speak your expense naturally. It will be automatically added to your transactions.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.black38, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
