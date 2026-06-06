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
        'Dog' => const Color(0xFFFFF7ED),
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
                      decoration: BoxDecoration(
                          color: const Color(0xFFFFF1F2),
                          shape: BoxShape.circle),
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

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5F0EA))),
                child: Column(children: [
                  // Image area
                  Container(
                    height: 100,
                    decoration: BoxDecoration(
                        color: bg,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16))),
                    child: Stack(children: [
                      Center(
                          child: Icon(_typeIcon(type),
                              size: 52, color: color.withValues(alpha: 0.8))),
                      // Vaccinated badge
                      if (post['vaccinated'] == true)
                        Positioned(
                          bottom: 8,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                                color: _green,
                                borderRadius: BorderRadius.circular(20)),
                            child: Text('Vaccinated',
                                style: GoogleFonts.nunito(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white)),
                          ),
                        ),
                      // Unsave button
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () async {
                            await SavedPostsService.unsavePost(
                                post['name'] as String);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text(
                                    '${post['name']} removed from saved',
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
                          child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.08),
                                        blurRadius: 4)
                                  ]),
                              child: const Icon(Icons.favorite_rounded,
                                  size: 16, color: Color(0xFFE11D48))),
                        ),
                      ),
                    ]),
                  ),

                  // Info
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(post['name'] as String? ?? '',
                                  style: GoogleFonts.nunito(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: _textMain)),
                              Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                      color: bg,
                                      borderRadius: BorderRadius.circular(20)),
                                  child: Text(
                                      (post['gender'] as String?) == 'Male'
                                          ? '♂ Male'
                                          : '♀ Female',
                                      style: GoogleFonts.nunito(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: color))),
                            ]),
                        const SizedBox(height: 4),
                        Text(
                            '${post['breed'] ?? ''} · ${post['age'] ?? ''} · ${post['location'] ?? ''}',
                            style: GoogleFonts.nunito(
                                fontSize: 12, color: _textMuted)),
                        const SizedBox(height: 8),
                        Text(post['description'] as String? ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.nunito(
                                fontSize: 12, color: _textMuted, height: 1.5)),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _green,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.favorite_rounded, size: 16),
                            label: Text('Adopt ${post['name']}',
                                style: GoogleFonts.nunito(
                                    fontSize: 13, fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
              );
            },
          );
        },
      ),
    );
  }
}
