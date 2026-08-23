import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/cyber_theme.dart';
import '../widgets/cyber_card.dart';

class AuthScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const AuthScreen({super.key, required this.onLoginSuccess});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isRegister = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _resetEmailController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _resetEmailController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final auth = context.read<AuthProvider>();
    auth.clearError();

    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final pass = _passwordController.text.trim();
    final name = _nameController.text.trim();

    if (_isRegister) {
      final success = await auth.register(name, email, pass);
      if (success && mounted) {
        widget.onLoginSuccess();
      }
    } else {
      final success = await auth.login(email, pass);
      if (success && mounted) {
        widget.onLoginSuccess();
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    final auth = context.read<AuthProvider>();
    auth.clearError();
    final success = await auth.loginWithGoogle();
    if (success && mounted) {
      widget.onLoginSuccess();
    }
  }

  void _handleDemoLogin() {
    final auth = context.read<AuthProvider>();
    auth.loginAsDemo();
    widget.onLoginSuccess();
  }

  void _showPasswordResetDialog() {
    _resetEmailController.text = _emailController.text.trim();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: CyberTheme.cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: CyberTheme.cardBorder),
        ),
        title: Row(
          children: [
            const FaIcon(FontAwesomeIcons.key, color: CyberTheme.cyan, size: 18),
            const SizedBox(width: 10),
            Text(
              'Reset Password',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: CyberTheme.white,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter your registered analyst email address to receive a secure password reset link:',
              style: GoogleFonts.inter(fontSize: 12, color: CyberTheme.slateLight),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _resetEmailController,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'name@organization.com',
                prefixIcon: const Padding(
                  padding: EdgeInsets.all(12),
                  child: FaIcon(FontAwesomeIcons.envelope, size: 14, color: CyberTheme.slateLight),
                ),
                filled: true,
                fillColor: CyberTheme.navyMid,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: CyberTheme.cardBorder),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text('Cancel', style: GoogleFonts.inter(color: CyberTheme.slateLight)),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = _resetEmailController.text.trim();
              if (email.isEmpty) return;
              Navigator.pop(dialogCtx);
              final auth = context.read<AuthProvider>();
              final sent = await auth.sendPasswordReset(email);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      sent
                          ? 'Password reset link dispatched to $email'
                          : (auth.errorMessage ?? 'Unable to send reset link'),
                    ),
                    backgroundColor: sent ? CyberTheme.success : CyberTheme.danger,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: CyberTheme.cyan, foregroundColor: CyberTheme.navyDark),
            child: const Text('Send Reset Link'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: CyberTheme.navyDark,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Cyber Logo & Shield
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: CyberTheme.cyan.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: CyberTheme.cyan.withOpacity(0.4), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: CyberTheme.cyan.withOpacity(0.25),
                        blurRadius: 24,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: FaIcon(FontAwesomeIcons.shieldHalved, color: CyberTheme.cyan, size: 28),
                  ),
                ),

                const SizedBox(height: 16),

                RichText(
                  text: TextSpan(
                    text: 'CYBER',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: CyberTheme.white,
                      letterSpacing: 1.5,
                    ),
                    children: const [
                      TextSpan(text: 'SHIELD', style: TextStyle(color: CyberTheme.cyan)),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Autonomous Threat Intelligence & Security Console',
                  style: GoogleFonts.inter(fontSize: 12, color: CyberTheme.slateLight),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                // Main Authentication Card
                CyberCard(
                  glow: true,
                  padding: const EdgeInsets.all(26),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tab Switcher (Sign In vs Register)
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: CyberTheme.navyMid,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: CyberTheme.cardBorder),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    if (_isRegister) {
                                      setState(() => _isRegister = false);
                                      auth.clearError();
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(6),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    decoration: BoxDecoration(
                                      color: !_isRegister ? CyberTheme.cyan.withOpacity(0.2) : Colors.transparent,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Sign In',
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: !_isRegister ? CyberTheme.cyan : CyberTheme.slateLight,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    if (!_isRegister) {
                                      setState(() => _isRegister = true);
                                      auth.clearError();
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(6),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    decoration: BoxDecoration(
                                      color: _isRegister ? CyberTheme.cyan.withOpacity(0.2) : Colors.transparent,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Register',
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: _isRegister ? CyberTheme.cyan : CyberTheme.slateLight,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Error Banner
                        if (auth.errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: CyberTheme.danger.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: CyberTheme.danger.withOpacity(0.4)),
                            ),
                            child: Row(
                              children: [
                                const FaIcon(FontAwesomeIcons.circleExclamation, color: CyberTheme.danger, size: 14),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    auth.errorMessage!,
                                    style: GoogleFonts.inter(fontSize: 12, color: CyberTheme.danger, fontWeight: FontWeight.w500),
                                  ),
                                ),
                                InkWell(
                                  onTap: () => auth.clearError(),
                                  child: const FaIcon(FontAwesomeIcons.xmark, size: 12, color: CyberTheme.slateLight),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Full Name (Registration only)
                        if (_isRegister) ...[
                          TextFormField(
                            controller: _nameController,
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                            decoration: const InputDecoration(
                              labelText: 'Full Name',
                              prefixIcon: Padding(
                                padding: EdgeInsets.all(12),
                                child: FaIcon(FontAwesomeIcons.user, size: 14, color: CyberTheme.slateLight),
                              ),
                            ),
                            validator: (val) {
                              if (_isRegister && (val == null || val.trim().isEmpty)) {
                                return 'Please enter your name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                        ],

                        // Email Field
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: const InputDecoration(
                            labelText: 'Analyst Email Address',
                            prefixIcon: Padding(
                              padding: EdgeInsets.all(12),
                              child: FaIcon(FontAwesomeIcons.envelope, size: 14, color: CyberTheme.slateLight),
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Please enter your email address';
                            }
                            if (!val.contains('@') || !val.contains('.')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // Password Field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Padding(
                              padding: EdgeInsets.all(12),
                              child: FaIcon(FontAwesomeIcons.lock, size: 14, color: CyberTheme.slateLight),
                            ),
                            suffixIcon: IconButton(
                              icon: FaIcon(
                                _obscurePassword ? FontAwesomeIcons.eyeSlash : FontAwesomeIcons.eye,
                                size: 14,
                                color: CyberTheme.slateLight,
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (_isRegister && val.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),

                        // Confirm Password (Registration only)
                        if (_isRegister) ...[
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                            decoration: InputDecoration(
                              labelText: 'Confirm Password',
                              prefixIcon: const Padding(
                                padding: EdgeInsets.all(12),
                                child: FaIcon(FontAwesomeIcons.shieldHalved, size: 14, color: CyberTheme.slateLight),
                              ),
                              suffixIcon: IconButton(
                                icon: FaIcon(
                                  _obscureConfirmPassword ? FontAwesomeIcons.eyeSlash : FontAwesomeIcons.eye,
                                  size: 14,
                                  color: CyberTheme.slateLight,
                                ),
                                onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                              ),
                            ),
                            validator: (val) {
                              if (_isRegister && val != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                        ],

                        // Forgot Password Link
                        if (!_isRegister) ...[
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _showPasswordResetDialog,
                              child: Text(
                                'Forgot Password?',
                                style: GoogleFonts.inter(fontSize: 11, color: CyberTheme.cyan),
                              ),
                            ),
                          ),
                        ] else ...[
                          const SizedBox(height: 16),
                        ],

                        // Main Submit Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: auth.isLoading ? null : _handleSubmit,
                            child: auth.isLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: CyberTheme.navyDark),
                                  )
                                : Text(_isRegister ? 'Register Account' : 'Sign In with Firebase'),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Divider with text
                        Row(
                          children: [
                            const Expanded(child: Divider(color: CyberTheme.cardBorder)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                'OR',
                                style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: CyberTheme.slateLight),
                              ),
                            ),
                            const Expanded(child: Divider(color: CyberTheme.cardBorder)),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Google Sign-In Button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: auth.isLoading ? null : _handleGoogleSignIn,
                            icon: const FaIcon(FontAwesomeIcons.google, size: 14, color: Color(0xFFEA4335)),
                            label: const Text('Sign in with Google Firebase'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: CyberTheme.white,
                              side: const BorderSide(color: CyberTheme.cardBorder),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Instant Demo Access Button
                        SizedBox(
                          width: double.infinity,
                          child: TextButton.icon(
                            onPressed: _handleDemoLogin,
                            icon: const FaIcon(FontAwesomeIcons.bolt, size: 12, color: CyberTheme.cyan),
                            label: const Text('Instant Demo Sandbox Access'),
                            style: TextButton.styleFrom(
                              foregroundColor: CyberTheme.cyan,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
