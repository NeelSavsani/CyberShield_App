import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/scan_result.dart';
import '../providers/scan_provider.dart';
import '../theme/cyber_theme.dart';
import '../widgets/cyber_card.dart';
import '../widgets/scanning_radar.dart';

class DashboardScreen extends StatefulWidget {
  final ValueChanged<ScanResult> onResultSelected;

  const DashboardScreen({super.key, required this.onResultSelected});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _urlController = TextEditingController();
  Uint8List? _selectedQrBytes;
  String? _selectedQrFileName;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _handleUrlScan() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a target URL to analyze')),
      );
      return;
    }
    final scan = context.read<ScanProvider>();
    final result = await scan.scanUrl(url);
    if (result != null && mounted) {
      widget.onResultSelected(result);
    }
  }

  Future<void> _pickQrImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedQrBytes = bytes;
          _selectedQrFileName = image.name;
        });
      }
    } catch (_) {
      // Fallback to FilePicker
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['png', 'jpg', 'jpeg', 'webp'],
      );
      if (result != null && result.files.single.bytes != null) {
        setState(() {
          _selectedQrBytes = result.files.single.bytes;
          _selectedQrFileName = result.files.single.name;
        });
      }
    }
  }

  Future<void> _handleQrScan() async {
    if (_selectedQrBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a QR code image to decode')),
      );
      return;
    }
    final scan = context.read<ScanProvider>();
    final result = await scan.scanQrImage(
      _selectedQrBytes!,
      _selectedQrFileName ?? 'qrcode.png',
    );
    if (result != null && mounted) {
      widget.onResultSelected(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scan = context.watch<ScanProvider>();
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: CyberTheme.navyDark,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 32 : 16,
              vertical: 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Security Operations Console',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: isDesktop ? 26 : 20,
                              fontWeight: FontWeight.w700,
                              color: CyberTheme.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Inspect real-time target URLs and QR code payloads against multi-stage threat heuristics.',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: CyberTheme.slateLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Quick Stat Counters
                Row(
                  children: [
                    _buildMetricCard(
                      'TOTAL SCANNED',
                      '${scan.totalScans}',
                      FontAwesomeIcons.listCheck,
                      CyberTheme.cyan,
                    ),
                    const SizedBox(width: 12),
                    _buildMetricCard(
                      'THREATS DETECTED',
                      '${scan.phishingDetected}',
                      FontAwesomeIcons.triangleExclamation,
                      CyberTheme.danger,
                    ),
                    const SizedBox(width: 12),
                    _buildMetricCard(
                      'SAFE SITES',
                      '${scan.safeUrls}',
                      FontAwesomeIcons.circleCheck,
                      CyberTheme.success,
                    ),
                    if (isDesktop) ...[
                      const SizedBox(width: 12),
                      _buildMetricCard(
                        'AVG LATENCY',
                        '1.2s',
                        FontAwesomeIcons.stopwatch,
                        CyberTheme.teal,
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 24),

                // Main Scanner Container
                CyberCard(
                  glow: true,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Dual Tabs
                      TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        indicatorColor: CyberTheme.cyan,
                        indicatorWeight: 3,
                        dividerColor: Colors.transparent,
                        labelColor: CyberTheme.cyan,
                        unselectedLabelColor: CyberTheme.slateLight,
                        labelStyle: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                        tabs: const [
                          Tab(
                            icon: FaIcon(FontAwesomeIcons.globe, size: 15),
                            text: 'URL Threat Scanner',
                          ),
                          Tab(
                            icon: FaIcon(FontAwesomeIcons.qrcode, size: 15),
                            text: 'QR Code Analyzer',
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        height: 220,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            // Tab 1: URL Scanner
                            _buildUrlScannerTab(),

                            // Tab 2: QR Scanner
                            _buildQrScannerTab(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Recent Scans Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Intelligence Scans',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: CyberTheme.white,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => scan.clearAllHistory(),
                      icon: const FaIcon(FontAwesomeIcons.trashCan, size: 12, color: CyberTheme.slateLight),
                      label: Text(
                        'Clear Archive',
                        style: GoogleFonts.inter(fontSize: 12, color: CyberTheme.slateLight),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                if (scan.history.isEmpty)
                  CyberCard(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Text(
                        'No scan logs recorded yet. Enter a URL above to begin your first threat investigation.',
                        style: GoogleFonts.inter(color: CyberTheme.slateLight, fontSize: 13),
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: scan.history.take(6).length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = scan.history[index];
                      return _buildRecentScanTile(item);
                    },
                  ),
              ],
            ),
          ),

          // Full Screen Scanning Overlay Modal
          if (scan.isScanning)
            Container(
              color: Colors.black.withOpacity(0.85),
              child: BackdropFilter(
                filter: ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.darken),
                child: Center(
                  child: ScanningRadar(stage: scan.currentStage),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUrlScannerTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: CyberTheme.navyLight.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: CyberTheme.cardBorder),
                ),
                child: TextField(
                  controller: _urlController,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: const InputDecoration(
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(12),
                      child: FaIcon(FontAwesomeIcons.link, color: CyberTheme.cyan, size: 16),
                    ),
                    hintText: 'Enter complete web URL (e.g. https://login-bank-verification.com)',
                    hintStyle: TextStyle(color: CyberTheme.slateLight, fontSize: 13),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  onSubmitted: (_) => _handleUrlScan(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: _handleUrlScan,
              icon: const FaIcon(FontAwesomeIcons.bolt, size: 14),
              label: const Text('Analyze URL'),
              style: ElevatedButton.styleFrom(
                backgroundColor: CyberTheme.cyan,
                foregroundColor: CyberTheme.navyDark,
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        Text(
          'Quick Target Sandbox Scenarios:',
          style: GoogleFonts.inter(fontSize: 12, color: CyberTheme.slateLight, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),

        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: [
            _buildSampleButton('Phishing Target', 'https://secure-login-verify-account-update.xyz/auth', CyberTheme.danger),
            _buildSampleButton('Safe Platform', 'https://github.com/login', CyberTheme.success),
            _buildSampleButton('Suspicious Redirect', 'http://tracking-package-update.tk/invoice.php', CyberTheme.warning),
          ],
        ),
      ],
    );
  }

  Widget _buildQrScannerTab() {
    return Row(
      children: [
        // Drop / Pick Zone
        Expanded(
          flex: 2,
          child: InkWell(
            onTap: _pickQrImage,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CyberTheme.navyLight.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _selectedQrBytes != null ? CyberTheme.cyan : CyberTheme.cardBorder,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(
                    _selectedQrBytes != null ? FontAwesomeIcons.circleCheck : FontAwesomeIcons.cloudArrowUp,
                    color: _selectedQrBytes != null ? CyberTheme.cyan : CyberTheme.slateLight,
                    size: 28,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _selectedQrFileName ?? 'Click or tap to select QR code image (PNG, JPEG, WebP)',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _selectedQrBytes != null ? CyberTheme.white : CyberTheme.slateLight,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(width: 16),

        // QR Image Preview and Action
        if (_selectedQrBytes != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(
              _selectedQrBytes!,
              width: 90,
              height: 90,
              fit: BoxFit.cover,
            ),
          ),

        const SizedBox(width: 16),

        ElevatedButton.icon(
          onPressed: _handleQrScan,
          icon: const FaIcon(FontAwesomeIcons.qrcode, size: 14),
          label: const Text('Decode & Scan'),
          style: ElevatedButton.styleFrom(
            backgroundColor: CyberTheme.cyan,
            foregroundColor: CyberTheme.navyDark,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildSampleButton(String label, String url, Color color) {
    return InkWell(
      onTap: () {
        _urlController.text = url;
        _handleUrlScan();
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: CyberTheme.navyMid,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(fontSize: 12, color: CyberTheme.grayLt, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String val, dynamic icon, Color color) {
    return Expanded(
      child: CyberCard(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: FaIcon(icon, color: color, size: 14),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    val,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: CyberTheme.white,
                    ),
                  ),
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: CyberTheme.slateLight,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentScanTile(ScanResult item) {
    final color = item.isPhishing
        ? CyberTheme.danger
        : (item.isSuspicious ? CyberTheme.warning : CyberTheme.success);

    return CyberCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      onTap: () => widget.onResultSelected(item),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.14),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withOpacity(0.4)),
            ),
            child: Center(
              child: Text(
                '${item.riskScore}',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.url,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: CyberTheme.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      DateFormat('MMM d, HH:mm').format(item.analyzedAt),
                      style: GoogleFonts.inter(fontSize: 11, color: CyberTheme.slateLight),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '• ${item.classifier}',
                        style: GoogleFonts.inter(fontSize: 11, color: CyberTheme.slateLight),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.14),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: color.withOpacity(0.4)),
            ),
            child: Text(
              item.verdict.toUpperCase(),
              style: GoogleFonts.spaceGrotesk(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 6),
          const FaIcon(FontAwesomeIcons.chevronRight, size: 10, color: CyberTheme.slateLight),
        ],
      ),
    );
  }
}
