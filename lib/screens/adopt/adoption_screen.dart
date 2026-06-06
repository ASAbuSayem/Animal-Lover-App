import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/saved_posts_service.dart';

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

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  static const _green = Color(0xFF1D9E75);
  static const _greenLight = Color(0xFFE1F5EE);
  static const _bgPage = Color(0xFFF4FAF7);
  static const _textMain = Color(0xFF0A2E24);
  static const _textMuted = Color(0xFF6B8F80);

  final List<Map<String, dynamic>> _allPets = [
    {
      'name': 'Buddy',
      'type': 'Dog',
      'breed': 'Labrador Mix',
      'age': '2 years',
      'gender': 'Male',
      'location': 'Dhaka',
      'description':
          'Friendly and playful Labrador mix looking for a loving home. Good with kids and other pets.',
      'color': const Color(0xFFEA580C),
      'bg': const Color(0xFFFFF0E6),
      'icon': Icons.pets_rounded,
      'saved': false,
      'vaccinated': true,
      'neutered': false,
    },
    {
      'name': 'Whiskers',
      'type': 'Cat',
      'breed': 'Persian',
      'age': '1 year',
      'gender': 'Female',
      'location': 'Sylhet',
      'description':
          'Beautiful Persian cat, very calm and affectionate. Loves cuddles and indoor living.',
      'color': const Color(0xFF8B5CF6),
      'bg': const Color(0xFFF3EFFE),
      'icon': Icons.catching_pokemon_rounded,
      'saved': false,
      'vaccinated': true,
      'neutered': true,
    },
    {
      'name': 'Rocky',
      'type': 'Dog',
      'breed': 'German Shepherd',
      'age': '3 years',
      'gender': 'Male',
      'location': 'Chittagong',
      'description':
          'Intelligent and loyal German Shepherd. Trained, vaccinated, and ready for a new family.',
      'color': const Color(0xFF0891B2),
      'bg': const Color(0xFFE0F7FA),
      'icon': Icons.pets_rounded,
      'saved': false,
      'vaccinated': true,
      'neutered': false,
    },
    {
      'name': 'Luna',
      'type': 'Cat',
      'breed': 'Siamese',
      'age': '6 months',
      'gender': 'Female',
      'location': 'Rajshahi',
      'description':
          'Playful Siamese kitten who loves attention and playtime. Very social and curious.',
      'color': const Color(0xFF8B5CF6),
      'bg': const Color(0xFFF3EFFE),
      'icon': Icons.catching_pokemon_rounded,
      'saved': false,
      'vaccinated': false,
      'neutered': false,
    },
    {
      'name': 'Max',
      'type': 'Dog',
      'breed': 'Golden Retriever',
      'age': '4 years',
      'gender': 'Male',
      'location': 'Dhaka',
      'description':
          'Sweet Golden Retriever, excellent with children. House-trained and loves outdoor activities.',
      'color': const Color(0xFFEA580C),
      'bg': const Color(0xFFFFF0E6),
      'icon': Icons.pets_rounded,
      'saved': false,
      'vaccinated': true,
      'neutered': true,
    },
    {
      'name': 'Mochi',
      'type': 'Rabbit',
      'breed': 'Holland Lop',
      'age': '8 months',
      'gender': 'Female',
      'location': 'Dhaka',
      'description':
          'Adorable Holland Lop rabbit, very gentle and quiet. Perfect for apartment living.',
      'color': const Color(0xFF16A34A),
      'bg': const Color(0xFFE1F5EE),
      'icon': Icons.cruelty_free_rounded,
      'saved': false,
      'vaccinated': false,
      'neutered': false,
    },
  ];

  List<Map<String, dynamic>> get _filtered {
    return _allPets.where((pet) {
      final matchFilter =
          _selectedFilter == 'All' || pet['type'] == _selectedFilter;
      final matchSearch = _searchQuery.isEmpty ||
          (pet['name'] as String)
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          (pet['breed'] as String)
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          (pet['location'] as String)
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
      return matchFilter && matchSearch;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
    _loadSavedStatus();
  }

  // Load saved status from Firestore on init
  Future<void> _loadSavedStatus() async {
    for (final pet in _allPets) {
      final saved = await SavedPostsService.isSaved(pet['name'] as String);
      if (mounted) {
        setState(() => pet['saved'] = saved);
      }
    }
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // Toggle save with Firestore sync
  Future<void> _toggleSave(Map<String, dynamic> pet) async {
    final isSaved = pet['saved'] as bool;
    setState(() => pet['saved'] = !isSaved);

    try {
      if (!isSaved) {
        await SavedPostsService.savePost(pet);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('${pet['name']} saved! View in Profile → Saved posts',
                style: GoogleFonts.nunito(fontWeight: FontWeight.w600)),
            backgroundColor: _green,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ));
        }
      } else {
        await SavedPostsService.unsavePost(pet['name'] as String);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('${pet['name']} removed from saved',
                style: GoogleFonts.nunito(fontWeight: FontWeight.w600)),
            backgroundColor: const Color(0xFFE11D48),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ));
        }
      }
    } catch (_) {
      // Revert on error
      if (mounted) setState(() => pet['saved'] = isSaved);
    }
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
            Expanded(child: _buildPetGrid()),
          ]),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPostAdoptionSheet(context),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
                color: _greenLight, borderRadius: BorderRadius.circular(20)),
            child: Row(children: [
              const Icon(Icons.pets_rounded, size: 14, color: _green),
              const SizedBox(width: 4),
              Text('${_filtered.length} pets',
                  style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _green)),
            ]),
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
    final filters = ['All', 'Dog', 'Cat', 'Rabbit', 'Bird'];
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

  Widget _buildPetGrid() {
    if (_filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded,
                size: 56, color: _textMuted.withValues(alpha: 0.4)),
            const SizedBox(height: 12),
            Text('No pets found',
                style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _textMuted)),
            Text('Try a different filter or search',
                style: GoogleFonts.nunito(fontSize: 13, color: _textMuted)),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 100),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemCount: _filtered.length,
      itemBuilder: (_, i) => _buildPetCard(_filtered[i]),
    );
  }

  Widget _buildPetCard(Map<String, dynamic> pet) {
    final color = pet['color'] as Color;
    final bg = pet['bg'] as Color;

    return GestureDetector(
      onTap: () => _showPetDetail(context, pet),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5F0EA))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area
            Container(
              height: 130,
              decoration: BoxDecoration(
                  color: bg,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16))),
              child: Stack(children: [
                Center(
                    child: Icon(pet['icon'] as IconData,
                        size: 64, color: color.withValues(alpha: 0.8))),

                // ── Save button — Firestore synced ──
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => _toggleSave(pet),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 4)
                          ]),
                      child: Icon(
                          pet['saved'] as bool
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          size: 16,
                          color: pet['saved'] as bool
                              ? const Color(0xFFE11D48)
                              : _textMuted),
                    ),
                  ),
                ),

                // Vaccinated badge
                if (pet['vaccinated'] as bool)
                  Positioned(
                    bottom: 8,
                    left: 8,
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
              ]),
            ),

            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(pet['name'] as String,
                            style: GoogleFonts.nunito(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: _textMain)),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                              color: bg,
                              borderRadius: BorderRadius.circular(20)),
                          child: Text(
                              pet['gender'] as String == 'Male' ? '♂' : '♀',
                              style: TextStyle(fontSize: 12, color: color)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(pet['breed'] as String,
                        style: GoogleFonts.nunito(
                            fontSize: 11, color: _textMuted)),
                    const SizedBox(height: 6),
                    Row(children: [
                      const Icon(Icons.access_time_rounded,
                          size: 12, color: Color(0xFF9CA3AF)),
                      const SizedBox(width: 3),
                      Text(pet['age'] as String,
                          style: GoogleFonts.nunito(
                              fontSize: 11, color: _textMuted)),
                      const SizedBox(width: 8),
                      const Icon(Icons.location_on_outlined,
                          size: 12, color: Color(0xFF9CA3AF)),
                      const SizedBox(width: 2),
                      Expanded(
                          child: Text(pet['location'] as String,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.nunito(
                                  fontSize: 11, color: _textMuted))),
                    ]),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _showPetDetail(context, pet),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _green,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 8),
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
            ),
          ],
        ),
      ),
    );
  }

  void _showPetDetail(BuildContext context, Map<String, dynamic> pet) {
    final color = pet['color'] as Color;
    final bg = pet['bg'] as Color;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.92,
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
                    child:
                        Icon(pet['icon'] as IconData, size: 72, color: color)),
              ),
              const SizedBox(height: 20),

              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(pet['name'] as String,
                    style: GoogleFonts.nunito(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0A2E24))),
                Row(children: [
                  if (pet['vaccinated'] as bool)
                    _badge('Vaccinated', _green, _greenLight),
                  if (pet['neutered'] as bool) ...[
                    const SizedBox(width: 6),
                    _badge('Neutered', const Color(0xFF0891B2),
                        const Color(0xFFE0F7FA)),
                  ],
                ]),
              ]),
              const SizedBox(height: 6),
              Text('${pet['breed']} · ${pet['age']} · ${pet['gender']}',
                  style: GoogleFonts.nunito(fontSize: 14, color: _textMuted)),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.location_on_outlined,
                    size: 14, color: Color(0xFF9CA3AF)),
                const SizedBox(width: 4),
                Text(pet['location'] as String,
                    style: GoogleFonts.nunito(fontSize: 13, color: _textMuted)),
              ]),
              const SizedBox(height: 16),

              Text('About',
                  style: GoogleFonts.nunito(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0A2E24))),
              const SizedBox(height: 8),
              Text(pet['description'] as String,
                  style: GoogleFonts.nunito(
                      fontSize: 14,
                      color: const Color(0xFF6B8F80),
                      height: 1.6)),
              const SizedBox(height: 24),

              // Save button inside detail sheet
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _toggleSave(pet);
                },
                style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFE11D48),
                    side: const BorderSide(color: Color(0xFFE11D48)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14))),
                icon: Icon(
                    pet['saved'] as bool
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    size: 18),
                label: Text(
                    pet['saved'] as bool
                        ? 'Remove from saved'
                        : 'Save to wishlist',
                    style: GoogleFonts.nunito(
                        fontSize: 14, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 12),

              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                          'Adoption request sent for ${pet['name']}! 🐾',
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
            ],
          ),
        ),
      ),
    );
  }

  void _showPostAdoptionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                  child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: const Color(0xFFE5E7EB),
                          borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              Text('Post a pet for adoption',
                  style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: _textMain)),
              const SizedBox(height: 6),
              Text('Help a pet find a loving home by posting their profile.',
                  style: GoogleFonts.nunito(fontSize: 13, color: _textMuted)),
              const SizedBox(height: 20),
              SizedBox(
                height: 52,
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: _green,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14))),
                  icon: const Icon(Icons.add_a_photo_outlined, size: 18),
                  label: Text('Create adoption post',
                      style: GoogleFonts.nunito(
                          fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 12),
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
