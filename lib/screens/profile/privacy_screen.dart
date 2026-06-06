import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  static const _green = Color(0xFF1D9E75);
  static const _greenLight = Color(0xFFE1F5EE);
  static const _textMain = Color(0xFF0A2E24);
  static const _textMuted = Color(0xFF6B8F80);

  User? get _user => FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final user = _user;
    return Scaffold(
      backgroundColor: const Color(0xFFF4FAF7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Privacy & Security',
            style: GoogleFonts.nunito(
                fontSize: 18, fontWeight: FontWeight.w800, color: _textMain)),
        leading: IconButton(
            icon:
                const Icon(Icons.arrow_back_rounded, color: Color(0xFF0A2E24)),
            onPressed: () => Navigator.pop(context)),
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: const Color(0xFFE5F0EA))),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Account info card
            _card(
              icon: Icons.person_outline_rounded,
              iconColor: _green,
              iconBg: _greenLight,
              title: 'Account information',
              children: [
                _dataRow(
                    'Full name',
                    user?.displayName?.isEmpty == true ||
                            user?.displayName == null
                        ? 'Not set'
                        : user!.displayName!),
                _dataRow('Email address', user?.email ?? 'Not available'),
                _dataRow('User ID', user?.uid ?? 'Not available',
                    isMonospace: true),
                _dataRow(
                    'Account created',
                    user?.metadata.creationTime != null
                        ? _formatDate(user!.metadata.creationTime!)
                        : 'Not available'),
                _dataRow(
                    'Last sign in',
                    user?.metadata.lastSignInTime != null
                        ? _formatDate(user!.metadata.lastSignInTime!)
                        : 'Not available'),
                _dataRow('Email verified',
                    user?.emailVerified == true ? '✅ Yes' : '❌ No'),
              ],
            ),

            const SizedBox(height: 14),

            // Security card
            _card(
              icon: Icons.security_rounded,
              iconColor: const Color(0xFF0891B2),
              iconBg: const Color(0xFFE0F7FA),
              title: 'Security',
              children: [
                _actionRow(
                  icon: Icons.lock_reset_rounded,
                  label: 'Change password',
                  subtitle: 'Send password reset email',
                  color: const Color(0xFF0891B2),
                  onTap: () async {
                    if (user?.email != null) {
                      await FirebaseAuth.instance
                          .sendPasswordResetEmail(email: user!.email!);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              'Password reset email sent to ${user.email}',
                              style: GoogleFonts.nunito(
                                  fontWeight: FontWeight.w600)),
                          backgroundColor: _green,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          margin: const EdgeInsets.all(16),
                        ));
                      }
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Data policy card
            _card(
              icon: Icons.policy_outlined,
              iconColor: const Color(0xFF8B5CF6),
              iconBg: const Color(0xFFF3EFFE),
              title: 'Data & privacy',
              children: [
                _dataRow('Data storage', 'Firebase Firestore (Google)'),
                _dataRow('Authentication', 'Firebase Auth (Google)'),
                _dataRow('AI processing', 'Gemini API — no data stored'),
                _dataRow('Data retention', 'Until account deletion'),
              ],
            ),

            const SizedBox(height: 14),

            // Danger zone
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFCA5A5))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.warning_amber_rounded,
                            size: 18, color: Color(0xFFDC2626))),
                    const SizedBox(width: 10),
                    Text('Danger zone',
                        style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFDC2626))),
                  ]),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _confirmDeleteAccount(context),
                      style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFDC2626),
                          side: const BorderSide(color: Color(0xFFDC2626)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                      icon: const Icon(Icons.delete_forever_rounded, size: 18),
                      label: Text('Delete my account',
                          style: GoogleFonts.nunito(
                              fontSize: 13, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _card({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5F0EA))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                    color: iconBg, borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, size: 18, color: iconColor)),
            const SizedBox(width: 10),
            Text(title,
                style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _textMain)),
          ]),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _dataRow(String label, String value, {bool isMonospace = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 130,
              child: Text(label,
                  style: GoogleFonts.nunito(fontSize: 12, color: _textMuted))),
          Expanded(
            child: Text(value,
                style: isMonospace
                    ? const TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                        color: Color(0xFF374151))
                    : GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _textMain)),
          ),
        ],
      ),
    );
  }

  Widget _actionRow({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10)),
        child: Row(children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _textMain)),
                Text(subtitle,
                    style: GoogleFonts.nunito(fontSize: 11, color: _textMuted)),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded,
              size: 14, color: color.withValues(alpha: 0.5)),
        ]),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  void _confirmDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete account?',
            style: GoogleFonts.nunito(
                fontWeight: FontWeight.w800, color: const Color(0xFFDC2626))),
        content: Text(
            'All your data including pets, history will be permanently deleted. This cannot be undone.',
            style: GoogleFonts.nunito(color: _textMuted)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel',
                  style: GoogleFonts.nunito(
                      color: _textMuted, fontWeight: FontWeight.w600))),
          ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.currentUser?.delete();
                if (context.mounted) {
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil('/login', (_) => false);
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              child: Text('Delete',
                  style: GoogleFonts.nunito(fontWeight: FontWeight.w700))),
        ],
      ),
    );
  }
}
