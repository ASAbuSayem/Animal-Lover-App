import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/pet_service.dart';

class AddPetScreen extends StatefulWidget {
  const AddPetScreen({super.key});
  @override
  State<AddPetScreen> createState() => _AddPetScreenState();
}

class _AddPetScreenState extends State<AddPetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _breedCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _vaccineDateCtrl = TextEditingController();
  final _mealTimeCtrl = TextEditingController();

  String _petType = 'Dog';
  int _age = 1;
  double _weight = 10;
  bool _loading = false;

  static const _green = Color(0xFF1D9E75);
  static const _greenLight = Color(0xFFE1F5EE);
  static const _greenMid = Color(0xFF9FE1CB);
  static const _textMain = Color(0xFF0A2E24);
  static const _textMuted = Color(0xFF6B8F80);
  static const _errorRed = Color(0xFFDC2626);

  @override
  void dispose() {
    _nameCtrl.dispose();
    _breedCtrl.dispose();
    _notesCtrl.dispose();
    _vaccineDateCtrl.dispose();
    _mealTimeCtrl.dispose();
    super.dispose();
  }

  Future<void> _savePet() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final pet = Pet(
        id: '',
        name: _nameCtrl.text.trim(),
        type: _petType,
        breed:
            _breedCtrl.text.trim().isEmpty ? _petType : _breedCtrl.text.trim(),
        age: _age,
        weight: _weight,
        vaccineDate: _vaccineDateCtrl.text.trim().isEmpty
            ? null
            : _vaccineDateCtrl.text.trim(),
        mealTime: _mealTimeCtrl.text.trim().isEmpty
            ? null
            : _mealTimeCtrl.text.trim(),
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        createdAt: DateTime.now(),
      );

      await PetService.addPet(pet);
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${_nameCtrl.text.trim()} added successfully! 🐾',
              style: GoogleFonts.nunito(fontWeight: FontWeight.w600)),
          backgroundColor: _green,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to save pet: $e'),
          backgroundColor: _errorRed,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FAF7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Add a new pet',
            style: GoogleFonts.nunito(
                fontSize: 18, fontWeight: FontWeight.w800, color: _textMain)),
        leading: IconButton(
            icon: const Icon(Icons.close_rounded, color: Color(0xFF0A2E24)),
            onPressed: () => Navigator.pop(context)),
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: const Color(0xFFE5F0EA))),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Pet type selector
              _sectionTitle('Pet type'),
              const SizedBox(height: 10),
              Row(
                children: ['Dog', 'Cat', 'Bird', 'Rabbit', 'Other']
                    .map((t) => Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _petType = t),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(right: 6),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                  color: _petType == t ? _green : Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: _petType == t
                                          ? _green
                                          : const Color(0xFFE5F0EA))),
                              child: Column(children: [
                                Text(_petIcon(t),
                                    style: const TextStyle(fontSize: 18)),
                                const SizedBox(height: 3),
                                Text(t,
                                    style: GoogleFonts.nunito(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: _petType == t
                                            ? Colors.white
                                            : _textMuted)),
                              ]),
                            ),
                          ),
                        ))
                    .toList(),
              ),

              const SizedBox(height: 20),

              // Basic info card
              _card(children: [
                _sectionTitle('Basic information'),
                const SizedBox(height: 14),
                _textField('Pet name *', _nameCtrl,
                    hint: 'e.g. Max, Luna, Buddy',
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Pet name is required'
                        : null),
                const SizedBox(height: 14),
                _textField('Breed', _breedCtrl,
                    hint: 'e.g. Golden Retriever, Persian'),
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(
                      child: _dropdown(
                          'Age (years)',
                          _age.toString(),
                          List.generate(20, (i) => (i + 1).toString()),
                          (v) => setState(() => _age = int.parse(v!)))),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Weight: ${_weight.toStringAsFixed(1)} kg',
                          style: GoogleFonts.nunito(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _textMuted)),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: _green,
                          thumbColor: _green,
                          inactiveTrackColor: _greenMid.withValues(alpha: 0.3),
                          overlayColor: _green.withValues(alpha: 0.1),
                          trackHeight: 3,
                        ),
                        child: Slider(
                            value: _weight,
                            min: 0.1,
                            max: 80,
                            onChanged: (v) => setState(() => _weight = v)),
                      ),
                    ],
                  )),
                ]),
              ]),

              const SizedBox(height: 14),

              // Care schedule card
              _card(children: [
                _sectionTitle('Care schedule'),
                const SizedBox(height: 4),
                Text('Optional — helps show reminders on home screen',
                    style: GoogleFonts.nunito(fontSize: 11, color: _textMuted)),
                const SizedBox(height: 14),
                _textField('Next vaccine due date', _vaccineDateCtrl,
                    hint: 'e.g. July 10, 2026',
                    icon: Icons.vaccines_rounded,
                    iconColor: const Color(0xFF8B5CF6)),
                const SizedBox(height: 14),
                _textField('Meal time', _mealTimeCtrl,
                    hint: 'e.g. 8:00 AM and 6:00 PM',
                    icon: Icons.restaurant_rounded,
                    iconColor: const Color(0xFFEA580C)),
                const SizedBox(height: 14),
                _textField('Notes', _notesCtrl,
                    hint: 'Any allergies, special needs...',
                    maxLines: 3,
                    icon: Icons.notes_rounded,
                    iconColor: _textMuted),
              ]),

              const SizedBox(height: 24),

              // Save button
              SizedBox(
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _loading ? null : _savePet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: _green.withValues(alpha: 0.6),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.white))
                      : const Icon(Icons.check_circle_outline_rounded,
                          size: 20),
                  label: Text(_loading ? 'Saving...' : 'Save pet',
                      style: GoogleFonts.nunito(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  String _petIcon(String type) => switch (type) {
        'Dog' => '🐕',
        'Cat' => '🐈',
        'Bird' => '🐦',
        'Rabbit' => '🐇',
        _ => '🐾'
      };

  Widget _sectionTitle(String t) => Text(t,
      style: GoogleFonts.nunito(
          fontSize: 15, fontWeight: FontWeight.w800, color: _textMain));

  Widget _card({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5F0EA))),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _textField(String label, TextEditingController ctrl,
      {String hint = '',
      int maxLines = 1,
      IconData? icon,
      Color? iconColor,
      String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.nunito(
                fontSize: 12, fontWeight: FontWeight.w600, color: _textMuted)),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          maxLines: maxLines,
          style: GoogleFonts.nunito(fontSize: 13, color: _textMain),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
                color: _textMuted.withValues(alpha: 0.5), fontSize: 13),
            prefixIcon: icon != null
                ? Padding(
                    padding: const EdgeInsets.only(left: 12, right: 8),
                    child: Icon(icon, size: 18, color: iconColor ?? _textMuted))
                : null,
            prefixIconConstraints:
                const BoxConstraints(minWidth: 0, minHeight: 0),
            filled: true,
            fillColor: const Color(0xFFF8FDFB),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFD6EDE5))),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFD6EDE5))),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _green, width: 1.5)),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _errorRed)),
            focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _errorRed, width: 1.5)),
            errorStyle: const TextStyle(fontSize: 11, color: _errorRed),
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
