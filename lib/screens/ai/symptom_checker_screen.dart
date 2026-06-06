import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/ai_service.dart';
import '../../services/ai_session_service.dart';

class SymptomCheckerScreen extends StatefulWidget {
  const SymptomCheckerScreen({super.key});
  @override
  State<SymptomCheckerScreen> createState() => _SymptomCheckerScreenState();
}

class _SymptomCheckerScreenState extends State<SymptomCheckerScreen>
    with TickerProviderStateMixin {
  final _symptomCtrl = TextEditingController();
  final _petNameCtrl = TextEditingController(text: 'Max');

  String _selectedPetType = 'Dog';
  String _selectedBreed = 'Golden Retriever';
  int _selectedAge = 3;

  bool _loading = false;
  String? _error;
  Map<String, dynamic>? _result;

  late final AnimationController _gaugeAnim;
  late Animation<double> _gaugeValue;

  static const _purple = Color(0xFF8B5CF6);
  static const _purpleLight = Color(0xFFF3EFFE);
  static const _green = Color(0xFF1D9E75);
  static const _greenLight = Color(0xFFE1F5EE);
  static const _textMain = Color(0xFF0A2E24);
  static const _textMuted = Color(0xFF6B8F80);
  static const _bgPage = Color(0xFFF4FAF7);

  @override
  void initState() {
    super.initState();
    _gaugeAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _gaugeValue = Tween<double>(begin: 0, end: 0)
        .animate(CurvedAnimation(parent: _gaugeAnim, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _gaugeAnim.dispose();
    _symptomCtrl.dispose();
    _petNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _analyze() async {
    if (_symptomCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Please describe your pet\'s symptoms.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
      _result = null;
    });

    try {
      final result = await AiService.analyzeSymptoms(
        symptoms: _symptomCtrl.text.trim(),
        petName: _petNameCtrl.text.trim().isEmpty
            ? 'My pet'
            : _petNameCtrl.text.trim(),
        petType: _selectedPetType,
        breed: _selectedBreed,
        ageYears: _selectedAge,
      );
      setState(() => _result = result);

      // ── Animate gauge ──────────────────────────
      final score = (result['risk_score'] as int).toDouble();
      _gaugeAnim.reset();
      _gaugeValue = Tween<double>(begin: 0, end: score / 100)
          .animate(CurvedAnimation(parent: _gaugeAnim, curve: Curves.easeOut));
      _gaugeAnim.forward();

      // ── Save AI session to Firestore ───────────
      await AiSessionService.saveSession(
        type: 'symptom',
        petName: _petNameCtrl.text.trim().isEmpty
            ? 'My pet'
            : _petNameCtrl.text.trim(),
        petType: _selectedPetType,
        riskScore: result['risk_score'] as int,
        riskLevel: result['risk_level'] as String,
      );
    } catch (e) {
      setState(() => _error = 'Error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Color _riskColor(String level) => switch (level.toLowerCase()) {
        'low' => const Color(0xFF16A34A),
        'medium' => const Color(0xFFD97706),
        'high' => const Color(0xFFDC2626),
        'critical' => const Color(0xFF7C3AED),
        _ => _green,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgPage,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('AI Symptom Checker',
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
            _buildAiBadge(),
            const SizedBox(height: 20),
            _buildPetInfoCard(),
            const SizedBox(height: 16),
            _buildSymptomInput(),
            const SizedBox(height: 16),
            _buildAnalyzeButton(),
            if (_error != null) ...[
              const SizedBox(height: 12),
              _buildErrorBox(),
            ],
            if (_loading) ...[
              const SizedBox(height: 32),
              _buildLoadingIndicator(),
            ],
            if (_result != null) ...[
              const SizedBox(height: 24),
              _buildRiskGauge(),
              const SizedBox(height: 16),
              _buildExplanationCard(),
              const SizedBox(height: 16),
              _buildSymptomsCard(),
              const SizedBox(height: 16),
              _buildCausesCard(),
              const SizedBox(height: 16),
              _buildCarePlanCard(),
              const SizedBox(height: 32),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAiBadge() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: _purpleLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _purple.withValues(alpha: 0.2))),
      child: Row(children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
              color: _purple, borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.smart_toy_rounded,
              color: Colors.white, size: 24),
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
                      color: _purple)),
              Text('NLP symptom extraction + risk scoring',
                  style: GoogleFonts.nunito(
                      fontSize: 11, color: const Color(0xFF6D3FC8))),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _buildPetInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5F0EA))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pet information',
              style: GoogleFonts.nunito(
                  fontSize: 14, fontWeight: FontWeight.w700, color: _textMain)),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(
                child: _infoField('Pet name', _petNameCtrl, hint: 'e.g. Max')),
            const SizedBox(width: 12),
            Expanded(
                child: _dropdownField('Type',
                    value: _selectedPetType,
                    items: ['Dog', 'Cat', 'Bird', 'Rabbit', 'Other'],
                    onChanged: (v) => setState(() => _selectedPetType = v!))),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
                child: _dropdownField('Breed',
                    value: _selectedBreed,
                    items: [
                      'Golden Retriever',
                      'Labrador',
                      'German Shepherd',
                      'Persian Cat',
                      'Siamese',
                      'Maine Coon',
                      'Mixed',
                      'Other'
                    ],
                    onChanged: (v) => setState(() => _selectedBreed = v!))),
            const SizedBox(width: 12),
            Expanded(
                child: _dropdownField('Age (yrs)',
                    value: _selectedAge.toString(),
                    items: List.generate(20, (i) => (i + 1).toString()),
                    onChanged: (v) =>
                        setState(() => _selectedAge = int.parse(v!)))),
          ]),
        ],
      ),
    );
  }

  Widget _infoField(String label, TextEditingController ctrl,
      {String hint = ''}) {
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

  Widget _dropdownField(String label,
      {required String value,
      required List<String> items,
      required void Function(String?) onChanged}) {
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

  Widget _buildSymptomInput() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5F0EA))),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Describe symptoms',
              style: GoogleFonts.nunito(
                  fontSize: 14, fontWeight: FontWeight.w700, color: _textMain)),
          const SizedBox(height: 4),
          Text('Be as detailed as possible for better AI analysis',
              style: GoogleFonts.nunito(fontSize: 12, color: _textMuted)),
          const SizedBox(height: 12),
          TextFormField(
            controller: _symptomCtrl,
            maxLines: 5,
            style: GoogleFonts.nunito(fontSize: 14, color: _textMain),
            decoration: InputDecoration(
              hintText: 'e.g. My dog has been vomiting since morning, '
                  'not eating, seems lethargic and is drinking '
                  'a lot of water...',
              hintStyle: TextStyle(
                  color: _textMuted.withValues(alpha: 0.5),
                  fontSize: 13,
                  height: 1.5),
              filled: true,
              fillColor: const Color(0xFFF8FDFB),
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFD6EDE5))),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFD6EDE5))),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _purple, width: 1.5)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyzeButton() {
    return SizedBox(
      height: 54,
      child: ElevatedButton.icon(
        onPressed: _loading ? null : _analyze,
        style: ElevatedButton.styleFrom(
          backgroundColor: _purple,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _purple.withValues(alpha: 0.6),
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        icon: const Icon(Icons.biotech_rounded, size: 20),
        label: Text('Analyze with AI',
            style:
                GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _buildErrorBox() {
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
                    const TextStyle(fontSize: 13, color: Color(0xFFDC2626)))),
      ]),
    );
  }

  Widget _buildLoadingIndicator() {
    return Column(children: [
      const CircularProgressIndicator(color: _purple),
      const SizedBox(height: 16),
      Text('AI is analyzing symptoms...',
          style: GoogleFonts.nunito(fontSize: 14, color: _textMuted)),
      const SizedBox(height: 4),
      Text('Extracting symptoms · Scoring risk · Generating plan',
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(fontSize: 12, color: _textMuted)),
    ]);
  }

  Widget _buildRiskGauge() {
    final score = _result!['risk_score'] as int;
    final level = _result!['risk_level'] as String;
    final color = _riskColor(level);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5F0EA))),
      child: Column(children: [
        Text('Risk Assessment',
            style: GoogleFonts.nunito(
                fontSize: 16, fontWeight: FontWeight.w800, color: _textMain)),
        const SizedBox(height: 20),
        AnimatedBuilder(
          animation: _gaugeAnim,
          builder: (_, __) {
            return Stack(alignment: Alignment.center, children: [
              SizedBox(
                width: 160,
                height: 160,
                child: CircularProgressIndicator(
                  value: _gaugeValue.value,
                  strokeWidth: 14,
                  backgroundColor: color.withValues(alpha: 0.12),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(mainAxisSize: MainAxisSize.min, children: [
                Text('$score',
                    style: GoogleFonts.nunito(
                        fontSize: 44,
                        fontWeight: FontWeight.w900,
                        color: color)),
                Text('/ 100',
                    style: GoogleFonts.nunito(fontSize: 14, color: _textMuted)),
              ]),
            ]);
          },
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20)),
          child: Text(level.toUpperCase(),
              style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: color,
                  letterSpacing: 1)),
        ),
      ]),
    );
  }

  Widget _buildExplanationCard() {
    return _sectionCard(
      icon: Icons.info_outline_rounded,
      iconColor: const Color(0xFF0891B2),
      iconBg: const Color(0xFFE0F7FA),
      title: 'AI Analysis',
      child: Text(_result!['explanation'] as String,
          style:
              GoogleFonts.nunito(fontSize: 14, color: _textMain, height: 1.6)),
    );
  }

  Widget _buildSymptomsCard() {
    final symptoms = (_result!['extracted_symptoms'] as List).cast<String>();
    return _sectionCard(
      icon: Icons.search_rounded,
      iconColor: _purple,
      iconBg: _purpleLight,
      title: 'Detected symptoms',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: symptoms
            .map((s) => Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                      color: _purpleLight,
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(s,
                      style: GoogleFonts.nunito(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _purple)),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildCausesCard() {
    final causes = (_result!['possible_causes'] as List).cast<String>();
    return _sectionCard(
      icon: Icons.biotech_rounded,
      iconColor: const Color(0xFFD97706),
      iconBg: const Color(0xFFFFF7ED),
      title: 'Possible causes',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: causes
            .asMap()
            .entries
            .map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            width: 22,
                            height: 22,
                            margin: const EdgeInsets.only(right: 10, top: 1),
                            decoration: BoxDecoration(
                                color: const Color(0xFFFFF7ED),
                                borderRadius: BorderRadius.circular(6)),
                            child: Center(
                                child: Text('${e.key + 1}',
                                    style: GoogleFonts.nunito(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFFD97706))))),
                        Expanded(
                            child: Text(e.value,
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

  Widget _buildCarePlanCard() {
    final plan = _result!['care_plan'] as Map<String, dynamic>;
    return _sectionCard(
      icon: Icons.calendar_today_rounded,
      iconColor: _green,
      iconBg: _greenLight,
      title: 'Personalized care plan',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _carePlanSection(
              'Today', (plan['today'] as List).cast<String>(), _green),
          const SizedBox(height: 14),
          _carePlanSection(
              'Next 48 hours',
              (plan['next_48_hours'] as List).cast<String>(),
              const Color(0xFF0891B2)),
          const SizedBox(height: 14),
          _carePlanSection(
              'See vet immediately if',
              (plan['see_vet_if'] as List).cast<String>(),
              const Color(0xFFDC2626)),
        ],
      ),
    );
  }

  Widget _carePlanSection(String title, List<String> items, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: GoogleFonts.nunito(
                fontSize: 13, fontWeight: FontWeight.w700, color: color)),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(Icons.check_circle_outline_rounded,
                    size: 16, color: color),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(item,
                        style: GoogleFonts.nunito(
                            fontSize: 13, color: _textMain, height: 1.4))),
              ]),
            )),
      ],
    );
  }

  Widget _sectionCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required Widget child,
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
}
