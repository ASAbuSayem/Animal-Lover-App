import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BlogScreen extends StatefulWidget {
  const BlogScreen({super.key});
  @override
  State<BlogScreen> createState() => _BlogScreenState();
}

class _BlogScreenState extends State<BlogScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();

  static const _green = Color(0xFF1D9E75);
  static const _greenLight = Color(0xFFE1F5EE);
  static const _bgPage = Color(0xFFF4FAF7);
  static const _textMain = Color(0xFF0A2E24);
  static const _textMuted = Color(0xFF6B8F80);

  final List<Map<String, dynamic>> _posts = [
    {
      'title': 'Best foods for your Golden Retriever in 2026',
      'category': 'Nutrition',
      'catColor': const Color(0xFFEA580C),
      'catBg': const Color(0xFFFFF0E6),
      'readTime': '4 min read',
      'date': 'Jun 1, 2026',
      'featured': true,
      'content':
          '''Golden Retrievers are energetic dogs that need a balanced diet rich in protein and healthy fats. Here are the top foods recommended by veterinarians in 2026:

**High-Quality Proteins**
Chicken, turkey, and salmon are excellent protein sources for Golden Retrievers. Aim for at least 25-30% protein in their diet to support muscle mass and energy levels.

**Healthy Fats**
Omega-3 fatty acids from fish oil help maintain their beautiful golden coat. Include foods like sardines, salmon, or flaxseed oil.

**Complex Carbohydrates**
Sweet potatoes, brown rice, and oats provide sustained energy. Avoid simple carbs and fillers like corn syrup.

**Vegetables & Fruits**
Carrots, blueberries, and spinach are great additions. These provide antioxidants that support immune health.

**Foods to Avoid**
- Chocolate (toxic)
- Grapes and raisins (kidney damage)
- Onions and garlic (destroys red blood cells)
- Macadamia nuts (neurological issues)

Always consult your veterinarian before making major dietary changes.''',
    },
    {
      'title': 'How to groom your cat at home: Complete guide',
      'category': 'Grooming',
      'catColor': const Color(0xFF8B5CF6),
      'catBg': const Color(0xFFF3EFFE),
      'readTime': '5 min read',
      'date': 'May 28, 2026',
      'featured': false,
      'content':
          '''Regular grooming keeps your cat healthy and strengthens your bond. Here is everything you need to know about grooming your cat at home.

**Brushing**
Long-haired cats need daily brushing to prevent matting. Short-haired cats benefit from weekly brushing. Always brush in the direction of fur growth.

**Bathing**
Most cats do not need frequent baths. When necessary, use cat-specific shampoo and warm water. Keep the experience calm and positive.

**Nail Trimming**
Trim nails every 2-3 weeks using cat nail clippers. Avoid cutting the quick (pink area) which contains blood vessels.

**Ear Cleaning**
Check ears weekly for dirt or wax buildup. Use a cotton ball with veterinary ear cleaner, never cotton swabs.

**Dental Care**
Brush teeth 3 times per week with cat-safe toothpaste. Dental treats and water additives also help maintain oral health.''',
    },
    {
      'title': 'Vaccine schedule every pet owner must know',
      'category': 'Health',
      'catColor': const Color(0xFF1D9E75),
      'catBg': const Color(0xFFE1F5EE),
      'readTime': '3 min read',
      'date': 'May 22, 2026',
      'featured': false,
      'content':
          '''Vaccination is one of the most important things you can do for your pet. Here is the essential vaccine schedule for dogs and cats.

**Dogs - Core Vaccines**
- DHPP (Distemper, Hepatitis, Parvovirus, Parainfluenza): First dose at 6-8 weeks, boosters every 3-4 weeks until 16 weeks, then every 1-3 years.
- Rabies: First dose at 12-16 weeks, booster at 1 year, then every 1-3 years.

**Dogs - Non-Core Vaccines**
- Bordetella (Kennel Cough): Recommended for social dogs
- Leptospirosis: For dogs exposed to wildlife or standing water
- Lyme Disease: For dogs in tick-prone areas

**Cats - Core Vaccines**
- FVRCP (Feline Viral Rhinotracheitis, Calicivirus, Panleukopenia): Every 3-4 weeks from 6-16 weeks, then every 1-3 years.
- Rabies: As required by local law.

Always keep vaccination records and consult your vet for a personalized schedule.''',
    },
    {
      'title': 'Understanding your dog\'s body language',
      'category': 'Behavior',
      'catColor': const Color(0xFF0891B2),
      'catBg': const Color(0xFFE0F7FA),
      'readTime': '6 min read',
      'date': 'May 15, 2026',
      'featured': false,
      'content':
          '''Learning to read your dog's body language helps you understand their needs and emotions. Here are the key signals to watch for.

**Happy and Relaxed**
Loose, wiggly body, soft eyes, relaxed ears, and a wagging tail held at mid-height indicate a happy dog. Play bows (front legs down, rear up) signal an invitation to play.

**Fearful or Anxious**
Tail tucked, ears back, body lowered, yawning, licking lips, or turning away are signs of stress. Give the dog space and identify the cause of anxiety.

**Alert or Excited**
Ears forward, tail raised, body leaning forward indicate alertness or excitement. This can be positive or mean the dog is preparing to react.

**Aggressive Warning Signs**
Stiff body, direct stare, raised hackles, lips pulled back, low growl. Never ignore these signals — give the dog space and avoid eye contact.

**Submissive Behavior**
Rolling onto back, exposing belly is a sign of submission and trust. It can also indicate anxiety in some situations.''',
    },
    {
      'title': 'Top 5 exercises for indoor cats',
      'category': 'Exercise',
      'catColor': const Color(0xFF16A34A),
      'catBg': const Color(0xFFDCFCE7),
      'readTime': '4 min read',
      'date': 'May 10, 2026',
      'featured': false,
      'content':
          '''Indoor cats need regular exercise to stay healthy and mentally stimulated. Here are 5 excellent ways to keep your indoor cat active.

**1. Wand Toys**
Interactive wand toys mimic prey movement and trigger your cat's hunting instincts. Play for 10-15 minutes twice daily for best results.

**2. Puzzle Feeders**
Hide kibble in puzzle feeders or use slow-feeding bowls. This makes mealtime mentally stimulating and slows eating.

**3. Cat Trees and Climbing Structures**
Multi-level cat trees provide exercise through climbing and jumping. Place near windows for added stimulation from outdoor viewing.

**4. Laser Pointers**
Cats love chasing laser dots. Always end sessions with a physical toy they can catch to avoid frustration.

**5. Window Bird Feeders**
Place bird feeders outside windows. Watching birds provides mental stimulation and satisfies hunting instincts safely.''',
    },
    {
      'title': 'How to introduce a new pet to your home',
      'category': 'Tips',
      'catColor': const Color(0xFFD97706),
      'catBg': const Color(0xFFFEF3C7),
      'readTime': '5 min read',
      'date': 'May 5, 2026',
      'featured': false,
      'content':
          '''Bringing a new pet home requires careful preparation. Follow these steps for a smooth transition.

**Before Arrival**
Set up a safe space with food, water, bedding, and toys. Pet-proof the area by securing cables and removing hazards. If you have existing pets, prepare separate spaces.

**The First Day**
Keep things calm and quiet. Allow the new pet to explore at their own pace. Limit visitors for the first few days.

**Introducing to Other Pets**
For cats meeting cats: Use scent swapping first. Exchange bedding between pets before face-to-face meetings. Use a baby gate for initial visual introductions.

For dogs meeting dogs: Neutral territory meetings work best. Keep both dogs on leash initially. Watch body language carefully.

**The First Week**
Maintain a consistent routine for feeding and play. Monitor for signs of stress in all animals. Give each pet individual attention.

**Long Term**
Most pets adjust within 2-4 weeks. Be patient — some animals take months to fully settle in.''',
    },
  ];

  List<Map<String, dynamic>> get _filtered {
    return _posts.where((post) {
      final matchCat =
          _selectedCategory == 'All' || post['category'] == _selectedCategory;
      final matchSearch = _searchQuery.isEmpty ||
          (post['title'] as String)
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          (post['category'] as String)
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
      return matchCat && matchSearch;
    }).toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgPage,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildCategories(),
            Expanded(child: _buildPostList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pet Care Blog',
              style: GoogleFonts.nunito(
                  fontSize: 22, fontWeight: FontWeight.w800, color: _textMain)),
          Text('Tips, guides & expert advice',
              style: GoogleFonts.nunito(fontSize: 13, color: _textMuted)),
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
          hintText: 'Search articles...',
          hintStyle:
              TextStyle(color: _textMuted.withValues(alpha: 0.6), fontSize: 13),
          prefixIcon: const Icon(Icons.search_rounded,
              size: 20, color: Color(0xFF9CA3AF)),
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

  Widget _buildCategories() {
    final cats = [
      'All',
      'Nutrition',
      'Health',
      'Grooming',
      'Behavior',
      'Exercise',
      'Tips'
    ];
    return SizedBox(
      height: 52,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
        itemCount: cats.length,
        itemBuilder: (_, i) {
          final selected = _selectedCategory == cats[i];
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cats[i]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                  color: selected ? _green : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: selected ? _green : const Color(0xFFE5F0EA))),
              child: Text(cats[i],
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
    final posts = _filtered;
    if (posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined,
                size: 56, color: _textMuted.withValues(alpha: 0.4)),
            const SizedBox(height: 12),
            Text('No articles found',
                style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _textMuted)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      physics: const BouncingScrollPhysics(),
      itemCount: posts.length,
      itemBuilder: (_, i) {
        final post = posts[i];
        if (i == 0 &&
            post['featured'] as bool &&
            _selectedCategory == 'All' &&
            _searchQuery.isEmpty) {
          return _buildFeaturedCard(post);
        }
        return _buildPostCard(post);
      },
    );
  }

  Widget _buildFeaturedCard(Map<String, dynamic> post) {
    return GestureDetector(
      onTap: () => _openPost(context, post),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [_green, Color(0xFF0D7A58)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(18)),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(20)),
                child: Text('⭐ Featured',
                    style: GoogleFonts.nunito(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
              const SizedBox(width: 8),
              _catChipWhite(post['category'] as String),
            ]),
            const SizedBox(height: 14),
            Text(post['title'] as String,
                style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.3)),
            const SizedBox(height: 12),
            Row(children: [
              const Icon(Icons.access_time_rounded,
                  size: 14, color: Colors.white70),
              const SizedBox(width: 4),
              Text(post['readTime'] as String,
                  style:
                      GoogleFonts.nunito(fontSize: 12, color: Colors.white70)),
              const SizedBox(width: 12),
              const Icon(Icons.calendar_today_outlined,
                  size: 14, color: Colors.white70),
              const SizedBox(width: 4),
              Text(post['date'] as String,
                  style:
                      GoogleFonts.nunito(fontSize: 12, color: Colors.white70)),
            ]),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Text('Read article →',
                  style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _green)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    final catColor = post['catColor'] as Color;
    final catBg = post['catBg'] as Color;

    return GestureDetector(
      onTap: () => _openPost(context, post),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5F0EA))),
        child: Row(children: [
          Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                  color: catBg, borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.article_rounded, size: 30, color: catColor)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                      color: catBg, borderRadius: BorderRadius.circular(20)),
                  child: Text(post['category'] as String,
                      style: GoogleFonts.nunito(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: catColor)),
                ),
                const SizedBox(height: 6),
                Text(post['title'] as String,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _textMain,
                        height: 1.3)),
                const SizedBox(height: 6),
                Row(children: [
                  const Icon(Icons.access_time_rounded,
                      size: 12, color: Color(0xFF9CA3AF)),
                  const SizedBox(width: 3),
                  Text(post['readTime'] as String,
                      style:
                          GoogleFonts.nunito(fontSize: 11, color: _textMuted)),
                  const SizedBox(width: 8),
                  Text(post['date'] as String,
                      style:
                          GoogleFonts.nunito(fontSize: 11, color: _textMuted)),
                ]),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFFB0C4BC)),
        ]),
      ),
    );
  }

  Widget _catChipWhite(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: GoogleFonts.nunito(
              fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
    );
  }

  void _openPost(BuildContext context, Map<String, dynamic> post) {
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => _BlogDetailScreen(post: post)));
  }
}

