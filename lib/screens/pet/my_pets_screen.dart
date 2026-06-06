import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/pet_service.dart';
import '../pet/pet_detail_screen.dart';
import '../pet/add_pet_screen.dart';

class MyPetsScreen extends StatelessWidget {
  const MyPetsScreen({super.key});

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
        title: Text('My pets',
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const AddPetScreen())),
        backgroundColor: _green,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('Add pet',
            style: GoogleFonts.nunito(
                color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: StreamBuilder<List<Pet>>(
        stream: PetService.petsStream(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: _green));
          }

          final pets = snap.data ?? [];

          if (pets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                          color: _greenLight, shape: BoxShape.circle),
                      child: const Icon(Icons.pets_rounded,
                          size: 40, color: _green)),
                  const SizedBox(height: 16),
                  Text('No pets yet',
                      style: GoogleFonts.nunito(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: _textMain)),
                  const SizedBox(height: 6),
                  Text('Tap + to add your first pet',
                      style:
                          GoogleFonts.nunito(fontSize: 14, color: _textMuted)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            physics: const BouncingScrollPhysics(),
            itemCount: pets.length,
            itemBuilder: (_, i) {
              final pet = pets[i];
              final color = _typeColor(pet.type);
              final bg = _typeBg(pet.type);

              return GestureDetector(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => PetDetailScreen(pet: pet))),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE5F0EA))),
                  child: Row(children: [
                    Container(
                        width: 56,
                        height: 56,
                        decoration:
                            BoxDecoration(color: bg, shape: BoxShape.circle),
                        child:
                            Icon(_typeIcon(pet.type), size: 28, color: color)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(pet.name,
                              style: GoogleFonts.nunito(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: _textMain)),
                          const SizedBox(height: 2),
                          Text(
                              '${pet.type} · ${pet.breed.isEmpty ? "No breed" : pet.breed} · ${pet.age} yr',
                              style: GoogleFonts.nunito(
                                  fontSize: 12, color: _textMuted)),
                          const SizedBox(height: 6),
                          Row(children: [
                            if (pet.vaccineDate != null &&
                                pet.vaccineDate!.isNotEmpty) ...[
                              _tag(
                                  'Vaccine: ${pet.vaccineDate}',
                                  const Color(0xFF8B5CF6),
                                  const Color(0xFFF3EFFE)),
                              const SizedBox(width: 6),
                            ],
                            if (pet.mealTime != null &&
                                pet.mealTime!.isNotEmpty)
                              _tag(
                                  'Meal: ${pet.mealTime}',
                                  const Color(0xFFEA580C),
                                  const Color(0xFFFFF0E6)),
                          ]),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded,
                        color: Color(0xFFB0C4BC)),
                  ]),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _tag(String label, Color fg, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: GoogleFonts.nunito(
              fontSize: 10, fontWeight: FontWeight.w600, color: fg)),
    );
  }
}
