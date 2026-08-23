import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/scan_result.dart';
import '../providers/scan_provider.dart';
import '../theme/cyber_theme.dart';
import '../widgets/cyber_card.dart';

class HistoryScreen extends StatefulWidget {
  final ValueChanged<ScanResult> onResultSelected;

  const HistoryScreen({super.key, required this.onResultSelected});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scan = context.watch<ScanProvider>();
    final isDesktop = MediaQuery.of(context).size.width > 900;

    final query = _searchController.text.trim().toLowerCase();
    final items = scan.filteredHistory.where((s) {
      if (query.isEmpty) return true;
      return s.url.toLowerCase().contains(query) || s.verdict.toLowerCase().contains(query);
    }).toList();

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
                        'Investigation History & Audit Logs',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: isDesktop ? 26 : 20,
                          fontWeight: FontWeight.w700,
                          color: CyberTheme.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Browse, search, and review historical threat inspections and telemetry.',
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
                  onPressed: () => scan.clearAllHistory(),
                  icon: const FaIcon(FontAwesomeIcons.trashCan, size: 13),
                  label: const Text('Clear All'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CyberTheme.navyLight,
                    foregroundColor: CyberTheme.danger,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Search Bar & Filter Chips
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: CyberTheme.navyMid,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: CyberTheme.cardBorder),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        prefixIcon: Padding(
                          padding: EdgeInsets.all(12),
                          child: FaIcon(FontAwesomeIcons.magnifyingGlass, size: 14, color: CyberTheme.slateLight),
                        ),
                        hintText: 'Search by URL, domain, or verdict...',
                        hintStyle: TextStyle(color: CyberTheme.slateLight, fontSize: 13),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Filter Chips
            Wrap(
              spacing: 8,
              children: [
                _buildFilterChip('all', 'All Verdicts (${scan.history.length})', scan),
                _buildFilterChip('safe', 'Safe Sites (${scan.safeUrls})', scan),
                _buildFilterChip('suspicious', 'Suspicious (${scan.suspiciousUrls})', scan),
                _buildFilterChip('phishing', 'Phishing Threats (${scan.phishingDetected})', scan),
              ],
            ),

            const SizedBox(height: 20),

            // History List
            if (items.isEmpty)
              CyberCard(
                padding: const EdgeInsets.all(40),
                child: Center(
                  child: Column(
                    children: [
                      const FaIcon(FontAwesomeIcons.inbox, size: 36, color: CyberTheme.slateLight),
                      const SizedBox(height: 12),
                      Text(
                        'No matching investigation records found.',
                        style: GoogleFonts.inter(fontSize: 14, color: CyberTheme.slateLight),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = items[index];
                  final color = item.isPhishing
                      ? CyberTheme.danger
                      : (item.isSuspicious ? CyberTheme.warning : CyberTheme.success);

                  return CyberCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    onTap: () => widget.onResultSelected(item),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.14),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: color.withOpacity(0.4)),
                          ),
                          child: Center(
                            child: Text(
                              '${item.riskScore}',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: color,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.url,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: CyberTheme.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    DateFormat('yyyy-MM-dd HH:mm').format(item.analyzedAt),
                                    style: GoogleFonts.inter(fontSize: 11, color: CyberTheme.slateLight),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '• ${item.indicators.length} indicators',
                                      style: GoogleFonts.inter(fontSize: 11, color: CyberTheme.slateLight),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.14),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: color.withOpacity(0.4)),
                          ),
                          child: Text(
                            item.verdict.toUpperCase(),
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: color,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const FaIcon(FontAwesomeIcons.chevronRight, size: 12, color: CyberTheme.slateLight),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    ));
  }

  Widget _buildFilterChip(String filterKey, String label, ScanProvider scan) {
    final isSelected = scan.activeFilter == filterKey;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => scan.setFilter(filterKey),
      selectedColor: CyberTheme.cyan.withOpacity(0.2),
      backgroundColor: CyberTheme.navyMid,
      labelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        color: isSelected ? CyberTheme.cyan : CyberTheme.slateLight,
      ),
      side: BorderSide(
        color: isSelected ? CyberTheme.cyan : CyberTheme.cardBorder,
      ),
    );
  }
}