// ── Blog detail screen ─────────────────────────
class _BlogDetailScreen extends StatelessWidget {
  final Map<String, dynamic> post;
  const _BlogDetailScreen({required this.post});

  static const _green = Color(0xFF1D9E75);
  static const _textMain = Color(0xFF0A2E24);
  static const _textMuted = Color(0xFF6B8F80);

  @override
  Widget build(BuildContext context) {
    final catColor = post['catColor'] as Color;
    final catBg = post['catBg'] as Color;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
            icon:
                const Icon(Icons.arrow_back_rounded, color: Color(0xFF0A2E24)),
            onPressed: () => Navigator.pop(context)),
        actions: [
          IconButton(
              icon: const Icon(Icons.share_outlined, color: Color(0xFF6B8F80)),
              onPressed: () {}),
        ],
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: const Color(0xFFE5F0EA))),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                  color: catBg, borderRadius: BorderRadius.circular(20)),
              child: Text(post['category'] as String,
                  style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: catColor)),
            ),
            const SizedBox(height: 14),

            // Title
            Text(post['title'] as String,
                style: GoogleFonts.nunito(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: _textMain,
                    height: 1.3)),
            const SizedBox(height: 12),

            // Meta
            Row(children: [
              const Icon(Icons.access_time_rounded,
                  size: 14, color: Color(0xFF9CA3AF)),
              const SizedBox(width: 4),
              Text(post['readTime'] as String,
                  style: GoogleFonts.nunito(fontSize: 13, color: _textMuted)),
              const SizedBox(width: 12),
              const Icon(Icons.calendar_today_outlined,
                  size: 14, color: Color(0xFF9CA3AF)),
              const SizedBox(width: 4),
              Text(post['date'] as String,
                  style: GoogleFonts.nunito(fontSize: 13, color: _textMuted)),
            ]),
            const SizedBox(height: 20),

            // Divider
            Container(height: 1, color: const Color(0xFFE5F0EA)),
            const SizedBox(height: 20),

            // Content
            ...(post['content'] as String).split('\n').map((line) {
              if (line.startsWith('**') && line.endsWith('**')) {
                return Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 6),
                    child: Text(line.replaceAll('**', ''),
                        style: GoogleFonts.nunito(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: _textMain)));
              } else if (line.startsWith('- ')) {
                return Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                          padding: const EdgeInsets.only(top: 7, right: 8),
                          child: Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                  color: _green, shape: BoxShape.circle))),
                      Expanded(
                          child: Text(line.substring(2),
                              style: GoogleFonts.nunito(
                                  fontSize: 14,
                                  color: _textMuted,
                                  height: 1.6))),
                    ],
                  ),
                );
              } else if (line.isEmpty) {
                return const SizedBox(height: 6);
              }
              return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(line,
                      style: GoogleFonts.nunito(
                          fontSize: 14.5, color: _textMuted, height: 1.7)));
            }),

            const SizedBox(height: 32),

            // Back button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                    foregroundColor: _green,
                    side: const BorderSide(color: _green),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14))),
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: Text('Back to Blog',
                    style: GoogleFonts.nunito(
                        fontSize: 14, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
