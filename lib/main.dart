import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'models/scan_result.dart';
import 'providers/auth_provider.dart';
import 'providers/scan_provider.dart';
import 'screens/auth_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/history_screen.dart';
import 'screens/landing_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/result_screen.dart';
import 'screens/settings_screen.dart';
import 'theme/cyber_theme.dart';
import 'widgets/sidebar_navigation.dart';

import 'services/firebase_auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseAuthService.initialize();
  runApp(const CyberShieldApp());
}

class CyberShieldApp extends StatelessWidget {
  const CyberShieldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ScanProvider()),
      ],
      child: MaterialApp(
        title: 'CyberShield — Phishing & Threat Detection',
        debugShowCheckedModeBanner: false,
        theme: CyberTheme.darkTheme,
        home: const MainShell(),
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 1; // Default to Threat Scanner Console
  ScanResult? _selectedResult;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    // If unauthenticated, show AuthScreen
    if (!auth.isAuthenticated) {
      return AuthScreen(
        onLoginSuccess: () => setState(() => _currentIndex = 1),
      );
    }

    // If inspecting a specific result, show ResultScreen
    if (_selectedResult != null) {
      return ResultScreen(
        result: _selectedResult!,
        onBack: () => setState(() => _selectedResult = null),
        onRescan: (url) async {
          setState(() => _selectedResult = null);
          setState(() => _currentIndex = 1);
          final result = await context.read<ScanProvider>().scanUrl(url);
          if (result != null && mounted) {
            setState(() => _selectedResult = result);
          }
        },
      );
    }

    final isDesktop = MediaQuery.of(context).size.width > 900;

    // Body content by tab index
    Widget body;
    switch (_currentIndex) {
      case 0:
        body = LandingScreen(
          onNavigateToDashboard: () => setState(() => _currentIndex = 1),
          onQuickScan: (url) async {
            setState(() => _currentIndex = 1);
            final result = await context.read<ScanProvider>().scanUrl(url);
            if (result != null && mounted) {
              setState(() => _selectedResult = result);
            }
          },
        );
        break;
      case 1:
        body = DashboardScreen(
          onResultSelected: (result) => setState(() => _selectedResult = result),
        );
        break;
      case 2:
        body = HistoryScreen(
          onResultSelected: (result) => setState(() => _selectedResult = result),
        );
        break;
      case 3:
        body = const ReportsScreen();
        break;
      case 4:
        body = SettingsScreen(
          onLogout: () => auth.logout(),
        );
        break;
      default:
        body = DashboardScreen(
          onResultSelected: (result) => setState(() => _selectedResult = result),
        );
    }

    if (isDesktop) {
      // Desktop shell with full sidebar
      return Scaffold(
        backgroundColor: CyberTheme.navyDark,
        body: Row(
          children: [
            SidebarNavigation(
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _selectedResult = null;
                  _currentIndex = index;
                });
              },
            ),
            Expanded(child: body),
          ],
        ),
      );
    }

    // Mobile / Tablet shell with BottomNavigationBar
    return Scaffold(
      backgroundColor: CyberTheme.navyDark,
      body: body,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: CyberTheme.navy,
          border: Border(
            top: BorderSide(color: Color(0x1A00C8FF)),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _selectedResult = null;
              _currentIndex = index;
            });
          },
          backgroundColor: Colors.transparent,
          selectedItemColor: CyberTheme.cyan,
          unselectedItemColor: CyberTheme.slateLight,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.w700),
          unselectedLabelStyle: GoogleFonts.inter(fontSize: 11),
          items: const [
            BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.house, size: 16),
              label: 'Overview',
            ),
            BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.magnifyingGlassChart, size: 16),
              label: 'Scanner',
            ),
            BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.clockRotateLeft, size: 16),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.fileShield, size: 16),
              label: 'Reports',
            ),
            BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.gears, size: 16),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
