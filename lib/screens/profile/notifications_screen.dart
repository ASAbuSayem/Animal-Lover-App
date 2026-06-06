import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/pet_service.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static const _green = Color(0xFF1D9E75);
  static const _greenLight = Color(0xFFE1F5EE);
  static const _textMain = Color(0xFF0A2E24);
  static const _textMuted = Color(0xFF6B8F80);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FAF7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Notifications',
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
      body: StreamBuilder<List<Pet>>(
        stream: PetService.petsStream(),
        builder: (context, snap) {
          final pets = snap.data ?? [];
          final items = <Map<String, dynamic>>[];

          for (final pet in pets) {
            if (pet.vaccineDate != null && pet.vaccineDate!.isNotEmpty) {
              items.add({
                'icon': Icons.vaccines_rounded,
                'color': const Color(0xFF8B5CF6),
                'bg': const Color(0xFFF3EFFE),
                'title': 'Vaccine reminder — ${pet.name}',
                'subtitle': 'Due: ${pet.vaccineDate}',
                'tag': 'Vaccine',
              });
            }
            if (pet.mealTime != null && pet.mealTime!.isNotEmpty) {
              items.add({
                'icon': Icons.restaurant_rounded,
                'color': const Color(0xFFEA580C),
                'bg': const Color(0xFFFFF0E6),
                'title': 'Meal time — ${pet.name}',
                'subtitle': pet.mealTime!,
                'tag': 'Feeding',
              });
            }
          }

          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                          color: _greenLight, shape: BoxShape.circle),
                      child: const Icon(Icons.notifications_none_rounded,
                          size: 40, color: _green)),
                  const SizedBox(height: 16),
                  Text('No reminders yet',
                      style: GoogleFonts.nunito(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: _textMain)),
                  const SizedBox(height: 6),
                  Text(
                      'Add vaccine date or meal time to a pet\nto see reminders here',
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
            itemCount: items.length,
            itemBuilder: (_, i) {
              final item = items[i];
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
                          color: item['bg'] as Color,
                          borderRadius: BorderRadius.circular(12)),
                      child: Icon(item['icon'] as IconData,
                          size: 24, color: item['color'] as Color)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['title'] as String,
                            style: GoogleFonts.nunito(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: _textMain)),
                        const SizedBox(height: 2),
                        Text(item['subtitle'] as String,
                            style: GoogleFonts.nunito(
                                fontSize: 12, color: _textMuted)),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color: item['bg'] as Color,
                        borderRadius: BorderRadius.circular(20)),
                    child: Text(item['tag'] as String,
                        style: GoogleFonts.nunito(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: item['color'] as Color)),
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
