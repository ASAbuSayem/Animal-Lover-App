import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

import '../adopt/adoption_screen.dart';
import '../blog/blog_screen.dart';
import '../profile/profile_screen.dart';
import '../ai/symptom_checker_screen.dart';
import '../ai/care_planner_screen.dart';
import '../pet/add_pet_screen.dart';
import '../pet/pet_detail_screen.dart';
import '../../services/pet_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  static const _green = Color(0xFF1D9E75);
  static const _bgPage = Color(0xFFF4FAF7);

  final _pages = const [
    _HomePage(),
    AdoptionScreen(),
    _AiCareMenuPage(),
    BlogScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _onTabTapped(int i) {
    if (i == _currentIndex) return;
    _fadeCtrl.reset();
    setState(() => _currentIndex = i);
    _fadeCtrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgPage,
      body: FadeTransition(opacity: _fadeAnim, child: _pages[_currentIndex]),
      bottomNavigationBar: _buildNavBar(),
    );
  }

  Widget _buildNavBar() {
    const items = [
      BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home_rounded),
          label: 'Home'),
      BottomNavigationBarItem(
          icon: Icon(Icons.favorite_border_rounded),
          activeIcon: Icon(Icons.favorite_rounded),
          label: 'Adopt'),
      BottomNavigationBarItem(
          icon: Icon(Icons.smart_toy_outlined),
          activeIcon: Icon(Icons.smart_toy_rounded),
          label: 'AI Care'),
      BottomNavigationBarItem(
          icon: Icon(Icons.article_outlined),
          activeIcon: Icon(Icons.article_rounded),
          label: 'Blog'),
      BottomNavigationBarItem(
          icon: Icon(Icons.person_outline_rounded),
          activeIcon: Icon(Icons.person_rounded),
          label: 'Profile'),
    ];

    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          border:
              Border(top: BorderSide(color: Colors.grey.shade200, width: 0.5))),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: items,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: _green,
        unselectedItemColor: const Color(0xFFB0C4BC),
        selectedLabelStyle:
            GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w700),
        unselectedLabelStyle: GoogleFonts.nunito(fontSize: 11),
        elevation: 0,
      ),
    );
  }
}

// ── AI Care menu ─────────────────────────────────
class _AiCareMenuPage extends StatelessWidget {
  const _AiCareMenuPage();

  static const _green = Color(0xFF1D9E75);
  static const _greenLight = Color(0xFFE1F5EE);
  static const _bgPage = Color(0xFFF4FAF7);
  static const _textMain = Color(0xFF0A2E24);
  static const _textMuted = Color(0xFF6B8F80);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgPage,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text('AI Care',
                  style: GoogleFonts.nunito(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: _textMain)),
              Text('Smart tools for your pet\'s health',
                  style: GoogleFonts.nunito(fontSize: 13, color: _textMuted)),
              const SizedBox(height: 24),

              // Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFF8B5CF6), Color(0xFF6D3FC8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(18)),
                child: Row(children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Powered by',
                            style: GoogleFonts.nunito(
                                fontSize: 11, color: Colors.white70)),
                        Text('Fooggle AI',
                            style: GoogleFonts.nunito(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.white)),
                        const SizedBox(height: 4),
                        Text('AI-powered veterinary assistance',
                            style: GoogleFonts.nunito(
                                fontSize: 12, color: Colors.white70)),
                      ],
                    ),
                  ),
                  const Icon(Icons.smart_toy_rounded,
                      size: 48, color: Colors.white),
                ]),
              ),

              const SizedBox(height: 20),
              Text('Choose a tool',
                  style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: _textMain)),
              const SizedBox(height: 14),

              _aiCard(
                context,
                icon: Icons.medical_services_rounded,
                color: const Color(0xFF8B5CF6),
                bg: const Color(0xFFF3EFFE),
                title: 'Symptom Checker',
                description:
                    'Describe your pet\'s symptoms and get an AI-powered '
                    'risk assessment with a personalized care plan.',
                tag: 'NLP + Risk scoring',
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const SymptomCheckerScreen())),
              ),
              const SizedBox(height: 14),

              _aiCard(
                context,
                icon: Icons.calendar_today_rounded,
                color: _green,
                bg: _greenLight,
                title: 'Care Planner',
                description: 'Generate a complete personalized plan covering '
                    'nutrition, exercise, grooming, and vaccine schedule.',
                tag: 'Personalized AI plan',
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const CarePlannerScreen())),
              ),
              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: _greenLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF9FE1CB))),
                child: Row(children: [
                  const Icon(Icons.tips_and_updates_rounded,
                      size: 20, color: _green),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Text(
                          'AI responses are for guidance only. '
                          'Always consult a licensed veterinarian '
                          'for medical decisions.',
                          style: GoogleFonts.nunito(
                              fontSize: 12,
                              color: const Color(0xFF2D6E56),
                              height: 1.5))),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _aiCard(BuildContext context,
      {required IconData icon,
      required Color color,
      required Color bg,
      required String title,
      required String description,
      required String tag,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5F0EA))),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                  color: bg, borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, size: 26, color: color)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0A2E24))),
                const SizedBox(height: 4),
                Text(description,
                    style: GoogleFonts.nunito(
                        fontSize: 12,
                        color: const Color(0xFF6B8F80),
                        height: 1.5)),
                const SizedBox(height: 10),
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color: bg, borderRadius: BorderRadius.circular(20)),
                    child: Text(tag,
                        style: GoogleFonts.nunito(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: color))),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded,
              size: 16, color: color.withValues(alpha: 0.5)),
        ]),
      ),
    );
  }
}

// ── Home tab ─────────────────────────────────────
class _HomePage extends StatelessWidget {
  const _HomePage();

  static const _green = Color(0xFF1D9E75);
  static const _greenLight = Color(0xFFE1F5EE);
  static const _greenMid = Color(0xFF9FE1CB);
  static const _textMain = Color(0xFF0A2E24);
  static const _textMuted = Color(0xFF6B8F80);

  String get _userName {
    final user = FirebaseAuth.instance.currentUser;
    if (user?.displayName != null && user!.displayName!.isNotEmpty) {
      return user.displayName!.split(' ').first;
    }
    return 'there';
  }

  void _navigate(BuildContext context, int tabIndex) {
    context.findAncestorStateOfType<_HomeScreenState>()?._onTabTapped(tabIndex);
  }

