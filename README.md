# CyberShield — Autonomous Threat Intelligence & Phishing Scanner

A high-performance, cross-platform (Windows Desktop, Android, iOS, Web) threat intelligence and phishing analysis application built with Flutter.

CyberShield operates **100% standalone and autonomous** with its built-in on-device threat intelligence engine — requiring **zero external backend servers or web API dependencies**.

---

## Key Features

- **Autonomous On-Device Threat Intelligence**:
  - Lexical topology & subdomain depth deconstruction.
  - Shannon Entropy algorithmic randomness (DGA) analysis.
  - Brand impersonation & typosquatting detection across major tech, banking, and crypto platforms.
  - High-risk TLD reputation scoring (`.xyz`, `.top`, `.tk`, `.buzz`, `.icu`, etc.).
  - Insecure protocol & IP literal hostname flags.
- **Dual Vector Threat Scanner**:
  - **URL Threat Scanner**: Normalized input, live radar animation, and multi-stage progress tracking.
  - **QR Code Analyzer**: Image picker / camera capture and instant threat decoding.
- **Real-Time 6-Stage Heuristic Pipeline**:
  1. DNS & Registry Telemetry Synthesis
  2. SSL/TLS Cryptographic Cipher Analysis
  3. DOM Structure & Sensitive Credential Form Extraction
  4. JavaScript Obfuscation & Malicious Payload Heuristics
  5. Multi-Feed Reputation Simulation
  6. Explainable Evidence Baseline Risk Score & Contributor Weights
- **Deep Threat Report**:
  - Circular animated Risk Score meter (0–100) with classification verdict (`SAFE`, `SUSPICIOUS`, `PHISHING`).
  - Categorized inspection tabs (DNS, SSL, DOM, JavaScript, Reputation).
  - Multi-feature evidence weight breakdown with plain-English risk explanations.
- **Persistent Investigation Archive**: Searchable and filterable scan history saved locally via on-device storage.
- **Executive Security Reports**: Dynamic threat classification charts and actionable hardening guidelines.
- **Cyber Aesthetic Design System**: Deep cyber navy theme, electric cyan accents, glassmorphic cards, Space Grotesk & Inter typography.

---

## How to Run the Application

The application is completely self-contained. You do not need to start any backend server.

### 1. Prerequisites
Ensure you have Flutter installed:
```bash
flutter --version
```

### 2. Run the Application

#### On Windows Desktop:
```bash
flutter run -d windows
```

#### In Google Chrome / Web:
```bash
flutter run -d chrome
```

#### On Android Device / Emulator:
```bash
flutter run -d android
```

---

## Project Structure

```
cybershield_app/
├── lib/
│   ├── models/
│   │   └── scan_result.dart          # Data models for threat telemetry & scores
│   ├── providers/
│   │   ├── auth_provider.dart        # Session state & analyst profiles
│   │   └── scan_provider.dart        # Reactive scanning state & local history
│   ├── screens/
│   │   ├── auth_screen.dart          # Sign in / Register console
│   │   ├── dashboard_screen.dart     # URL & QR scanner dashboard
│   │   ├── history_screen.dart       # Searchable investigation logs
│   │   ├── landing_screen.dart       # Landing showcase & quick scanner
│   │   ├── reports_screen.dart       # Threat distribution charts & metrics
│   │   ├── result_screen.dart        # Deep vector analysis & risk gauge
│   │   └── settings_screen.dart      # Engine sensitivity & vector toggles
│   ├── services/
│   │   ├── api_service.dart          # Gateway delegating to local ThreatEngine
│   │   ├── storage_service.dart      # On-device history & settings persistence
│   │   └── threat_engine.dart        # Autonomous on-device threat intelligence engine
│   ├── theme/
│   │   └── cyber_theme.dart          # Colors, gradients, and typography tokens
│   ├── widgets/
│   │   ├── cyber_card.dart           # Glassmorphic card container
│   │   ├── risk_gauge.dart           # Animated circular score meter
│   │   ├── scanning_radar.dart       # Live scanning radar animation
│   │   └── sidebar_navigation.dart   # Desktop / tablet navigation shell
│   └── main.dart                     # App entry point & responsive router
├── assets/
│   ├── images/                       # Logo and branding assets
│   └── audio/                        # Notification chimes
└── pubspec.yaml
```

---

## Architecture & Standalone Guarantee

- **Zero External API Calls**: All threat analysis, scoring algorithms, and evidence generation run locally in pure Dart.
- **Offline Resilient**: Functions with or without an active internet connection.
- **Rely-Free**: The application operates independently from any web platform or backend service.
