import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/pet_service.dart';

class PetDetailScreen extends StatelessWidget {
  final Pet pet;
  const PetDetailScreen({super.key, required this.pet});

  static const _green = Color(0xFF1D9E75);
  static const _greenLight = Color(0xFFE1F5EE);
  static const _textMain = Color(0xFF0A2E24);
  static const _textMuted = Color(0xFF6B8F80);

  Color get _typeColor => switch (pet.type) {
        'Dog' => const Color(0xFFEA580C),
        'Cat' => const Color(0xFF8B5CF6),
        'Bird' => const Color(0xFF0891B2),
        'Rabbit' => const Color(0xFF16A34A),
        _ => _green,
      };

  Color get _typeBg => switch (pet.type) {
        'Dog' => const Color(0xFFFFF7ED),
        'Cat' => const Color(0xFFF3EFFE),
        'Bird' => const Color(0xFFE0F7FA),
        'Rabbit' => const Color(0xFFDCFCE7),
        _ => _greenLight,
      };

  IconData get _typeIcon => switch (pet.type) {
        'Cat' => Icons.catching_pokemon_rounded,
        'Bird' => Icons.flutter_dash_rounded,
        'Rabbit' => Icons.cruelty_free_rounded,
        _ => Icons.pets_rounded,
      };

  String get _typeEmoji => switch (pet.type) {
        'Dog' => '🐕',
        'Cat' => '🐈',
        'Bird' => '🐦',
        'Rabbit' => '🐇',
        _ => '🐾',
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FAF7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(pet.name,
            style: GoogleFonts.nunito(
                fontSize: 18, fontWeight: FontWeight.w800, color: _textMain)),
        leading: IconButton(
            icon:
                const Icon(Icons.arrow_back_rounded, color: Color(0xFF0A2E24)),
            onPressed: () => Navigator.pop(context)),
        actions: [
          IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  color: Color(0xFFDC2626)),
              onPressed: () => _confirmDelete(context)),
        ],
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
            // Pet avatar card
            Container(
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                  color: _typeBg, borderRadius: BorderRadius.circular(20)),
              child: Column(children: [
                Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                        color: _typeColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle),
                    child: Icon(_typeIcon, size: 44, color: _typeColor)),
                const SizedBox(height: 14),
                Text('${_typeEmoji} ${pet.name}',
                    style: GoogleFonts.nunito(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: _textMain)),
                const SizedBox(height: 4),
                Text(pet.type,
                    style: GoogleFonts.nunito(
                        fontSize: 14,
                        color: _typeColor,
                        fontWeight: FontWeight.w600)),
              ]),
            ),

            const SizedBox(height: 16),

            // Basic info
            _infoCard(title: 'Basic information', items: [
              _infoRow(Icons.pets_rounded, 'Breed',
                  pet.breed.isEmpty ? 'Not specified' : pet.breed, _typeColor),
              _infoRow(
                  Icons.cake_rounded,
                  'Age',
                  '${pet.age} year${pet.age > 1 ? 's' : ''}',
                  const Color(0xFF0891B2)),
              _infoRow(
                  Icons.monitor_weight_outlined,
                  'Weight',
                  '${pet.weight.toStringAsFixed(1)} kg',
                  const Color(0xFF8B5CF6)),
            ]),

            const SizedBox(height: 14),

            // Care schedule
            if ((pet.vaccineDate != null && pet.vaccineDate!.isNotEmpty) ||
                (pet.mealTime != null && pet.mealTime!.isNotEmpty))
              _infoCard(title: 'Care schedule', items: [
                if (pet.vaccineDate != null && pet.vaccineDate!.isNotEmpty)
                  _infoRow(Icons.vaccines_rounded, 'Next vaccine',
                      pet.vaccineDate!, const Color(0xFF8B5CF6)),
                if (pet.mealTime != null && pet.mealTime!.isNotEmpty)
                  _infoRow(Icons.restaurant_rounded, 'Meal time', pet.mealTime!,
                      const Color(0xFFEA580C)),
              ]),

            if ((pet.vaccineDate != null && pet.vaccineDate!.isNotEmpty) ||
                (pet.mealTime != null && pet.mealTime!.isNotEmpty))
              const SizedBox(height: 14),

            // Notes
            if (pet.notes != null && pet.notes!.isNotEmpty) ...[
              Container(
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
                              color: _greenLight,
                              borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.notes_rounded,
                              size: 18, color: _green)),
                      const SizedBox(width: 10),
                      Text('Notes',
                          style: GoogleFonts.nunito(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _textMain)),
                    ]),
                    const SizedBox(height: 12),
                    Text(pet.notes!,
                        style: GoogleFonts.nunito(
                            fontSize: 14, color: _textMuted, height: 1.6)),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            // AI Care buttons
            _infoCard(title: 'AI care tools', items: [
              _actionRow(
                  context,
                  Icons.medical_services_rounded,
                  'Check symptoms',
                  'AI symptom analysis',
                  const Color(0xFF8B5CF6),
                  const Color(0xFFF3EFFE),
                  () => Navigator.pushNamed(context, '/symptom-checker')),
              _actionRow(
                  context,
                  Icons.calendar_today_rounded,
                  'Generate care plan',
                  'Personalized AI plan',
                  _green,
                  _greenLight,
                  () => Navigator.pushNamed(context, '/care-planner')),
            ]),

            const SizedBox(height: 24),

            // Delete button
            OutlinedButton.icon(
              onPressed: () => _confirmDelete(context),
              style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFDC2626),
                  side: const BorderSide(color: Color(0xFFDC2626)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14))),
              icon: const Icon(Icons.delete_outline_rounded, size: 18),
              label: Text('Remove ${pet.name}',
                  style: GoogleFonts.nunito(
                      fontSize: 14, fontWeight: FontWeight.w700)),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _infoCard({required String title, required List<Widget> items}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5F0EA))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.nunito(
                  fontSize: 14, fontWeight: FontWeight.w700, color: _textMain)),
          const SizedBox(height: 12),
          ...items,
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 18, color: color)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: GoogleFonts.nunito(fontSize: 11, color: _textMuted)),
              Text(value,
                  style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _textMain)),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _actionRow(BuildContext context, IconData icon, String label,
      String subtitle, Color color, Color bg, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration:
              BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
          child: Row(children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: GoogleFonts.nunito(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _textMain)),
                  Text(subtitle,
                      style:
                          GoogleFonts.nunito(fontSize: 11, color: _textMuted)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: color.withValues(alpha: 0.5)),
          ]),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Remove ${pet.name}?',
            style: GoogleFonts.nunito(
                fontWeight: FontWeight.w800, color: _textMain)),
        content: Text(
            'This will permanently delete ${pet.name}\'s profile and all related data.',
            style: GoogleFonts.nunito(color: _textMuted)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel',
                  style: GoogleFonts.nunito(
                      color: _textMuted, fontWeight: FontWeight.w600))),
          ElevatedButton(
              onPressed: () async {
                await PetService.deletePet(pet.id);
                if (context.mounted) {
                  Navigator.pop(context); // close dialog
                  Navigator.pop(context); // go back to home
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              child: Text('Remove',
                  style: GoogleFonts.nunito(fontWeight: FontWeight.w700))),
        ],
      ),
    );
  }
}
