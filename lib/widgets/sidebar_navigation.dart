import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/cyber_theme.dart';

class SidebarNavigation extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const SidebarNavigation({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Container(
      width: 240,
      decoration: const BoxDecoration(
        color: CyberTheme.navy,
        border: Border(
          right: BorderSide(color: Color(0x1A00C8FF), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand Logo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: CyberTheme.cyan.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: CyberTheme.cyan.withOpacity(0.3)),
                  ),
                  child: const Center(
                    child: FaIcon(
                      FontAwesomeIcons.shieldHalved,
                      color: CyberTheme.cyan,
                      size: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                RichText(
                  text: TextSpan(
                    text: 'CYBER',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: CyberTheme.white,
                      letterSpacing: 0.5,
                    ),
                    children: const [
                      TextSpan(
                        text: 'SHIELD',
                        style: TextStyle(color: CyberTheme.cyan),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: Color(0x14FFFFFF), height: 1),

          // Menu Sections
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              children: [
                _buildSectionHeader('CORE PLATFORM'),
                _buildNavItem(0, 'Home & Overview', FontAwesomeIcons.house),
                _buildNavItem(1, 'Threat Scanner', FontAwesomeIcons.magnifyingGlassChart),
                _buildNavItem(2, 'Scan History', FontAwesomeIcons.clockRotateLeft),
                _buildNavItem(3, 'Security Reports', FontAwesomeIcons.fileShield),

                const SizedBox(height: 16),
                _buildSectionHeader('SYSTEM & CONFIG'),
                _buildNavItem(4, 'Settings & Engine', FontAwesomeIcons.gears),
              ],
            ),
          ),

          // Autonomous Engine Live Status Badge
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: CyberTheme.success.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: CyberTheme.success.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: CyberTheme.success,
                      boxShadow: [
                        BoxShadow(
                          color: CyberTheme.success.withOpacity(0.6),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Autonomous Engine (Active)',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: CyberTheme.success,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Divider(color: Color(0x14FFFFFF), height: 1),

          // User Profile Card
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: CyberTheme.cyan.withOpacity(0.2),
                  child: Text(
                    auth.user?.displayName.substring(0, 1) ?? 'A',
                    style: const TextStyle(
                      color: CyberTheme.cyan,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        auth.user?.displayName ?? 'Analyst',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: CyberTheme.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        auth.user?.role.toUpperCase() ?? 'ANALYST',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: CyberTheme.slateLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 12, bottom: 6),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.white.withOpacity(0.3),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String title, dynamic icon) {
    final isSelected = selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: InkWell(
        onTap: () => onDestinationSelected(index),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? CyberTheme.cyan.withOpacity(0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isSelected
                ? Border.all(color: CyberTheme.cyan.withOpacity(0.3))
                : null,
          ),
          child: Row(
            children: [
              FaIcon(
                icon,
                size: 16,
                color: isSelected ? CyberTheme.cyan : CyberTheme.slateLight,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? CyberTheme.cyan : CyberTheme.grayLt,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
