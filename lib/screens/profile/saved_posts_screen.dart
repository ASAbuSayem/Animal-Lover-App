import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/saved_posts_service.dart';

class SavedPostsScreen extends StatelessWidget {
  const SavedPostsScreen({super.key});

  static const _green = Color(0xFF1D9E75);
  static const _greenLight = Color(0xFFE1F5EE);
  static const _textMain = Color(0xFF0A2E24);
  static const _textMuted = Color(0xFF6B8F80);

  Color _typeColor(String type) => switch (type) {
        'Dog' => const Color(0xFFEA580C),
        'Cat' => const Color(0xFF8B5CF6),
        'Bird' => const Color(0xFF0891B2),
        'Rabbit' => const Color(0xFF16A34A),
        _ => _green,
      };

  Color _typeBg(String type) => switch (type) {
        'Dog' => const Color(0xFFFFF0E6),
        'Cat' => const Color(0xFFF3EFFE),
        'Bird' => const Color(0xFFE0F7FA),
        'Rabbit' => const Color(0xFFDCFCE7),
        _ => _greenLight,
      };

  IconData _typeIcon(String type) => switch (type) {
        'Cat' => Icons.catching_pokemon_rounded,
        'Bird' => Icons.flutter_dash_rounded,
        'Rabbit' => Icons.cruelty_free_rounded,
        _ => Icons.pets_rounded,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FAF7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Saved posts',
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
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: SavedPostsService.savedPostsStream(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: _green));
          }

          final posts = snap.data ?? [];

          if (posts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                          color: Color(0xFFFFF1F2), shape: BoxShape.circle),
                      child: const Icon(Icons.favorite_border_rounded,
                          size: 40, color: Color(0xFFE11D48))),
                  const SizedBox(height: 16),
                  Text('No saved posts',
                      style: GoogleFonts.nunito(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: _textMain)),
                  const SizedBox(height: 6),
                  Text('Go to Adopt tab and tap ♡ to save pets',
                      textAlign: TextAlign.center,
                      style:
                          GoogleFonts.nunito(fontSize: 13, color: _textMuted)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            physics: const BouncingScrollPhysics(),
            itemCount: posts.length,
            itemBuilder: (_, i) {
              final post = posts[i];
              final type = post['type'] as String? ?? 'Dog';
              final color = _typeColor(type);
              final bg = _typeBg(type);

              return GestureDetector(
                onTap: () => _showDetail(context, post),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE5F0EA))),
                  child: Row(children: [
                    // Image area
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                          color: bg,
                          borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(16))),
                      child: Stack(children: [
                        Center(
                            child: Icon(_typeIcon(type),
                                size: 44, color: color.withValues(alpha: 0.8))),
                        if (post['vaccinated'] == true)
                          Positioned(
                            bottom: 4,
                            left: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                  color: _green,
                                  borderRadius: BorderRadius.circular(20)),
                              child: Text('✓',
                                  style: GoogleFonts.nunito(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white)),
                            ),
                          ),
                      ]),
                    ),

                    // Info
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                      child: Text(post['name'] as String? ?? '',
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.nunito(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w800,
                                              color: _textMain))),
                                  Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                          color: bg,
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: Text(
                                          (post['gender'] as String?) == 'Male'
                                              ? '♂'
                                              : '♀',
                                          style: TextStyle(
                                              fontSize: 12, color: color))),
                                ]),
                            const SizedBox(height: 3),
                            Text(
                                '${post['breed'] ?? post['type'] ?? ''} · ${post['age'] ?? ''}',
                                style: GoogleFonts.nunito(
                                    fontSize: 11, color: _textMuted)),
                            const SizedBox(height: 3),
                            Row(children: [
                              const Icon(Icons.location_on_outlined,
                                  size: 12, color: Color(0xFF9CA3AF)),
                              const SizedBox(width: 3),
                              Text(post['location'] as String? ?? '',
                                  style: GoogleFonts.nunito(
                                      fontSize: 11, color: _textMuted)),
                            ]),
                          ],
                        ),
                      ),
                    ),

                    // Unsave button
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () async {
                          await SavedPostsService.unsavePost(
                              post['name'] as String);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('${post['name']} removed',
                                  style: GoogleFonts.nunito(
                                      fontWeight: FontWeight.w600)),
                              backgroundColor: const Color(0xFFE11D48),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              margin: const EdgeInsets.all(16),
                            ));
                          }
                        },
                        child: const Icon(Icons.favorite_rounded,
                            size: 22, color: Color(0xFFE11D48)),
                      ),
                    ),

                    const Icon(Icons.chevron_right_rounded,
                        size: 20, color: Color(0xFFB0C4BC)),
                    const SizedBox(width: 8),
                  ]),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ── Detail bottom sheet ──────────────────────
  void _showDetail(BuildContext context, Map<String, dynamic> post) {
    final type = post['type'] as String? ?? 'Dog';
    final color = _typeColor(type);
    final bg = _typeBg(type);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, ctrl) => Container(
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: ListView(
            controller: ctrl,
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                  child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: const Color(0xFFE5E7EB),
                          borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),

              // Image
              Container(
                height: 140,
                decoration: BoxDecoration(
                    color: bg, borderRadius: BorderRadius.circular(16)),
                child: Center(
                    child: Icon(_typeIcon(type), size: 72, color: color)),
              ),
              const SizedBox(height: 20),

              // Name + badges
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Expanded(
                    child: Text(post['name'] as String? ?? '',
                        style: GoogleFonts.nunito(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: _textMain))),
                Row(children: [
                  if (post['vaccinated'] == true)
                    _badge('Vaccinated', _green, _greenLight),
                  if (post['neutered'] == true) ...[
                    const SizedBox(width: 6),
                    _badge('Neutered', const Color(0xFF0891B2),
                        const Color(0xFFE0F7FA)),
                  ],
                ]),
              ]),
              const SizedBox(height: 6),

              Text(
                  '${post['breed'] ?? type} · ${post['age'] ?? ''} · ${post['gender'] ?? ''}',
                  style: GoogleFonts.nunito(fontSize: 14, color: _textMuted)),
              const SizedBox(height: 4),

              Row(children: [
                const Icon(Icons.location_on_outlined,
                    size: 14, color: Color(0xFF9CA3AF)),
                const SizedBox(width: 4),
                Text(post['location'] as String? ?? '',
                    style: GoogleFonts.nunito(fontSize: 13, color: _textMuted)),
              ]),
              const SizedBox(height: 16),

              // Description
              if ((post['description'] as String?)?.isNotEmpty == true) ...[
                Text('About',
                    style: GoogleFonts.nunito(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _textMain)),
                const SizedBox(height: 8),
                Text(post['description'] as String,
                    style: GoogleFonts.nunito(
                        fontSize: 14, color: _textMuted, height: 1.6)),
                const SizedBox(height: 16),
              ],

              // Contact
              if ((post['contact'] as String?)?.isNotEmpty == true) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      color: _greenLight,
                      borderRadius: BorderRadius.circular(12)),
                  child: Row(children: [
                    const Icon(Icons.phone_outlined, size: 18, color: _green),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Contact',
                              style: GoogleFonts.nunito(
                                  fontSize: 11, color: _textMuted)),
                          Text(post['contact'] as String,
                              style: GoogleFonts.nunito(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: _textMain)),
                        ],
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 16),
              ],

              // Adopt button
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                          'Adoption request sent for ${post['name']}! 🐾',
                          style:
                              GoogleFonts.nunito(fontWeight: FontWeight.w600)),
                      backgroundColor: _green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      margin: const EdgeInsets.all(16),
                    ));
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: _green,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14))),
                  icon: const Icon(Icons.favorite_rounded, size: 18),
                  label: Text('Send adoption request',
                      style: GoogleFonts.nunito(
                          fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ),

              // Remove from saved
              const SizedBox(height: 12),
              SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    Navigator.pop(context);
                    await SavedPostsService.unsavePost(post['name'] as String);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('${post['name']} removed from saved',
                            style: GoogleFonts.nunito(
                                fontWeight: FontWeight.w600)),
                        backgroundColor: const Color(0xFFE11D48),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        margin: const EdgeInsets.all(16),
                      ));
                    }
                  },
                  style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFE11D48),
                      side: const BorderSide(color: Color(0xFFE11D48)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14))),
                  icon: const Icon(Icons.favorite_border_rounded, size: 18),
                  label: Text('Remove from saved',
                      style: GoogleFonts.nunito(
                          fontSize: 14, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _badge(String label, Color fg, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: GoogleFonts.nunito(
              fontSize: 11, fontWeight: FontWeight.w700, color: fg)),
    );
  }
}
