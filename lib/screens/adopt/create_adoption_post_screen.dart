import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/adoption_post_service.dart';

class CreateAdoptionPostScreen extends StatefulWidget {
  const CreateAdoptionPostScreen({super.key});
  @override
  State<CreateAdoptionPostScreen> createState() =>
      _CreateAdoptionPostScreenState();
}

class _CreateAdoptionPostScreenState extends State<CreateAdoptionPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _breedCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();

  String _type = 'Dog';
  String _gender = 'Male';
  bool _vaccinated = false;
  bool _neutered = false;
  bool _loading = false;

  static const _green = Color(0xFF1D9E75);
  static const _greenLight = Color(0xFFE1F5EE);
  static const _greenMid = Color(0xFF9FE1CB);
  static const _textMain = Color(0xFF0A2E24);
  static const _textMuted = Color(0xFF6B8F80);

  @override
  void dispose() {
    _nameCtrl.dispose();
    _breedCtrl.dispose();
    _ageCtrl.dispose();
    _locationCtrl.dispose();
    _descCtrl.dispose();
    _contactCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      final post = AdoptionPost(
        id: '',
        name: _nameCtrl.text.trim(),
        type: _type,
        breed: _breedCtrl.text.trim(),
        age: _ageCtrl.text.trim(),
        gender: _gender,
        location: _locationCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        contact: _contactCtrl.text.trim(),
        vaccinated: _vaccinated,
        neutered: _neutered,
        postedBy: user?.uid ?? '',
        postedByName: user?.displayName ?? 'Anonymous',
        createdAt: DateTime.now(),
      );

      await AdoptionPostService.createPost(post);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${_nameCtrl.text.trim()} posted for adoption! 🐾',
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
          content: Text('Failed: $e'),
          backgroundColor: const Color(0xFFDC2626),
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
        title: Text('Post for adoption',
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
              // Pet type
              _sectionTitle('Pet type'),
              const SizedBox(height: 10),
              Row(
                children: ['Dog', 'Cat', 'Bird', 'Rabbit', 'Other']
                    .map((t) => Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _type = t),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(right: 6),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                  color: _type == t ? _green : Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: _type == t
                                          ? _green
                                          : const Color(0xFFE5F0EA))),
                              child: Column(children: [
                                Text(_petEmoji(t),
                                    style: const TextStyle(fontSize: 18)),
                                const SizedBox(height: 2),
                                Text(t,
                                    style: GoogleFonts.nunito(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: _type == t
                                            ? Colors.white
                                            : _textMuted)),
                              ]),
                            ),
                          ),
                        ))
                    .toList(),
              ),

              const SizedBox(height: 20),

              // Basic info
              _card(children: [
                _sectionTitle('Pet information'),
                const SizedBox(height: 14),

                _field('Pet name *', _nameCtrl,
                    hint: 'e.g. Buddy',
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null),
                const SizedBox(height: 12),

                Row(children: [
                  Expanded(
                      child:
                          _field('Breed', _breedCtrl, hint: 'e.g. Labrador')),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _field('Age *', _ageCtrl,
                          hint: 'e.g. 2 years',
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Required'
                              : null)),
                ]),
                const SizedBox(height: 12),

                // Gender
                Text('Gender',
                    style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _textMuted)),
                const SizedBox(height: 8),
                Row(
                  children: ['Male', 'Female']
                      .map((g) => Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _gender = g),
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                    color: _gender == g ? _green : _greenLight,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color:
                                            _gender == g ? _green : _greenMid)),
                                child: Text(
                                    g == 'Male' ? '♂  Male' : '♀  Female',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.nunito(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: _gender == g
                                            ? Colors.white
                                            : _green)),
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ]),

              const SizedBox(height: 14),

              // Location + contact
              _card(children: [
                _sectionTitle('Location & contact'),
                const SizedBox(height: 14),
                _field('Location *', _locationCtrl,
                    hint: 'e.g. Dhaka, Mirpur',
                    icon: Icons.location_on_outlined,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null),
                const SizedBox(height: 12),
                _field('Contact (phone/email) *', _contactCtrl,
                    hint: 'e.g. 01XXXXXXXXX',
                    icon: Icons.phone_outlined,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null),
              ]),

              const SizedBox(height: 14),

              // Description
              _card(children: [
                _sectionTitle('About this pet'),
                const SizedBox(height: 14),
                _field('Description *', _descCtrl,
                    hint: 'Describe the pet\'s personality, '
                        'health, habits...',
                    maxLines: 4,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null),
              ]),

              const SizedBox(height: 14),

              // Health status
              _card(children: [
                _sectionTitle('Health status'),
                const SizedBox(height: 8),
                _toggle(
                    'Vaccinated',
                    _vaccinated,
                    (v) => setState(() => _vaccinated = v),
                    Icons.vaccines_rounded,
                    const Color(0xFF8B5CF6)),
                const SizedBox(height: 4),
                _toggle(
                    'Neutered/Spayed',
                    _neutered,
                    (v) => setState(() => _neutered = v),
                    Icons.medical_services_outlined,
                    const Color(0xFF0891B2)),
              ]),

              const SizedBox(height: 24),

              SizedBox(
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _loading ? null : _submitPost,
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
                      : const Icon(Icons.pets_rounded, size: 20),
                  label: Text(_loading ? 'Posting...' : 'Post for adoption',
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

  String _petEmoji(String type) => switch (type) {
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

  Widget _field(String label, TextEditingController ctrl,
      {String hint = '',
      int maxLines = 1,
      IconData? icon,
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
                    child: Icon(icon, size: 18, color: _textMuted))
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
                borderSide: const BorderSide(color: Color(0xFFDC2626))),
            errorStyle: const TextStyle(fontSize: 11, color: Color(0xFFDC2626)),
          ),
        ),
      ],
    );
  }

  Widget _toggle(String label, bool value, void Function(bool) onChanged,
      IconData icon, Color color) {
    return Row(children: [
      Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
              color: value
                  ? color.withValues(alpha: 0.1)
                  : const Color(0xFFF4FAF7),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 18, color: value ? color : _textMuted)),
      const SizedBox(width: 12),
      Expanded(
          child: Text(label,
              style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _textMain))),
      Switch(
        value: value,
        onChanged: onChanged,
        activeColor: color,
      ),
    ]);
  }
}
