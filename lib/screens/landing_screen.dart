import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/cyber_theme.dart';
import '../widgets/cyber_card.dart';

class LandingScreen extends StatefulWidget {
  final VoidCallback onNavigateToDashboard;
  final ValueChanged<String> onQuickScan;

  const LandingScreen({
    super.key,
    required this.onNavigateToDashboard,
    required this.onQuickScan,
  });

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final TextEditingController _urlController = TextEditingController();

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _handleScan() {
    final text = _urlController.text.trim();
    if (text.isEmpty) return;
    widget.onQuickScan(text);
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: CyberTheme.navyDark,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
          children: [
            // Top Navigation Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: CyberTheme.navy.withOpacity(0.9),
                border: const Border(
                  bottom: BorderSide(color: Color(0x1A00C8FF)),
                ),
              ),
              child: Row(
                children: [
                  const FaIcon(FontAwesomeIcons.shieldHalved, color: CyberTheme.cyan, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    'CYBERSHIELD',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: CyberTheme.white,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: widget.onNavigateToDashboard,
                    icon: const FaIcon(FontAwesomeIcons.magnifyingGlassChart, size: 14),
                    label: const Text('Open Console'),
                  ),
                ],
              ),
            ),

            // Hero Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 64 : 20,
                vertical: isDesktop ? 56 : 36,
              ),
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.4),
                  radius: 1.2,
                  colors: [
                    CyberTheme.cyan.withOpacity(0.12),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                children: [
                  // Live Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: CyberTheme.cyan.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: CyberTheme.cyan.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: CyberTheme.cyan,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'AI-POWERED LIVE INFRASTRUCTURE ANALYSIS v1.0',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: CyberTheme.cyan,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Headline
                  Text(
                    'Real-Time Phishing &\nThreat Intelligence',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: isDesktop ? 46 : 30,
                      fontWeight: FontWeight.w800,
                      color: CyberTheme.white,
                      height: 1.15,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Subtitle
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 680),
                    child: Text(
                      'CyberShield inspects live page behavior, TLS certificates, DOM forms, and DNS infrastructure using headless Chromium and explainable machine learning.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: CyberTheme.grayLt,
                        height: 1.6,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Quick Scan Input Box
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: CyberTheme.navyMid,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: CyberTheme.cyan.withOpacity(0.4), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: CyberTheme.cyan.withOpacity(0.15),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 14),
                            child: FaIcon(FontAwesomeIcons.globe, color: CyberTheme.cyan, size: 18),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _urlController,
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                              decoration: const InputDecoration(
                                hintText: 'Enter any website URL (e.g. https://example.com)',
                                hintStyle: TextStyle(color: CyberTheme.slateLight, fontSize: 14),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                filled: false,
                                contentPadding: EdgeInsets.symmetric(vertical: 12),
                              ),
                              onSubmitted: (_) => _handleScan(),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _handleScan,
                            icon: const FaIcon(FontAwesomeIcons.bolt, size: 14),
                            label: const Text('Analyze URL'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: CyberTheme.cyan,
                              foregroundColor: CyberTheme.navyDark,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Quick Demo Samples
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      Text(
                        'Sample URLs:',
                        style: GoogleFonts.inter(fontSize: 12, color: CyberTheme.slateLight),
                      ),
                      _buildQuickChip('https://github.com/login', Colors.green),
                      _buildQuickChip('https://secure-login-verify-account.xyz', Colors.red),
                      _buildQuickChip('https://appleid.apple.com', Colors.blue),
                    ],
                  ),
                ],
              ),
            ),

            // Statistics Row
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isDesktop ? 64 : 20, vertical: 16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Row(
                  children: [
                    _buildStatCard('99.4%', 'Detection Precision', CyberTheme.cyan),
                    const SizedBox(width: 16),
                    _buildStatCard('< 1.8s', 'Avg Scan Latency', CyberTheme.teal),
                    const SizedBox(width: 16),
                    _buildStatCard('24+', 'Heuristic Features', CyberTheme.purple),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // 6-Stage Pipeline Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isDesktop ? 64 : 20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Multi-Vector Threat Inspection Pipeline',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: CyberTheme.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'CyberShield executes comprehensive security vectors sequentially before calculating the final explainable risk score.',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: CyberTheme.slateLight,
                      ),
                    ),
                    const SizedBox(height: 20),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final count = constraints.maxWidth > 700 ? 3 : 1;
                        return GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: count,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: constraints.maxWidth > 700 ? 1.6 : 2.2,
                          children: [
                            _buildPipelineCard(
                              '01',
                              'DNS & Domain Telemetry',
                              'Resolves authoritative nameservers, MX records, WHOIS registration age, and DNSSEC validation.',
                              FontAwesomeIcons.networkWired,
                              CyberTheme.cyan,
                            ),
                            _buildPipelineCard(
                              '02',
                              'SSL / TLS Cryptography',
                              'Validates certificate trust hierarchy, cipher suites, expiration dates, and issuance anomalies.',
                              FontAwesomeIcons.lock,
                              CyberTheme.teal,
                            ),
                            _buildPipelineCard(
                              '03',
                              'Chromium Sandbox Render',
                              'Renders full dynamic webpage in an isolated browser sandbox to capture rendered screenshot and events.',
                              FontAwesomeIcons.desktop,
                              CyberTheme.purple,
                            ),
                            _buildPipelineCard(
                              '04',
                              'DOM & Form Extraction',
                              'Inspects credential inputs, OTP fields, cross-domain submission targets, and hidden iframes.',
                              FontAwesomeIcons.code,
                              CyberTheme.warning,
                            ),
                            _buildPipelineCard(
                              '05',
                              'JavaScript Heuristics',
                              'Detects obfuscated code, deceptive pop-ups, automatic downloads, and stealth redirection scripts.',
                              FontAwesomeIcons.fileCode,
                              CyberTheme.danger,
                            ),
                            _buildPipelineCard(
                              '06',
                              'Explainable ML Classifier',
                              'Calculates risk probability with detailed mathematical contributor weights and actionable indicators.',
                              FontAwesomeIcons.brain,
                              CyberTheme.cyan,
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 50),

            // Footer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
              color: CyberTheme.navy,
              child: Center(
                child: Text(
                  'CyberShield Threat Intelligence Platform © 2026. Built with Flutter & FastAPI.',
                  style: GoogleFonts.inter(fontSize: 12, color: CyberTheme.slateLight),
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildQuickChip(String url, Color color) {
    return InkWell(
      onTap: () {
        _urlController.text = url;
        _handleScan();
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: CyberTheme.navyMid,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Text(
          url,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: CyberTheme.grayLt,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, Color color) {
    return Expanded(
      child: CyberCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: CyberTheme.slateLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPipelineCard(String num, String title, String desc, dynamic icon, Color color) {
    return CyberCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: FaIcon(icon, size: 14, color: color),
              ),
              const Spacer(),
              Text(
                num,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: CyberTheme.slateLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: CyberTheme.white,
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Text(
              desc,
              style: GoogleFonts.inter(
                fontSize: 11.5,
                color: CyberTheme.slateLight,
                height: 1.4,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
            ),
          ),
        ],
      ),
    );
  }
}
