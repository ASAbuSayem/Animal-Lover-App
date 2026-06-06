import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/pet_service.dart';
import '../../services/ai_session_service.dart';
import '../../services/saved_posts_service.dart';
import '../../services/adoption_request_service.dart';
import '../pet/my_pets_screen.dart';
import '../adopt/adoption_requests_screen.dart';
import 'notifications_screen.dart';
import 'privacy_screen.dart';
import 'saved_posts_screen.dart';
import 'ai_history_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const _green = Color(0xFF1D9E75);
  static const _greenLight = Color(0xFFE1F5EE);
  static const _greenMid = Color(0xFF9FE1CB);
  static const _bgPage = Color(0xFFF4FAF7);
  static const _textMain = Color(0xFF0A2E24);
  static const _textMuted = Color(0xFF6B8F80);

  User? get _user => FirebaseAuth.instance.currentUser;

  String get _displayName {
    if (_user?.displayName != null && _user!.displayName!.isNotEmpty) {
      return _user!.displayName!;
    }
    return 'Pet Lover';
  }

  String get _email => _user?.email ?? 'Not signed in';

  String get _initials {
    final name = _displayName;
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'P';
  }

  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Sign out',
            style: GoogleFonts.nunito(
                fontWeight: FontWeight.w800, color: _textMain)),
        content: Text('Are you sure you want to sign out?',
            style: GoogleFonts.nunito(color: _textMuted)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel',
                  style: GoogleFonts.nunito(
                      color: _textMuted, fontWeight: FontWeight.w600))),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              child: Text('Sign out',
                  style: GoogleFonts.nunito(fontWeight: FontWeight.w700))),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await FirebaseAuth.instance.signOut();
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgPage,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(children: [
            _buildProfileHeader(),
            const SizedBox(height: 20),
            _buildStatsRow(),
            const SizedBox(height: 20),
            _buildMenuSection(),
            const SizedBox(height: 16),
            _buildAboutSection(),
            const SizedBox(height: 24),
          ]),
        ),
      ),
    );
  }

  // ── Profile header ──────────────────────────
  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFF1D9E75), Color(0xFF0D7A58)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(20)),
      child: Column(children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              shape: BoxShape.circle,
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.5), width: 2)),
          child: Center(
              child: Text(_initials,
                  style: GoogleFonts.nunito(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white))),
        ),
        const SizedBox(height: 14),
        Text(_displayName,
            style: GoogleFonts.nunito(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white)),
        const SizedBox(height: 4),
        Text(_email,
            style: GoogleFonts.nunito(
                fontSize: 13, color: Colors.white.withValues(alpha: 0.8))),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.white.withValues(alpha: 0.5)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8)),
          icon: const Icon(Icons.edit_outlined, size: 16),
          label: Text('Edit profile',
              style: GoogleFonts.nunito(
                  fontSize: 13, fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }

  // ── Stats — all real Firestore data ─────────
  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(children: [
        StreamBuilder<List<Pet>>(
          stream: PetService.petsStream(),
          builder: (_, snap) => Expanded(
              child: _statCard('${snap.data?.length ?? 0}', 'My Pets',
                  Icons.pets_rounded, _green, _greenLight)),
        ),
        const SizedBox(width: 12),
        StreamBuilder<int>(
          stream: SavedPostsService.savedCountStream(),
          builder: (_, snap) => Expanded(
              child: _statCard(
                  '${snap.data ?? 0}',
                  'Saved Posts',
                  Icons.favorite_rounded,
                  const Color(0xFFE11D48),
                  const Color(0xFFFFF1F2))),
        ),
        const SizedBox(width: 12),
        StreamBuilder<int>(
          stream: AiSessionService.sessionCountStream(),
          builder: (_, snap) => Expanded(
              child: _statCard(
                  '${snap.data ?? 0}',
                  'AI Sessions',
                  Icons.smart_toy_rounded,
                  const Color(0xFF8B5CF6),
                  const Color(0xFFF3EFFE))),
        ),
      ]),
    );
  }

  Widget _statCard(
      String val, String label, IconData icon, Color fg, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5F0EA))),
      child: Column(children: [
        Icon(icon, size: 22, color: fg),
        const SizedBox(height: 8),
        Text(val,
            style: GoogleFonts.nunito(
                fontSize: 20, fontWeight: FontWeight.w800, color: fg)),
        Text(label,
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(fontSize: 11, color: _textMuted)),
      ]),
    );
  }

  // ── Menu — all functional ───────────────────
  Widget _buildMenuSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5F0EA))),
        child: Column(children: [
          // My pets
          _menuItem(Icons.pets_rounded, 'My pets',
              'View & manage your pet profiles', _green, _greenLight,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const MyPetsScreen()))),
          _divider(),

          // Adoption requests — with live badge
          StreamBuilder<int>(
            stream: AdoptionRequestService.pendingCountStream(),
            builder: (_, snap) {
              final count = snap.data ?? 0;
              return _menuItemWithBadge(
                  Icons.favorite_border_rounded,
                  'Adoption requests',
                  'Incoming requests for your pets',
                  const Color(0xFFEA580C),
                  const Color(0xFFFFF0E6),
                  badge: count > 0 ? '$count' : null,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AdoptionRequestsScreen())));
            },
          ),
          _divider(),

          // AI history
          _menuItem(
              Icons.history_rounded,
              'AI history',
              'Past symptom checks & care plans',
              const Color(0xFF8B5CF6),
              const Color(0xFFF3EFFE),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AiHistoryScreen()))),
          _divider(),

          // Saved posts
          _menuItem(
              Icons.favorite_rounded,
              'Saved posts',
              'Bookmarked adoption posts',
              const Color(0xFFE11D48),
              const Color(0xFFFFF1F2),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SavedPostsScreen()))),
          _divider(),

          // Notifications
          _menuItem(
              Icons.notifications_outlined,
              'Notifications',
              'Vaccine & meal reminders',
              const Color(0xFFD97706),
              const Color(0xFFFEF3C7),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const NotificationsScreen()))),
          _divider(),

          // Privacy & Security
          _menuItem(
              Icons.privacy_tip_outlined,
              'Privacy & Security',
              'Account settings & your data',
              const Color(0xFF0891B2),
              const Color(0xFFE0F7FA),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const PrivacyScreen()))),
          _divider(),

          // Sign out
          _menuItem(Icons.logout_rounded, 'Sign out', 'Log out of your account',
              const Color(0xFFDC2626), const Color(0xFFFEF2F2),
              onTap: _signOut, isDestructive: true),
        ]),
      ),
    );
  }

  Widget _menuItem(
      IconData icon, String title, String subtitle, Color fg, Color bg,
      {required VoidCallback onTap, bool isDestructive = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(children: [
          Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: bg, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, size: 20, color: fg)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDestructive
                            ? const Color(0xFFDC2626)
                            : _textMain)),
                Text(subtitle,
                    style: GoogleFonts.nunito(fontSize: 11, color: _textMuted)),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded,
              size: 20,
              color: isDestructive
                  ? const Color(0xFFDC2626).withValues(alpha: 0.5)
                  : const Color(0xFFB0C4BC)),
        ]),
      ),
    );
  }

  // Menu item with notification badge
  Widget _menuItemWithBadge(
      IconData icon, String title, String subtitle, Color fg, Color bg,
      {required VoidCallback onTap, String? badge}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(children: [
          Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: bg, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, size: 20, color: fg)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _textMain)),
                Text(subtitle,
                    style: GoogleFonts.nunito(fontSize: 11, color: _textMuted)),
              ],
            ),
          ),
          if (badge != null)
            Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: const Color(0xFFEA580C),
                    borderRadius: BorderRadius.circular(20)),
                child: Text(badge,
                    style: GoogleFonts.nunito(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)))
          else
            const Icon(Icons.chevron_right_rounded,
                size: 20, color: Color(0xFFB0C4BC)),
        ]),
      ),
    );
  }

  Widget _divider() => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(height: 0.5, color: const Color(0xFFE5F0EA)));

  // ── About us ────────────────────────────────
  Widget _buildAboutSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5F0EA))),
        child: Column(children: [
          Image.asset('assets/images/animal_lover_logo.png',
              width: 80, height: 80, fit: BoxFit.contain),
          const SizedBox(height: 12),
          Text('Animal Lover',
              style: GoogleFonts.nunito(
                  fontSize: 18, fontWeight: FontWeight.w800, color: _textMain)),
          Text('AI-Powered Pet Care App',
              style: GoogleFonts.nunito(fontSize: 12, color: _textMuted)),
          const SizedBox(height: 4),
          Text('Version 1.0.0',
              style: GoogleFonts.nunito(
                  fontSize: 11, color: _textMuted.withValues(alpha: 0.6))),
          const SizedBox(height: 20),
          Container(height: 0.5, color: const Color(0xFFE5F0EA)),
          const SizedBox(height: 20),
          Text('Developed by',
              style: GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _textMuted)),
          const SizedBox(height: 14),
          _developerCard(
              initials: 'MS',
              name: 'Md. Abu Sayem',
              role: 'Lead Developer & Researcher',
              color: _green,
              bg: _greenLight),
          const SizedBox(height: 10),
          _developerCard(
              initials: 'RS',
              name: 'Redwan Sharafat Kabir',
              role: 'Co-Developer & Researcher',
              color: const Color(0xFF8B5CF6),
              bg: const Color(0xFFF3EFFE)),
          const SizedBox(height: 20),
          Container(height: 0.5, color: const Color(0xFFE5F0EA)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: _greenLight, borderRadius: BorderRadius.circular(12)),
            child: Column(children: [
              const Text('🐾', style: TextStyle(fontSize: 22)),
              const SizedBox(height: 8),
              Text(
                  '"Every pet deserves love, care, and a happy home. '
                  'We hope Animal Lover helps you give your furry '
                  'friend the best life possible."',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                      fontSize: 13,
                      color: const Color(0xFF2D6E56),
                      fontStyle: FontStyle.italic,
                      height: 1.6)),
              const SizedBox(height: 10),
              Text(
                  '— With love, Team Animal Lover - Fooggle\n'
                  'Dedicated to Sara Chowdhury 💚',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _green)),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _developerCard({
    required String initials,
    required String name,
    required String role,
    required Color color,
    required Color bg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.3))),
          child: Center(
              child: Text(initials,
                  style: GoogleFonts.nunito(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: color))),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: _textMain)),
              Text(role,
                  style: GoogleFonts.nunito(fontSize: 11, color: _textMuted)),
            ],
          ),
        ),
        Icon(Icons.code_rounded, size: 16, color: color),
      ]),
    );
  }
}
