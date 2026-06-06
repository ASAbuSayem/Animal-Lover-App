import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert';
import '../../core/constants/api_constants.dart';
import '../../services/ai_session_service.dart';

class CarePlannerScreen extends StatefulWidget {
  const CarePlannerScreen({super.key});
  @override
  State<CarePlannerScreen> createState() => _CarePlannerScreenState();
}

class _CarePlannerScreenState extends State<CarePlannerScreen>
    with TickerProviderStateMixin {
  final _nameCtrl = TextEditingController(text: 'Max');
  String _petType = 'Dog';
  String _breed = 'Golden Retriever';
  int _age = 3;
  double _weight = 28;
  String _activity = 'Moderate';

  bool _loading = false;
  String? _error;
  Map<String, dynamic>? _plan;

  late final AnimationController _cardAnim;
  late final Animation<double> _cardFade;
  late final Animation<Offset> _cardSlide;

  static const _green = Color(0xFF1D9E75);
  static const _greenLight = Color(0xFFE1F5EE);
  static const _greenMid = Color(0xFF9FE1CB);
  static const _purple = Color(0xFF8B5CF6);
  static const _blue = Color(0xFF0891B2);
  static const _orange = Color(0xFFEA580C);
  static const _bgPage = Color(0xFFF4FAF7);
  static const _textMain = Color(0xFF0A2E24);
  static const _textMuted = Color(0xFF6B8F80);

  @override
  void initState() {
    super.initState();
    _cardAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _cardFade = CurvedAnimation(parent: _cardAnim, curve: Curves.easeOut);
    _cardSlide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _cardAnim, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _cardAnim.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _generatePlan() async {
    setState(() {
      _loading = true;
      _error = null;
      _plan = null;
    });

    try {
      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: ApiConstants.geminiApiKey,
      );

      final petName =
          _nameCtrl.text.trim().isEmpty ? 'My pet' : _nameCtrl.text.trim();

      final prompt = '''
You are an expert veterinary nutritionist and pet care specialist.
Generate a complete personalized care plan for the following pet.

Pet Details:
- Name: $petName
- Type: $_petType
- Breed: $_breed
- Age: $_age years
- Weight: ${_weight.toStringAsFixed(1)} kg
- Activity level: $_activity

Respond ONLY with valid JSON (no markdown, no code blocks):
{
  "daily_calories": <integer>,
  "meals_per_day": <integer>,
  "meal_schedule": [
    {"time": "Morning 7:00 AM", "portion": "200g dry food", "notes": "Add warm water"},
    {"time": "Evening 6:00 PM", "portion": "200g dry food", "notes": "With supplements"}
  ],
  "recommended_foods": ["food1", "food2", "food3", "food4"],
  "foods_to_avoid": ["food1", "food2", "food3"],
  "exercise": {
    "daily_minutes": <integer>,
    "type": "description of exercise type",
    "frequency": "e.g. twice daily"
  },
  "grooming": {
    "bath_frequency": "e.g. every 2 weeks",
    "brush_frequency": "e.g. daily",
    "nail_trim": "e.g. monthly",
    "dental": "e.g. brush 3x per week"
  },
  "vaccines_due": [
    {"name": "Rabies", "due_date": "July 2026", "notes": "Annual booster"},
    {"name": "DHPP", "due_date": "September 2026", "notes": "Triennial"}
  ],
  "health_tips": ["tip1", "tip2", "tip3", "tip4"],
  "vet_checkup": "Recommended schedule e.g. Every 6 months"
}
''';

      final response = await model.generateContent([Content.text(prompt)]);
      final text = response.text ?? '';
      final cleaned =
          text.replaceAll('```json', '').replaceAll('```', '').trim();

      setState(() => _plan = jsonDecode(cleaned) as Map<String, dynamic>);
      _cardAnim.reset();
      _cardAnim.forward();

      // ── Save AI session to Firestore ─────────
      await AiSessionService.saveSession(
        type: 'care',
        petName: petName,
        petType: _petType,
      );
    } catch (e) {
      setState(() => _error = 'Failed to generate plan: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgPage,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('AI Care Planner',
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
            _buildAiBanner(),
            const SizedBox(height: 20),
            _buildPetForm(),
            const SizedBox(height: 20),
            _buildGenerateButton(),
            if (_error != null) ...[
              const SizedBox(height: 12),
              _buildError(),
            ],
            if (_loading) ...[
              const SizedBox(height: 40),
              _buildLoader(),
            ],
            if (_plan != null) ...[
              const SizedBox(height: 24),
              FadeTransition(
                opacity: _cardFade,
                child: SlideTransition(
                  position: _cardSlide,
                  child: _buildPlanResults(),
                ),
              ),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildAiBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: _greenLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _greenMid)),
      child: Row(children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
              color: _green, borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.calendar_today_rounded,
              color: Colors.white, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Powered by Fooggle',
                  style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _green)),
              Text('Personalized nutrition, exercise & health plan',
                  style: GoogleFonts.nunito(
                      fontSize: 11, color: const Color(0xFF2D6E56))),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _buildPetForm() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5F0EA))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pet details',
              style: GoogleFonts.nunito(
                  fontSize: 15, fontWeight: FontWeight.w800, color: _textMain)),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _textField('Pet name', _nameCtrl, 'e.g. Max')),
            const SizedBox(width: 12),
            Expanded(
                child: _dropdown(
                    'Type',
                    _petType,
                    ['Dog', 'Cat', 'Bird', 'Rabbit', 'Other'],
                    (v) => setState(() => _petType = v!))),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(
                child: _dropdown(
                    'Breed',
                    _breed,
                    [
                      'Golden Retriever',
                      'Labrador',
                      'German Shepherd',
                      'Persian Cat',
                      'Siamese',
                      'Maine Coon',
                      'Beagle',
                      'Poodle',
                      'Mixed',
                      'Other'
                    ],
                    (v) => setState(() => _breed = v!))),
            const SizedBox(width: 12),
            Expanded(
                child: _dropdown(
                    'Age (yrs)',
                    _age.toString(),
                    List.generate(20, (i) => (i + 1).toString()),
                    (v) => setState(() => _age = int.parse(v!)))),
          ]),
          const SizedBox(height: 14),
          Text('Weight: ${_weight.toStringAsFixed(1)} kg',
              style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _textMuted)),
          const SizedBox(height: 4),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: _green,
              thumbColor: _green,
              inactiveTrackColor: _greenMid.withValues(alpha: 0.3),
              overlayColor: _green.withValues(alpha: 0.1),
              trackHeight: 4,
            ),
            child: Slider(
              value: _weight,
              min: 0.5,
              max: 80,
              onChanged: (v) => setState(() => _weight = v),
            ),
          ),
          const SizedBox(height: 14),
          Text('Activity level',
              style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _textMuted)),
          const SizedBox(height: 8),
          Row(
            children: ['Low', 'Moderate', 'High', 'Very Active']
                .map((a) => Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _activity = a),
                        child: Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                              color: _activity == a ? _green : _greenLight,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: _activity == a ? _green : _greenMid)),
                          child: Text(a,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.nunito(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color:
                                      _activity == a ? Colors.white : _green)),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateButton() {
    return SizedBox(
      height: 54,
      child: ElevatedButton.icon(
        onPressed: _loading ? null : _generatePlan,
        style: ElevatedButton.styleFrom(
          backgroundColor: _green,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _green.withValues(alpha: 0.6),
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        icon: const Icon(Icons.auto_awesome_rounded, size: 20),
        label: Text('Generate care plan',
            style:
                GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _buildLoader() {
    return Column(children: [
      const CircularProgressIndicator(color: _green),
      const SizedBox(height: 16),
      Text('Generating personalized plan...',
          style: GoogleFonts.nunito(fontSize: 14, color: _textMuted)),
      const SizedBox(height: 4),
      Text('Nutrition · Exercise · Health schedule',
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(fontSize: 12, color: _textMuted)),
    ]);
  }

  Widget _buildError() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: const Color(0xFFDC2626).withValues(alpha: 0.3))),
      child: Row(children: [
        const Icon(Icons.error_outline_rounded,
            size: 16, color: Color(0xFFDC2626)),
        const SizedBox(width: 8),
        Expanded(
            child: Text(_error!,
                style:
                    const TextStyle(fontSize: 12.5, color: Color(0xFFDC2626)))),
      ]),
    );
  }

  Widget _buildPlanResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildNutritionCard(),
        const SizedBox(height: 14),
        _buildMealScheduleCard(),
        const SizedBox(height: 14),
        _buildFoodsCard(),
        const SizedBox(height: 14),
        _buildExerciseCard(),
        const SizedBox(height: 14),
        _buildGroomingCard(),
        const SizedBox(height: 14),
        _buildVaccineCard(),
        const SizedBox(height: 14),
        _buildHealthTipsCard(),
      ],
    );
  }

  Widget _buildNutritionCard() {
    final cals = _plan!['daily_calories'] as int;
    final meals = _plan!['meals_per_day'] as int;
    final vet = _plan!['vet_checkup'] as String;
    return _card(
      icon: Icons.local_fire_department_rounded,
      iconColor: _orange,
      iconBg: const Color(0xFFFFF0E6),
      title: 'Daily nutrition summary',
      child: Row(children: [
        _statBox(
            '$cals kcal', 'Daily calories', _orange, const Color(0xFFFFF0E6)),
        const SizedBox(width: 10),
        _statBox('$meals meals', 'Per day', _blue, const Color(0xFFE0F7FA)),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: _greenLight, borderRadius: BorderRadius.circular(10)),
            child: Column(children: [
              const Icon(Icons.medical_services_outlined,
                  size: 18, color: _green),
              const SizedBox(height: 4),
              Text('Vet visit',
                  style: GoogleFonts.nunito(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: _textMuted)),
              Text(vet,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: GoogleFonts.nunito(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _green)),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _statBox(String val, String label, Color fg, Color bg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
        child: Column(children: [
          Text(val,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                  fontSize: 14, fontWeight: FontWeight.w800, color: fg)),
          Text(label,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(fontSize: 10, color: _textMuted)),
        ]),
      ),
    );
  }

  Widget _buildMealScheduleCard() {
    final meals =
        (_plan!['meal_schedule'] as List).cast<Map<String, dynamic>>();
    return _card(
      icon: Icons.restaurant_rounded,
      iconColor: _orange,
      iconBg: const Color(0xFFFFF0E6),
      title: 'Meal schedule',
      child: Column(
        children: meals
            .asMap()
            .entries
            .map((e) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: const Color(0xFFFFF9F5),
                      borderRadius: BorderRadius.circular(10),
                      border:
                          Border.all(color: _orange.withValues(alpha: 0.2))),
                  child: Row(children: [
                    Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                            color: _orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8)),
                        child: Center(
                            child: Text('${e.key + 1}',
                                style: GoogleFonts.nunito(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: _orange)))),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.value['time'] as String,
                            style: GoogleFonts.nunito(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _textMain)),
                        Text(e.value['portion'] as String,
                            style: GoogleFonts.nunito(
                                fontSize: 12, color: _textMuted)),
                        if ((e.value['notes'] as String).isNotEmpty)
                          Text(e.value['notes'] as String,
                              style: GoogleFonts.nunito(
                                  fontSize: 11,
                                  color: _orange,
                                  fontStyle: FontStyle.italic)),
                      ],
                    )),
                  ]),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildFoodsCard() {
    final good = (_plan!['recommended_foods'] as List).cast<String>();
    final bad = (_plan!['foods_to_avoid'] as List).cast<String>();
    return _card(
      icon: Icons.food_bank_rounded,
      iconColor: _green,
      iconBg: _greenLight,
      title: 'Food guide',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('✅ Recommended',
              style: GoogleFonts.nunito(
                  fontSize: 12, fontWeight: FontWeight.w700, color: _green)),
          const SizedBox(height: 8),
          Wrap(
              spacing: 8,
              runSpacing: 6,
              children:
                  good.map((f) => _chip(f, _green, _greenLight)).toList()),
          const SizedBox(height: 14),
          Text('❌ Avoid',
              style: GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFDC2626))),
          const SizedBox(height: 8),
          Wrap(
              spacing: 8,
              runSpacing: 6,
              children: bad
                  .map((f) => _chip(
                      f, const Color(0xFFDC2626), const Color(0xFFFEF2F2)))
                  .toList()),
        ],
      ),
    );
  }

  Widget _buildExerciseCard() {
    final ex = _plan!['exercise'] as Map<String, dynamic>;
    return _card(
      icon: Icons.directions_run_rounded,
      iconColor: _purple,
      iconBg: const Color(0xFFF3EFFE),
      title: 'Exercise plan',
      child: Row(children: [
        _statBox('${ex['daily_minutes']} min', 'Daily', _purple,
            const Color(0xFFF3EFFE)),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(ex['type'] as String,
                  style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _textMain,
                      height: 1.4)),
              const SizedBox(height: 4),
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: const Color(0xFFF3EFFE),
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(ex['frequency'] as String,
                      style: GoogleFonts.nunito(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _purple))),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _buildGroomingCard() {
    final g = _plan!['grooming'] as Map<String, dynamic>;
    final items = [
      {
        'icon': Icons.water_drop_outlined,
        'label': 'Bath',
        'val': g['bath_frequency']
      },
      {
        'icon': Icons.brush_rounded,
        'label': 'Brush',
        'val': g['brush_frequency']
      },
      {
        'icon': Icons.content_cut_rounded,
        'label': 'Nails',
        'val': g['nail_trim']
      },
      {
        'icon': Icons.clean_hands_rounded,
        'label': 'Dental',
        'val': g['dental']
      },
    ];
    return _card(
      icon: Icons.spa_rounded,
      iconColor: _blue,
      iconBg: const Color(0xFFE0F7FA),
      title: 'Grooming schedule',
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.4,
        children: items
            .map((item) => Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                      color: const Color(0xFFE0F7FA),
                      borderRadius: BorderRadius.circular(10)),
                  child: Row(children: [
                    Icon(item['icon'] as IconData, size: 18, color: _blue),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(item['label'] as String,
                            style: GoogleFonts.nunito(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: _textMuted)),
                        Text(item['val'] as String,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.nunito(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _blue)),
                      ],
                    )),
                  ]),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildVaccineCard() {
    final vaccines =
        (_plan!['vaccines_due'] as List).cast<Map<String, dynamic>>();
    return _card(
      icon: Icons.vaccines_rounded,
      iconColor: const Color(0xFF7C3AED),
      iconBg: const Color(0xFFF5F3FF),
      title: 'Upcoming vaccines',
      child: Column(
        children: vaccines
            .map((v) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: const Color(0xFFF5F3FF),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color:
                              const Color(0xFF7C3AED).withValues(alpha: 0.2))),
                  child: Row(children: [
                    const Icon(Icons.vaccines_rounded,
                        size: 20, color: Color(0xFF7C3AED)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(v['name'] as String,
                            style: GoogleFonts.nunito(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _textMain)),
                        Text(v['notes'] as String,
                            style: GoogleFonts.nunito(
                                fontSize: 11, color: _textMuted)),
                      ],
                    )),
                    Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: const Color(0xFF7C3AED)
                                    .withValues(alpha: 0.3))),
                        child: Text(v['due_date'] as String,
                            style: GoogleFonts.nunito(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF7C3AED)))),
                  ]),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildHealthTipsCard() {
    final tips = (_plan!['health_tips'] as List).cast<String>();
    return _card(
      icon: Icons.tips_and_updates_rounded,
      iconColor: _orange,
      iconBg: const Color(0xFFFFF0E6),
      title: 'Health tips',
      child: Column(
        children: tips
            .map((tip) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            width: 24,
                            height: 24,
                            margin: const EdgeInsets.only(right: 10, top: 1),
                            decoration: const BoxDecoration(
                                color: Color(0xFFFFF0E6),
                                shape: BoxShape.circle),
                            child: const Icon(Icons.lightbulb_outline_rounded,
                                size: 14, color: _orange)),
                        Expanded(
                            child: Text(tip,
                                style: GoogleFonts.nunito(
                                    fontSize: 13,
                                    color: _textMain,
                                    height: 1.5))),
                      ]),
                ))
            .toList(),
      ),
    );
  }

  Widget _card(
      {required IconData icon,
      required Color iconColor,
      required Color iconBg,
      required String title,
      required Widget child}) {
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
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 10),
            Text(title,
                style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _textMain)),
          ]),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _chip(String label, Color fg, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: GoogleFonts.nunito(
              fontSize: 12, fontWeight: FontWeight.w600, color: fg)),
    );
  }

  Widget _textField(String label, TextEditingController ctrl, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.nunito(
                fontSize: 12, fontWeight: FontWeight.w600, color: _textMuted)),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          style: GoogleFonts.nunito(fontSize: 13, color: _textMain),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
                color: _textMuted.withValues(alpha: 0.5), fontSize: 13),
            filled: true,
            fillColor: const Color(0xFFF8FDFB),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFD6EDE5))),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFD6EDE5))),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _green, width: 1.5)),
          ),
        ),
      ],
    );
  }

  Widget _dropdown(String label, String value, List<String> items,
      void Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.nunito(
                fontSize: 12, fontWeight: FontWeight.w600, color: _textMuted)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          decoration: BoxDecoration(
              color: const Color(0xFFF8FDFB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFD6EDE5))),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: items.contains(value) ? value : items.first,
              isExpanded: true,
              style: GoogleFonts.nunito(fontSize: 13, color: _textMain),
              items: items
                  .map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(e, style: GoogleFonts.nunito(fontSize: 13))))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
