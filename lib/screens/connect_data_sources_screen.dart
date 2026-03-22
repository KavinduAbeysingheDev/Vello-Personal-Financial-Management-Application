import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/sms_import_service.dart';
import '../services/gmail_connection_service.dart';
import '../services/gmail_sync_service.dart';
import '../widgets/vello_top_bar.dart';
import '../widgets/vello_drawer.dart';

class ConnectDataSourcesScreen extends StatefulWidget {
  const ConnectDataSourcesScreen({super.key});

  @override
  State<ConnectDataSourcesScreen> createState() => _ConnectDataSourcesScreenState();
}

class _ConnectDataSourcesScreenState extends State<ConnectDataSourcesScreen> {
  final SmsImportService _smsService = SmsImportService();
  final GmailConnectionService _gmailConnService = GmailConnectionService();
  final GmailSyncService _gmailSyncService = GmailSyncService();
  
  bool _isGmailConnected = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final connected = await _gmailConnService.isGmailConnected();
    if (mounted) {
      setState(() => _isGmailConnected = connected);
    }
  }

  Future<void> _handleSmsSync() async {
    setState(() => _isLoading = true);
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      await _smsService.importSmsTransactions(userId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('SMS Import completed. Check your transactions.')),
        );
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _toggleGmail() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    setState(() => _isLoading = true);
    if (_isGmailConnected) {
      // For MVP we just show a message, real logout would delete from DB
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Disconnecting Gmail...')),
      );
    } else {
      await _gmailConnService.connectGmail(userId);
      await _checkStatus();
    }
    setState(() => _isLoading = false);
  }

  Future<void> _syncGmail() async {
    setState(() => _isLoading = true);
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      await _gmailSyncService.triggerGmailSync(userId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gmail Sync triggered. Processing results...')),
        );
      }
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const VelloTopBar(),
      drawer: const VelloDrawer(),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Text(
                'Data Sources',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
              ),
              const SizedBox(height: 8),
              const Text(
                'Connect your financial feeds to automatically track spending.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              
              // SMS Card
              _buildSourceCard(
                title: 'Android SMS Alerts',
                description: 'Scan your inbox for bank transaction alerts and auto-categorize them.',
                icon: Icons.sms_outlined,
                color: Colors.blue,
                isConnected: true, // Always available on Android
                actionLabel: 'Sync Now',
                onAction: _handleSmsSync,
              ),
              
              const SizedBox(height: 20),
              
              // Gmail Card
              _buildSourceCard(
                title: 'Gmail Receipts',
                description: 'Securely extract purchase details from digital receipts and invoices.',
                icon: Icons.email_outlined,
                color: Colors.red,
                isConnected: _isGmailConnected,
                actionLabel: _isGmailConnected ? 'Sync Purchases' : 'Connect Gmail',
                onAction: _isGmailConnected ? _syncGmail : _toggleGmail,
                secondaryAction: _isGmailConnected ? IconButton(
                  icon: const Icon(Icons.link_off, color: Colors.grey),
                  onPressed: () {}, // Disconnect TODO
                ) : null,
              ),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black12,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildSourceCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required bool isConnected,
    required String actionLabel,
    required VoidCallback onAction,
    Widget? secondaryAction,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isConnected ? Colors.green : Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isConnected ? 'Connected' : 'Not Connected',
                          style: TextStyle(
                            fontSize: 12,
                            color: isConnected ? Colors.green : Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (secondaryAction != null) secondaryAction,
            ],
          ),
          const SizedBox(height: 16),
          Text(description, style: const TextStyle(color: Colors.black87, height: 1.4)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: isConnected ? color : const Color(0xFF111827),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleHeader(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(actionLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

class RoundedRectangleHeader extends OutlinedBorder {
  final BorderRadius borderRadius;
  const RoundedRectangleHeader({required this.borderRadius});
  @override
  OutlinedBorder copyWith({BorderSide? side, BorderRadius? borderRadius}) => RoundedRectangleHeader(borderRadius: borderRadius ?? this.borderRadius);
  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => Path()..addRRect(borderRadius.resolve(textDirection).toRRect(rect).deflate(side.width));
  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) => Path()..addRRect(borderRadius.resolve(textDirection).toRRect(rect));
  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (rect.isEmpty) return;
    final rrect = borderRadius.resolve(textDirection).toRRect(rect);
    canvas.drawRRect(rrect, side.toPaint());
  }
  @override
  ShapeBorder scale(double t) => RoundedRectangleHeader(borderRadius: borderRadius * t);
}
