import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/ai_session_service.dart';

class AiHistoryScreen extends StatelessWidget {
  const AiHistoryScreen({super.key});

  static const _green = Color(0xFF1D9E75);
  static const _greenLight = Color(0xFFE1F5EE);
  static const _purple = Color(0xFF8B5CF6);
  static const _textMain = Color(0xFF0A2E24);
  static const _textMuted = Color(0xFF6B8F80);

  Color _riskColor(String level) => switch (level.toLowerCase()) {
        'low' => const Color(0xFF16A34A),
        'medium' => const Color(0xFFD97706),
        'high' => const Color(0xFFDC2626),
        'critical' => const Color(0xFF7C3AED),
        _ => _green,
      };

  String _formatDate(Timestamp ts) {
    final dt = ts.toDate();
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
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}  '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FAF7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('AI history',
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
        stream: AiSessionService.sessionsStream(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF8B5CF6)));
          }

          final sessions = snap.data ?? [];

          if (sessions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                          color: const Color(0xFFF3EFFE),
                          shape: BoxShape.circle),
                      child: const Icon(Icons.smart_toy_outlined,
                          size: 40, color: Color(0xFF8B5CF6))),
                  const SizedBox(height: 16),
                  Text('No AI sessions yet',
                      style: GoogleFonts.nunito(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: _textMain)),
                  const SizedBox(height: 6),
                  Text(
                      'Use Symptom Checker or Care Planner\nto see your history here',
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
            itemCount: sessions.length,
            itemBuilder: (_, i) {
              final s = sessions[i];
              final isSymptom = s['type'] == 'symptom';
              final color = isSymptom ? _purple : _green;
              final bg = isSymptom ? const Color(0xFFF3EFFE) : _greenLight;
              final icon = isSymptom
                  ? Icons.medical_services_rounded
                  : Icons.calendar_today_rounded;
              final riskScore = s['riskScore'] as int?;
              final riskLevel = s['riskLevel'] as String? ?? '';
              final petName = s['petName'] as String? ?? 'Unknown';
              final createdAt = s['createdAt'] as Timestamp?;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE5F0EA))),
                child: Row(children: [
                  Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                          color: bg, borderRadius: BorderRadius.circular(12)),
                      child: Icon(icon, size: 24, color: color)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(isSymptom ? 'Symptom Check' : 'Care Plan',
                            style: GoogleFonts.nunito(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: _textMain)),
                        const SizedBox(height: 2),
                        Text('Pet: $petName',
                            style: GoogleFonts.nunito(
                                fontSize: 12, color: _textMuted)),
                        if (createdAt != null) ...[
                          const SizedBox(height: 2),
                          Text(_formatDate(createdAt),
                              style: GoogleFonts.nunito(
                                  fontSize: 11, color: _textMuted)),
                        ],
                      ],
                    ),
                  ),
                  if (isSymptom && riskScore != null)
                    Column(children: [
                      Text('$riskScore',
                          style: GoogleFonts.nunito(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: _riskColor(riskLevel))),
                      Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                              color:
                                  _riskColor(riskLevel).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20)),
                          child: Text(riskLevel.toUpperCase(),
                              style: GoogleFonts.nunito(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: _riskColor(riskLevel)))),
                    ])
                  else if (!isSymptom)
                    Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                            color: _greenLight,
                            borderRadius: BorderRadius.circular(20)),
                        child: Text('Done',
                            style: GoogleFonts.nunito(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _green))),
                ]),
              );
            },
          );
        },
      ),
    );
  }
}
