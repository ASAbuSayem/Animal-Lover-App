import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/adoption_post_service.dart';
import '../../services/saved_posts_service.dart';
import '../../services/adoption_request_service.dart';
import 'create_adoption_post_screen.dart';
import 'adoption_requests_screen.dart';

class AdoptionScreen extends StatefulWidget {
  const AdoptionScreen({super.key});
  @override
  State<AdoptionScreen> createState() => _AdoptionScreenState();
}

class _AdoptionScreenState extends State<AdoptionScreen>
    with SingleTickerProviderStateMixin {
  String _selectedFilter = 'All';
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();
  final Set<String> _savedIds = {};

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  static const _green = Color(0xFF1D9E75);
  static const _greenLight = Color(0xFFE1F5EE);
  static const _bgPage = Color(0xFFF4FAF7);
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
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
    _loadSavedStatus();
  }

  // Load saved status from Firestore
  Future<void> _loadSavedStatus() async {
    try {
      final posts = await SavedPostsService.savedPostsStream().first;
      if (mounted) {
        setState(() {
          for (final p in posts) {
            _savedIds.add(p['name'] as String);
          }
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _toggleSave(AdoptionPost post) async {
    final isSaved = _savedIds.contains(post.id);
    setState(() {
      if (isSaved)
        _savedIds.remove(post.id);
      else
        _savedIds.add(post.id);
    });
    try {
      if (!isSaved) {
        await SavedPostsService.savePost({
          'name': post.name,
          'type': post.type,
          'breed': post.breed,
          'age': post.age,
          'gender': post.gender,
          'location': post.location,
          'description': post.description,
          'vaccinated': post.vaccinated,
          'neutered': post.neutered,
          'contact': post.contact,
        });
        if (mounted) _snack('${post.name} saved! 🐾', _green);
      } else {
        await SavedPostsService.unsavePost(post.name);
        if (mounted)
          _snack('${post.name} removed from saved', const Color(0xFFE11D48));
      }
    } catch (_) {
      if (mounted)
        setState(() {
          if (isSaved)
            _savedIds.add(post.id);
          else
            _savedIds.remove(post.id);
        });
    }
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content:
          Text(msg, style: GoogleFonts.nunito(fontWeight: FontWeight.w600)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgPage,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SafeArea(
          child: Column(children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildFilterChips(),
            Expanded(child: _buildPostList()),
          ]),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const CreateAdoptionPostScreen())),
        backgroundColor: _green,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('Post pet',
            style: GoogleFonts.nunito(
                color: Colors.white, fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Adopt a pet',
                style: GoogleFonts.nunito(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: _textMain)),
            Text('Find your perfect companion',
                style: GoogleFonts.nunito(fontSize: 13, color: _textMuted)),
          ]),
          // Pending requests badge
          StreamBuilder<int>(
            stream: AdoptionRequestService.pendingCountStream(),
            builder: (_, snap) {
              final count = snap.data ?? 0;
              return GestureDetector(
                onTap: count > 0
                    ? () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AdoptionRequestsScreen()))
                    : null,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                      color: count > 0 ? const Color(0xFFFFF0E6) : _greenLight,
                      borderRadius: BorderRadius.circular(20)),
                  child: Row(children: [
                    Icon(
                        count > 0
                            ? Icons.notifications_active_rounded
                            : Icons.public_rounded,
                        size: 14,
                        color: count > 0 ? const Color(0xFFEA580C) : _green),
                    const SizedBox(width: 4),
                    Text(
                        count > 0
                            ? '$count request${count > 1 ? 's' : ''}'
                            : 'Public',
                        style: GoogleFonts.nunito(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color:
                                count > 0 ? const Color(0xFFEA580C) : _green)),
                  ]),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (v) => setState(() => _searchQuery = v),
        style: GoogleFonts.nunito(fontSize: 14, color: _textMain),
        decoration: InputDecoration(
          hintText: 'Search by name, breed, location...',
          hintStyle:
              TextStyle(color: _textMuted.withValues(alpha: 0.6), fontSize: 13),
          prefixIcon: const Icon(Icons.search_rounded,
              size: 20, color: Color(0xFF9CA3AF)),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded,
                      size: 18, color: Color(0xFF9CA3AF)),
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() => _searchQuery = '');
                  })
              : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE5F0EA))),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE5F0EA))),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _green, width: 1.5)),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'Dog', 'Cat', 'Rabbit', 'Bird', 'Other'];
    return SizedBox(
      height: 52,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
        itemCount: filters.length,
        itemBuilder: (_, i) {
          final selected = _selectedFilter == filters[i];
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = filters[i]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                  color: selected ? _green : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: selected ? _green : const Color(0xFFE5F0EA))),
              child: Text(filters[i],
                  style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: selected ? Colors.white : _textMuted)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPostList() {
    return StreamBuilder<List<AdoptionPost>>(
      stream: AdoptionPostService.postsStream(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: _green));
        }

        var posts = snap.data ?? [];
        if (_selectedFilter != 'All') {
          posts = posts.where((p) => p.type == _selectedFilter).toList();
        }
        if (_searchQuery.isNotEmpty) {
          final q = _searchQuery.toLowerCase();
          posts = posts
              .where((p) =>
                  p.name.toLowerCase().contains(q) ||
                  p.breed.toLowerCase().contains(q) ||
                  p.location.toLowerCase().contains(q))
              .toList();
        }

        if (posts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                    snap.data?.isEmpty == true
                        ? Icons.pets_rounded
                        : Icons.search_off_rounded,
                    size: 56,
                    color: _textMuted.withValues(alpha: 0.4)),
                const SizedBox(height: 12),
                Text(
                    snap.data?.isEmpty == true
                        ? 'No adoption posts yet'
                        : 'No pets found',
                    style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _textMuted)),
                Text(
                    snap.data?.isEmpty == true
                        ? 'Be the first to post a pet!'
                        : 'Try a different filter',
                    style: GoogleFonts.nunito(fontSize: 13, color: _textMuted)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 100),
          physics: const BouncingScrollPhysics(),
          itemCount: (posts.length / 2).ceil(),
          itemBuilder: (_, rowIndex) {
            final left = rowIndex * 2;
            final right = left + 1;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildPostCard(posts[left])),
                  const SizedBox(width: 12),
                  right < posts.length
                      ? Expanded(child: _buildPostCard(posts[right]))
                      : const Expanded(child: SizedBox()),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPostCard(AdoptionPost post) {
    final color = _typeColor(post.type);
    final bg = _typeBg(post.type);
    final isSaved = _savedIds.contains(post.id);
    final isOwner = FirebaseAuth.instance.currentUser?.uid == post.postedBy;

    return GestureDetector(
      onTap: () => _showPostDetail(context, post),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5F0EA))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area
            Container(
              height: 120,
              decoration: BoxDecoration(
                  color: bg,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16))),
              child: Stack(children: [
                Center(
                    child: Icon(_typeIcon(post.type),
                        size: 56, color: color.withValues(alpha: 0.8))),

                // Save button — only for non-owners
                if (!isOwner)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => _toggleSave(post),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 4)
                            ]),
                        child: Icon(
                            isSaved
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            size: 15,
                            color:
                                isSaved ? const Color(0xFFE11D48) : _textMuted),
                      ),
                    ),
                  ),

                // Vaccinated badge
                if (post.vaccinated)
                  Positioned(
                    bottom: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                          color: _green,
                          borderRadius: BorderRadius.circular(20)),
                      child: Text('Vaccinated',
                          style: GoogleFonts.nunito(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                    ),
                  ),

                // My post badge
                if (isOwner)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                          color: const Color(0xFF8B5CF6),
                          borderRadius: BorderRadius.circular(20)),
                      child: Text('My post',
                          style: GoogleFonts.nunito(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                    ),
                  ),
              ]),
            ),

            // Info
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: Text(post.name,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.nunito(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: _textMain))),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                            color: bg, borderRadius: BorderRadius.circular(20)),
                        child: Text(post.gender == 'Male' ? '♂' : '♀',
                            style: TextStyle(fontSize: 11, color: color)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(post.breed.isEmpty ? post.type : post.breed,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.nunito(
                          fontSize: 10.5, color: _textMuted)),
                  const SizedBox(height: 5),
                  Row(children: [
                    const Icon(Icons.access_time_rounded,
                        size: 11, color: Color(0xFF9CA3AF)),
                    const SizedBox(width: 2),
                    Text(post.age,
                        style: GoogleFonts.nunito(
                            fontSize: 10, color: _textMuted)),
                    const SizedBox(width: 6),
                    const Icon(Icons.location_on_outlined,
                        size: 11, color: Color(0xFF9CA3AF)),
                    const SizedBox(width: 2),
                    Expanded(
                        child: Text(post.location,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.nunito(
                                fontSize: 10, color: _textMuted))),
                  ]),
                  const SizedBox(height: 10),

                  // ── Owner: "View requests" | Others: "Adopt" ──
                  if (isOwner)
                    SizedBox(
                      width: double.infinity,
                      height: 34,
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const AdoptionRequestsScreen())),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF8B5CF6),
                          side: const BorderSide(color: Color(0xFF8B5CF6)),
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.inbox_outlined, size: 14),
                        label: Text('View requests',
                            style: GoogleFonts.nunito(
                                fontSize: 11, fontWeight: FontWeight.w700)),
                      ),
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      height: 34,
                      child: ElevatedButton(
                        onPressed: () => _showPostDetail(context, post),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _green,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text('Adopt',
                            style: GoogleFonts.nunito(
                                fontSize: 12, fontWeight: FontWeight.w700)),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPostDetail(BuildContext context, AdoptionPost post) {
    final color = _typeColor(post.type);
    final bg = _typeBg(post.type);
    final isSaved = _savedIds.contains(post.id);
    final isOwner = FirebaseAuth.instance.currentUser?.uid == post.postedBy;

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

              Container(
                height: 140,
                decoration: BoxDecoration(
                    color: bg, borderRadius: BorderRadius.circular(16)),
                child: Center(
                    child: Icon(_typeIcon(post.type), size: 72, color: color)),
              ),
              const SizedBox(height: 20),

              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Expanded(
                    child: Text(post.name,
                        style: GoogleFonts.nunito(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0A2E24)))),
                Row(children: [
                  if (post.vaccinated)
                    _badge('Vaccinated', _green, _greenLight),
                  if (post.neutered) ...[
                    const SizedBox(width: 6),
                    _badge('Neutered', const Color(0xFF0891B2),
                        const Color(0xFFE0F7FA)),
                  ],
                ]),
              ]),
              const SizedBox(height: 6),
              Text(
                  '${post.breed.isEmpty ? post.type : post.breed} · ${post.age} · ${post.gender}',
                  style: GoogleFonts.nunito(fontSize: 14, color: _textMuted)),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.location_on_outlined,
                    size: 14, color: Color(0xFF9CA3AF)),
                const SizedBox(width: 4),
                Text(post.location,
                    style: GoogleFonts.nunito(fontSize: 13, color: _textMuted)),
              ]),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.person_outline_rounded,
                    size: 14, color: Color(0xFF9CA3AF)),
                const SizedBox(width: 4),
                Text('Posted by ${post.postedByName}',
                    style: GoogleFonts.nunito(fontSize: 12, color: _textMuted)),
              ]),
              const SizedBox(height: 16),

              Text('About',
                  style: GoogleFonts.nunito(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0A2E24))),
              const SizedBox(height: 8),
              Text(post.description,
                  style: GoogleFonts.nunito(
                      fontSize: 14,
                      color: const Color(0xFF6B8F80),
                      height: 1.6)),

              if (post.contact.isNotEmpty) ...[
                const SizedBox(height: 16),
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
                          Text(post.contact,
                              style: GoogleFonts.nunito(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: _textMain)),
                        ],
                      ),
                    ),
                  ]),
                ),
              ],

              const SizedBox(height: 20),

              // Save — only non-owners
              if (!isOwner) ...[
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _toggleSave(post);
                  },
                  style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFE11D48),
                      side: const BorderSide(color: Color(0xFFE11D48)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14))),
                  icon: Icon(
                      isSaved
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      size: 18),
                  label: Text(
                      isSaved ? 'Remove from saved' : 'Save to wishlist',
                      style: GoogleFonts.nunito(
                          fontSize: 14, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(height: 12),

                // ── Send adoption request with contact dialog ──
                SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final contactCtrl = TextEditingController();
                      final contact = await showDialog<String>(
                        context: context,
                        builder: (_) => AlertDialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          title: Text('Your contact info',
                              style: GoogleFonts.nunito(
                                  fontWeight: FontWeight.w800,
                                  color: _textMain)),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('The pet owner will see your contact',
                                  style: GoogleFonts.nunito(
                                      fontSize: 12, color: _textMuted)),
                              const SizedBox(height: 12),
                              TextField(
                                controller: contactCtrl,
                                style: GoogleFonts.nunito(fontSize: 14),
                                decoration: InputDecoration(
                                  hintText: 'Phone or email',
                                  hintStyle: TextStyle(
                                      color: _textMuted.withValues(alpha: 0.5)),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                          color: _green, width: 1.5)),
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Cancel',
                                    style: GoogleFonts.nunito(
                                        color: _textMuted,
                                        fontWeight: FontWeight.w600))),
                            ElevatedButton(
                                onPressed: () => Navigator.pop(
                                    context, contactCtrl.text.trim()),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: _green,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10))),
                                child: Text('Send request',
                                    style: GoogleFonts.nunito(
                                        fontWeight: FontWeight.w700))),
                          ],
                        ),
                      );

                      if (contact != null && contact.isNotEmpty) {
                        await AdoptionRequestService.sendRequest(
                          postId: post.id,
                          petName: post.name,
                          petType: post.type,
                          ownerId: post.postedBy,
                          contact: contact,
                        );
                        if (context.mounted) {
                          Navigator.pop(context);
                          _snack(
                              'Request sent for ${post.name}! Owner will contact you. 🐾',
                              _green);
                        }
                      }
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
              ],

              // Owner: view requests + delete
              if (isOwner) ...[
                SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AdoptionRequestsScreen()));
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14))),
                    icon: const Icon(Icons.inbox_outlined, size: 18),
                    label: Text('View adoption requests',
                        style: GoogleFonts.nunito(
                            fontSize: 15, fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      await AdoptionPostService.deletePost(post.id);
                      if (context.mounted) {
                        _snack('Post deleted', const Color(0xFFDC2626));
                      }
                    },
                    style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFDC2626),
                        side: const BorderSide(color: Color(0xFFDC2626)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14))),
                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                    label: Text('Delete my post',
                        style: GoogleFonts.nunito(
                            fontSize: 14, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
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