  void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content:
          Text(msg, style: GoogleFonts.nunito(fontWeight: FontWeight.w600)),
      backgroundColor: _green,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
    ));
  }

  // Pet type helpers
  Color _petColor(String type) => switch (type) {
        'Dog' => const Color(0xFFEA580C),
        'Cat' => const Color(0xFF8B5CF6),
        'Bird' => const Color(0xFF0891B2),
        'Rabbit' => const Color(0xFF16A34A),
        _ => _green,
      };

  Color _petBg(String type) => switch (type) {
        'Dog' => const Color(0xFFFFF7ED),
        'Cat' => const Color(0xFFF3EFFE),
        'Bird' => const Color(0xFFE0F7FA),
        'Rabbit' => const Color(0xFFDCFCE7),
        _ => _greenLight,
      };

  IconData _petIconData(String type) => switch (type) {
        'Cat' => Icons.catching_pokemon_rounded,
        'Bird' => Icons.flutter_dash_rounded,
        'Rabbit' => Icons.cruelty_free_rounded,
        _ => Icons.pets_rounded,
      };

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            _buildTopBar(context),
            const SizedBox(height: 28),
            _buildGreetingCard(context),
            const SizedBox(height: 24),
            _buildSectionLabel('Your pets'),
            const SizedBox(height: 12),
            _buildPetRow(context),
            const SizedBox(height: 24),
            _buildSectionLabel('Upcoming care'),
            const SizedBox(height: 12),
            _buildUpcomingSection(),
            const SizedBox(height: 24),
            _buildSectionLabel('Quick actions'),
            const SizedBox(height: 12),
            _buildQuickActions(context),
            const SizedBox(height: 24),
            _buildSectionLabel('Recent blog posts'),
            const SizedBox(height: 12),
            _buildBlogCard(context,
                title: 'Best foods for your dog in 2026',
                category: 'Nutrition',
                readTime: '4 min read'),
            const SizedBox(height: 10),
            _buildBlogCard(context,
                title: 'How to groom your cat at home',
                category: 'Grooming',
                readTime: '3 min read'),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Hello, $_userName 👋',
              style: GoogleFonts.nunito(
                  fontSize: 22, fontWeight: FontWeight.w800, color: _textMain)),
          Text('How are your pets today?',
              style: GoogleFonts.nunito(fontSize: 13, color: _textMuted)),
        ]),
        Row(children: [
          _iconBtn(Icons.notifications_outlined,
              () => _showSnack(context, 'No new notifications 🔔')),
          const SizedBox(width: 8),
          _iconBtn(
              Icons.add_circle_outline_rounded,
              () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AddPetScreen()))),
        ]),
      ],
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5F0EA))),
        child: Icon(icon, size: 20, color: _textMuted),
      ),
    );
  }

  Widget _buildGreetingCard(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigate(context, 2),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: _green, borderRadius: BorderRadius.circular(20)),
        child: Row(children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI Pet Care',
                    style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70)),
                const SizedBox(height: 4),
                Text('Check your pet\'s health with AI',
                    style: GoogleFonts.nunito(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Colors.white)),
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)),
                  child: Text('Try AI checker',
                      style: GoogleFonts.nunito(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _green)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle),
            child: const Icon(Icons.smart_toy_rounded,
                size: 36, color: Colors.white),
          ),
        ]),
      ),
    );
  }

  Widget _buildSectionLabel(String text) => Text(text,
      style: GoogleFonts.nunito(
          fontSize: 16, fontWeight: FontWeight.w800, color: _textMain));

  // ── Real pets from Firestore ──────────────────
  Widget _buildPetRow(BuildContext context) {
    return StreamBuilder<List<Pet>>(
      stream: PetService.petsStream(),
      builder: (context, snap) {
        final pets = snap.data ?? [];
        return SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ...pets.map((pet) => Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      // ← Click opens Pet Detail screen
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => PetDetailScreen(pet: pet))),
                      child: _petCard(
                          pet.name,
                          pet.breed.isEmpty ? pet.type : pet.breed,
                          _petIconData(pet.type),
                          _petBg(pet.type),
                          _petColor(pet.type)),
                    ),
                  )),
              GestureDetector(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AddPetScreen())),
                child: _addPetCard(),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Real upcoming care from Firestore ──────────
  Widget _buildUpcomingSection() {
    return StreamBuilder<List<Pet>>(
      stream: PetService.petsStream(),
      builder: (context, snap) {
        final pets = snap.data ?? [];
        final items = <Widget>[];

        for (final pet in pets) {
          if (pet.vaccineDate != null && pet.vaccineDate!.isNotEmpty) {
            items.add(_buildUpcomingCard(
              icon: Icons.vaccines_rounded,
              iconColor: const Color(0xFF8B5CF6),
              iconBg: const Color(0xFFF3EFFE),
              title: 'Vaccine due',
              subtitle: '${pet.name} · ${pet.vaccineDate}',
              tag: 'Vaccine',
              tagColor: const Color(0xFF8B5CF6),
              tagBg: const Color(0xFFF3EFFE),
            ));
            items.add(const SizedBox(height: 10));
          }
          if (pet.mealTime != null && pet.mealTime!.isNotEmpty) {
            items.add(_buildUpcomingCard(
              icon: Icons.restaurant_rounded,
              iconColor: const Color(0xFFEA580C),
              iconBg: const Color(0xFFFFF0E6),
              title: 'Meal time',
              subtitle: '${pet.name} · ${pet.mealTime}',
              tag: 'Feeding',
              tagColor: const Color(0xFFEA580C),
              tagBg: const Color(0xFFFFF0E6),
            ));
            items.add(const SizedBox(height: 10));
          }
        }

        if (items.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5F0EA))),
            child: Row(children: [
              const Icon(Icons.info_outline_rounded,
                  size: 20, color: Color(0xFF9CA3AF)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                    'Add a pet with care schedule to see reminders here',
                    style: GoogleFonts.nunito(
                        fontSize: 13, color: const Color(0xFF6B8F80))),
              ),
            ]),
          );
        }

        return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, children: items);
      },
    );
  }

  Widget _petCard(
      String name, String breed, IconData icon, Color bg, Color fg) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5F0EA))),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            child: Icon(icon, size: 22, color: fg)),
        const SizedBox(height: 8),
        Text(name,
            style: GoogleFonts.nunito(
                fontSize: 13, fontWeight: FontWeight.w700, color: _textMain)),
        Text(breed,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.nunito(fontSize: 9, color: _textMuted)),
      ]),
    );
  }

  Widget _addPetCard() {
    return Container(
      width: 90,
      decoration: BoxDecoration(
          color: _greenLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _greenMid)),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.add_circle_outline_rounded, size: 28, color: _green),
        const SizedBox(height: 6),
        Text('Add pet',
            style: GoogleFonts.nunito(
                fontSize: 12, fontWeight: FontWeight.w700, color: _green)),
      ]),
    );
  }

  Widget _buildUpcomingCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required String tag,
    required Color tagColor,
    required Color tagBg,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5F0EA))),
      child: Row(children: [
        Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
                color: iconBg, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, size: 22, color: iconColor)),
        const SizedBox(width: 14),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _textMain)),
            Text(subtitle,
                style: GoogleFonts.nunito(fontSize: 12, color: _textMuted)),
          ]),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
              color: tagBg, borderRadius: BorderRadius.circular(20)),
          child: Text(tag,
              style: GoogleFonts.nunito(
                  fontSize: 11, fontWeight: FontWeight.w700, color: tagColor)),
        ),
      ]),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      {
        'icon': Icons.medical_services_outlined,
        'label': 'Symptom\nChecker',
        'color': const Color(0xFF8B5CF6),
        'bg': const Color(0xFFF3EFFE),
        'tab': 2
      },
      {
        'icon': Icons.calendar_today_outlined,
        'label': 'Care\nPlanner',
        'color': const Color(0xFF0891B2),
        'bg': const Color(0xFFE0F7FA),
        'tab': 2
      },
      {
        'icon': Icons.favorite_border_rounded,
        'label': 'Adopt\nPet',
        'color': const Color(0xFFEA580C),
        'bg': const Color(0xFFFFF0E6),
        'tab': 1
      },
      {
        'icon': Icons.article_outlined,
        'label': 'Read\nBlog',
        'color': _green,
        'bg': _greenLight,
        'tab': 3
      },
    ];

    return Row(
      children: actions.asMap().entries.map((entry) {
        final i = entry.key;
        final a = entry.value;
        return Expanded(
          child: GestureDetector(
            onTap: () => _navigate(context, a['tab'] as int),
            child: Container(
              margin: EdgeInsets.only(right: i < actions.length - 1 ? 10 : 0),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE5F0EA))),
              child: Column(children: [
                Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                        color: a['bg'] as Color,
                        borderRadius: BorderRadius.circular(12)),
                    child: Icon(a['icon'] as IconData,
                        size: 22, color: a['color'] as Color)),
                const SizedBox(height: 8),
                Text(a['label'] as String,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _textMain)),
              ]),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBlogCard(BuildContext context,
      {required String title,
      required String category,
      required String readTime}) {
    return GestureDetector(
      onTap: () => _navigate(context, 3),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5F0EA))),
        child: Row(children: [
          Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                  color: _greenLight, borderRadius: BorderRadius.circular(12)),
              child:
                  const Icon(Icons.article_rounded, size: 28, color: _green)),
          const SizedBox(width: 14),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _textMain)),
              const SizedBox(height: 4),
              Row(children: [
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                        color: _greenLight,
                        borderRadius: BorderRadius.circular(20)),
                    child: Text(category,
                        style: GoogleFonts.nunito(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: _green))),
                const SizedBox(width: 8),
                Text(readTime,
                    style: GoogleFonts.nunito(fontSize: 11, color: _textMuted)),
              ]),
            ]),
          ),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFFB0C4BC)),
        ]),
      ),
    );
  }
}
