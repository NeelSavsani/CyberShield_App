import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/storage_service.dart';
import '../theme/cyber_theme.dart';
import '../widgets/cyber_card.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const SettingsScreen({super.key, required this.onLogout});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _sensitivity = 'standard'; // 'standard', 'high', 'strict'
  bool _useTrainedModel = true;
  bool _homographCheck = true;
  bool _soundEnabled = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final sensitivity = await StorageService.getEngineSensitivity();
    final trained = await StorageService.getUseTrainedModel();
    final homograph = await StorageService.getHomographCheckEnabled();
    final sound = await StorageService.getSoundEnabled();
    setState(() {
      _sensitivity = sensitivity;
      _useTrainedModel = trained;
      _homographCheck = homograph;
      _soundEnabled = sound;
      _isLoading = false;
    });
  }

  Future<void> _saveSensitivity(String val) async {
    setState(() => _sensitivity = val);
    await StorageService.setEngineSensitivity(val);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Heuristic engine sensitivity updated to ${val.toUpperCase()}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _saveSettingToggles() async {
    await StorageService.setUseTrainedModel(_useTrainedModel);
    await StorageService.setHomographCheckEnabled(_homographCheck);
    await StorageService.setSoundEnabled(_soundEnabled);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isDesktop = MediaQuery.of(context).size.width > 900;

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: CyberTheme.navyDark,
        body: Center(child: CircularProgressIndicator(color: CyberTheme.cyan)),
      );
    }

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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Threat Engine & Platform Settings',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: isDesktop ? 26 : 20,
                    fontWeight: FontWeight.w700,
                    color: CyberTheme.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Configure on-device heuristic classifiers, algorithmic thresholds, and alert preferences.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: CyberTheme.slateLight,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Autonomous Engine Status Card
            CyberCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const FaIcon(FontAwesomeIcons.microchip, color: CyberTheme.cyan, size: 18),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Autonomous Threat Intelligence Engine',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: CyberTheme.white,
                              ),
                            ),
                            Text(
                              '100% On-Device • Zero Server Dependency • Offline Resilient',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: CyberTheme.teal,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: CyberTheme.success.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: CyberTheme.success),
                        ),
                        child: Text(
                          'ENGINE READY',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: CyberTheme.success,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'CyberShield analyzes target URLs and QR payloads using built-in lexical heuristics, Shannon entropy calculations, brand typosquatting indices, and cryptographic baseline estimators directly within this application.',
                    style: GoogleFonts.inter(fontSize: 12, color: CyberTheme.slateLight, height: 1.4),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Heuristic Sensitivity Level
            CyberCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Heuristic Sensitivity & Threat Thresholds',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: CyberTheme.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Adjust the risk multiplier applied to suspicious TLDs, IP literals, and deceptive URL subdomains.',
                    style: GoogleFonts.inter(fontSize: 12, color: CyberTheme.slateLight),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      _buildSensitivityOption('standard', 'Standard (Balanced)', 'Recommended for everyday enterprise browsing and general threat telemetry.'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildSensitivityOption('high', 'High Security (+15% Risk Multiplier)', 'Increases weight on newly registered TLDs and redirect chains.'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildSensitivityOption('strict', 'Strict Zero-Trust (+30% Risk Multiplier)', 'Immediately escalates unverified apex domains and IP hostnames.'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Deep Vector Toggles
            CyberCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vector Inspection Features',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: CyberTheme.white,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Autonomous Neural Evidence Baseline',
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: CyberTheme.white),
                    ),
                    subtitle: Text(
                      'Computes explainable feature contribution weights and multi-vector risk probabilities.',
                      style: GoogleFonts.inter(fontSize: 12, color: CyberTheme.slateLight),
                    ),
                    value: _useTrainedModel,
                    activeColor: CyberTheme.cyan,
                    onChanged: (val) {
                      setState(() => _useTrainedModel = val);
                      _saveSettingToggles();
                    },
                  ),
                  const Divider(color: CyberTheme.grayBorder, height: 24),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Homograph & Typosquatting Detection',
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: CyberTheme.white),
                    ),
                    subtitle: Text(
                      'Scans for lookalike characters and brand keyword hijacking in target hostnames.',
                      style: GoogleFonts.inter(fontSize: 12, color: CyberTheme.slateLight),
                    ),
                    value: _homographCheck,
                    activeColor: CyberTheme.cyan,
                    onChanged: (val) {
                      setState(() => _homographCheck = val);
                      _saveSettingToggles();
                    },
                  ),
                  const Divider(color: CyberTheme.grayBorder, height: 24),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Audio Alerts & Scan Completion Chimes',
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: CyberTheme.white),
                    ),
                    subtitle: Text(
                      'Play high-assurance audio cue when an intelligence scan completes.',
                      style: GoogleFonts.inter(fontSize: 12, color: CyberTheme.slateLight),
                    ),
                    value: _soundEnabled,
                    activeColor: CyberTheme.cyan,
                    onChanged: (val) {
                      setState(() => _soundEnabled = val);
                      _saveSettingToggles();
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // User Profile
            CyberCard(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: CyberTheme.cyan.withOpacity(0.2),
                    child: Text(
                      auth.user?.displayName.substring(0, 1) ?? 'A',
                      style: const TextStyle(color: CyberTheme.cyan, fontWeight: FontWeight.w700, fontSize: 18),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          auth.user?.displayName ?? 'Security Analyst',
                          style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w700, color: CyberTheme.white),
                        ),
                        Text(
                          auth.user?.email ?? 'analyst@cybershield.local',
                          style: GoogleFonts.inter(fontSize: 12, color: CyberTheme.slateLight),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: widget.onLogout,
                    icon: const FaIcon(FontAwesomeIcons.rightFromBracket, size: 12),
                    label: const Text('Sign Out'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CyberTheme.navyLight,
                      foregroundColor: CyberTheme.danger,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildSensitivityOption(String value, String title, String subtitle) {
    final isSelected = _sensitivity == value;
    return Expanded(
      child: InkWell(
        onTap: () => _saveSensitivity(value),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected ? CyberTheme.cyan.withOpacity(0.1) : CyberTheme.navyLight.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? CyberTheme.cyan : CyberTheme.cardBorder,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Radio<String>(
                value: value,
                groupValue: _sensitivity,
                activeColor: CyberTheme.cyan,
                onChanged: (val) {
                  if (val != null) _saveSensitivity(val);
                },
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? CyberTheme.cyan : CyberTheme.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(fontSize: 11, color: CyberTheme.slateLight),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
