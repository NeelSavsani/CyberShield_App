import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/scan_provider.dart';
import '../theme/cyber_theme.dart';
import '../widgets/cyber_card.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scan = context.watch<ScanProvider>();
    final isDesktop = MediaQuery.of(context).size.width > 900;

    final total = scan.totalScans > 0 ? scan.totalScans : 1;
    final safePct = ((scan.safeUrls / total) * 100).toStringAsFixed(0);
    final phishPct = ((scan.phishingDetected / total) * 100).toStringAsFixed(0);
    final suspPct = ((scan.suspiciousUrls / total) * 100).toStringAsFixed(0);

    return Scaffold(
      backgroundColor: CyberTheme.navyDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 32 : 16,
            vertical: isDesktop ? 24 : 16,
          ),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Executive Threat & Security Intelligence',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: isDesktop ? 26 : 20,
                          fontWeight: FontWeight.w700,
                          color: CyberTheme.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Comprehensive telemetry breakdown and organizational threat posture report.',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: CyberTheme.slateLight,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Executive Security Audit Report generated!')),
                    );
                  },
                  icon: const FaIcon(FontAwesomeIcons.filePdf, size: 14),
                  label: const Text('Export Audit PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CyberTheme.cyan,
                    foregroundColor: CyberTheme.navyDark,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Top Stat Cards
            if (isDesktop)
              Row(
                children: [
                  _buildReportStatCard('Total Audits', '${scan.totalScans}', CyberTheme.cyan, 'Target URLs'),
                  const SizedBox(width: 12),
                  _buildReportStatCard('Threat Ratio', '$phishPct%', CyberTheme.danger, 'Phishing Detections'),
                  const SizedBox(width: 12),
                  _buildReportStatCard('Clean Ratio', '$safePct%', CyberTheme.success, 'Benign Validated'),
                  const SizedBox(width: 12),
                  _buildReportStatCard('Suspicious', '$suspPct%', CyberTheme.warning, 'Anomalies Flagged'),
                ],
              )
            else
              Column(
                children: [
                  Row(
                    children: [
                      _buildReportStatCard('Total Audits', '${scan.totalScans}', CyberTheme.cyan, 'Target URLs'),
                      const SizedBox(width: 10),
                      _buildReportStatCard('Threat Ratio', '$phishPct%', CyberTheme.danger, 'Phishing Detections'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildReportStatCard('Clean Ratio', '$safePct%', CyberTheme.success, 'Benign Validated'),
                      const SizedBox(width: 10),
                      _buildReportStatCard('Suspicious', '$suspPct%', CyberTheme.warning, 'Anomalies Flagged'),
                    ],
                  ),
                ],
              ),

            const SizedBox(height: 24),

            // Chart & Posture Breakdown
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 800) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: _buildDistributionChartCard(scan)),
                      const SizedBox(width: 20),
                      Expanded(flex: 2, child: _buildThreatVectorsCard()),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildDistributionChartCard(scan),
                      const SizedBox(height: 20),
                      _buildThreatVectorsCard(),
                    ],
                  );
                }
              },
            ),

            const SizedBox(height: 24),

            // Security Recommendations Card
            CyberCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Operational Hardening Recommendations',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: CyberTheme.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildRecItem(
                    FontAwesomeIcons.shieldHalved,
                    'Zero-Trust Form Verification',
                    'Block all credential submissions targeting cross-domain endpoints without strict CORS authentication.',
                  ),
                  _buildRecItem(
                    FontAwesomeIcons.clockRotateLeft,
                    'Quarantine Newly Registered Domains',
                    'Automatically flag domains under 14 days old for manual analyst review before allowing network access.',
                  ),
                  _buildRecItem(
                    FontAwesomeIcons.lock,
                    'Mandate TLS 1.3 & DNSSEC',
                    'Enforce high-assurance certificate verification and reject expired or self-signed certificates on external URLs.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildReportStatCard(String title, String val, Color color, String sub) {
    return Expanded(
      child: CyberCard(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: CyberTheme.slateLight),
            ),
            const SizedBox(height: 6),
            Text(
              val,
              style: GoogleFonts.spaceGrotesk(fontSize: 26, fontWeight: FontWeight.w700, color: color),
            ),
            const SizedBox(height: 4),
            Text(
              sub,
              style: GoogleFonts.inter(fontSize: 11, color: CyberTheme.slateLight),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDistributionChartCard(ScanProvider scan) {
    final hasData = scan.totalScans > 0;
    return CyberCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Target Threat Classification Breakdown',
            style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w700, color: CyberTheme.white),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: hasData
                ? PieChart(
                    PieChartData(
                      sectionsSpace: 4,
                      centerSpaceRadius: 40,
                      sections: [
                        PieChartSectionData(
                          value: scan.safeUrls.toDouble().clamp(1.0, 999.0),
                          title: '${scan.safeUrls}',
                          color: CyberTheme.success,
                          radius: 50,
                          titleStyle: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                        PieChartSectionData(
                          value: scan.phishingDetected.toDouble().clamp(1.0, 999.0),
                          title: '${scan.phishingDetected}',
                          color: CyberTheme.danger,
                          radius: 50,
                          titleStyle: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                        PieChartSectionData(
                          value: scan.suspiciousUrls.toDouble().clamp(1.0, 999.0),
                          title: '${scan.suspiciousUrls}',
                          color: CyberTheme.warning,
                          radius: 50,
                          titleStyle: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                      ],
                    ),
                  )
                : const Center(child: Text('Awaiting scan telemetry...')),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLegend('Safe Targets', CyberTheme.success),
              _buildLegend('Phishing Threats', CyberTheme.danger),
              _buildLegend('Suspicious Sites', CyberTheme.warning),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: GoogleFonts.inter(fontSize: 11, color: CyberTheme.grayLt)),
      ],
    );
  }

  Widget _buildThreatVectorsCard() {
    return CyberCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Primary Vector Distribution',
            style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w700, color: CyberTheme.white),
          ),
          const SizedBox(height: 16),
          _buildVectorRow('Credential Harvest Forms', 0.42, CyberTheme.danger),
          _buildVectorRow('Brand Impersonation / Typos', 0.28, CyberTheme.warning),
          _buildVectorRow('Obfuscated JS Exploits', 0.18, CyberTheme.purple),
          _buildVectorRow('Multi-Hop Redirects', 0.12, CyberTheme.teal),
        ],
      ),
    );
  }

  Widget _buildVectorRow(String title, double pct, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: GoogleFonts.inter(fontSize: 12, color: CyberTheme.white)),
              Text('${(pct * 100).toInt()}%', style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 6,
              backgroundColor: CyberTheme.navyLight.withOpacity(0.5),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecItem(dynamic icon, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: CyberTheme.cyan.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
            child: FaIcon(icon, color: CyberTheme.cyan, size: 14),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: CyberTheme.white)),
                const SizedBox(height: 2),
                Text(desc, style: GoogleFonts.inter(fontSize: 12, color: CyberTheme.slateLight)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
