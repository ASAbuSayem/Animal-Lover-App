import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  late final AnimationController _bgAnim;
  late final AnimationController _cardAnim;
  late final Animation<double> _bgScale;
  late final Animation<double> _cardFade;
  late final Animation<Offset> _cardSlide;

  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _loading = false;
  String? _error;

  // ── Brand palette ──────────────────────────
  static const _green = Color(0xFF1D9E75);
  static const _greenDark = Color(0xFF085041);
  static const _greenLight = Color(0xFFE1F5EE);
  static const _greenMid = Color(0xFF9FE1CB);
  static const _bgTop = Color(0xFFF0FBF7);
  static const _textMain = Color(0xFF0A2E24);
  static const _textMuted = Color(0xFF6B8F80);
  static const _errorRed = Color(0xFFDC2626);

  @override
  void initState() {
    super.initState();

    _bgAnim =
        AnimationController(vsync: this, duration: const Duration(seconds: 7))
          ..repeat(reverse: true);
    _bgScale = Tween<double>(begin: 1.0, end: 1.14)
        .animate(CurvedAnimation(parent: _bgAnim, curve: Curves.easeInOut));

    _cardAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 950));
    _cardFade = CurvedAnimation(
        parent: _cardAnim,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut));
    _cardSlide = Tween<Offset>(begin: const Offset(0, 0.10), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _cardAnim,
            curve: const Interval(0.0, 0.8, curve: Curves.easeOut)));
    _cardAnim.forward();
  }

  @override
  void dispose() {
    _bgAnim.dispose();
    _cardAnim.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  // ── Firebase register ───────────────────────
  Future<void> _register() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
      );
      // Save display name
      await cred.user?.updateDisplayName(_nameCtrl.text.trim());

      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      setState(() {
        _error = switch (e.code) {
          'email-already-in-use' =>
            'An account already exists with this email.',
          'invalid-email' => 'Please enter a valid email address.',
          'weak-password' => 'Password is too weak. Use at least 6 characters.',
          'operation-not-allowed' => 'Email sign-up is not enabled.',
          _ => 'Registration failed. Please try again.',
        };
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontSize: 13)),
      backgroundColor: isError ? _errorRed : _greenDark,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
    ));
  }

  // ── Build ───────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgTop,
      body: Stack(children: [
        // Animated blob — bottom left
        AnimatedBuilder(
          animation: _bgAnim,
          builder: (_, __) => Positioned(
            bottom: -120,
            left: -80,
            child: Transform.scale(
              scale: _bgScale.value,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                    color: _greenMid.withValues(alpha: 0.22),
                    shape: BoxShape.circle),
              ),
            ),
          ),
        ),

        SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: FadeTransition(
              opacity: _cardFade,
              child: SlideTransition(
                position: _cardSlide,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 48),

                    // ── Header ──────────────────
                    _buildHeader(),

                    const SizedBox(height: 32),

                    // ── Form card ───────────────
                    _buildFormCard(),

                    const SizedBox(height: 28),

                    // ── Login prompt ────────────
                    _buildLoginRow(),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  // ── Header ─────────────────────────────────
  Widget _buildHeader() {
    return Column(children: [
      Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
            color: _greenLight,
            shape: BoxShape.circle,
            border: Border.all(color: _greenMid, width: 2)),
        child: Image.asset('assets/images/animal_lover_logo.png',
            width: 80, height: 80, fit: BoxFit.contain),
      ),
      const SizedBox(height: 16),
      Text('Create account',
          style: GoogleFonts.nunito(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: _textMain,
              letterSpacing: -0.6)),
      const SizedBox(height: 6),
      Text('Join Animal Lover today',
          style: GoogleFonts.nunito(fontSize: 14, color: _textMuted)),
    ]);
  }

  // ── Form card ──────────────────────────────
  Widget _buildFormCard() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE5F0EA))),
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Full name
            _label('Full name'),
            const SizedBox(height: 6),
            _buildField(
              ctrl: _nameCtrl,
              hint: 'Your full name',
              icon: Icons.person_outline_rounded,
              action: TextInputAction.next,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Name is required';
                if (v.trim().length < 2) return 'Name is too short';
                return null;
              },
            ),

            const SizedBox(height: 18),

            // Email
            _label('Email address'),
            const SizedBox(height: 6),
            _buildField(
              ctrl: _emailCtrl,
              hint: 'you@example.com',
              icon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
              action: TextInputAction.next,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Email is required';
                if (!RegExp(r'^[\w\-.]+@([\w\-]+\.)+[\w\-]{2,}$')
                    .hasMatch(v.trim())) {
                  return 'Enter a valid email';
                }
                return null;
              },
            ),

            const SizedBox(height: 18),

            // Password
            _label('Password'),
            const SizedBox(height: 6),
            _buildField(
              ctrl: _passCtrl,
              hint: '••••••••',
              icon: Icons.lock_outline_rounded,
              action: TextInputAction.next,
              obscure: _obscurePass,
              toggleObscure: () => setState(() => _obscurePass = !_obscurePass),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Password is required';
                if (v.length < 6) return 'At least 6 characters';
                return null;
              },
            ),

            const SizedBox(height: 18),

            // Confirm password
            _label('Confirm password'),
            const SizedBox(height: 6),
            _buildField(
              ctrl: _confirmCtrl,
              hint: '••••••••',
              icon: Icons.lock_outline_rounded,
              action: TextInputAction.done,
              obscure: _obscureConfirm,
              toggleObscure: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm),
              onSubmitted: (_) => _register(),
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return 'Please confirm your password';
                }
                if (v != _passCtrl.text) return 'Passwords do not match';
                return null;
              },
            ),

            // Error banner
            if (_error != null) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: _errorRed.withValues(alpha: 0.35))),
                child: Row(children: [
                  const Icon(Icons.error_outline_rounded,
                      size: 16, color: _errorRed),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(_error!,
                          style: const TextStyle(
                              fontSize: 12.5, color: _errorRed))),
                ]),
              ),
            ],

            const SizedBox(height: 24),

            // Register button
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _loading ? null : _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: _green.withValues(alpha: 0.6),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white))
                    : Text('Create account',
                        style: GoogleFonts.nunito(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3)),
              ),
            ),

            const SizedBox(height: 16),

            // Terms note
            Text(
              'By creating an account you agree to our Terms of Service and Privacy Policy.',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(fontSize: 11.5, color: _textMuted),
            ),
          ],
        ),
      ),
    );
  }

  // ── Login prompt ───────────────────────────
  Widget _buildLoginRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Already have an account?  ',
            style: GoogleFonts.nunito(fontSize: 14, color: _textMuted)),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Text('Sign in',
              style: GoogleFonts.nunito(
                  fontSize: 14, fontWeight: FontWeight.w700, color: _green)),
        ),
      ],
    );
  }

  // ── Shared field builder ───────────────────
  Widget _buildField({
    required TextEditingController ctrl,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction action = TextInputAction.next,
    bool obscure = false,
    VoidCallback? toggleObscure,
    ValueChanged<String>? onSubmitted,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: ctrl,
      obscureText: obscure,
      keyboardType: keyboardType,
      textInputAction: action,
      onFieldSubmitted: onSubmitted,
      style: GoogleFonts.nunito(fontSize: 14, color: _textMain),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            TextStyle(color: _textMuted.withValues(alpha: 0.5), fontSize: 14),
        prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 14, right: 10),
            child: Icon(icon, size: 19, color: _textMuted)),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        suffixIcon: toggleObscure != null
            ? Padding(
                padding: const EdgeInsets.only(right: 14),
                child: GestureDetector(
                    onTap: toggleObscure,
                    child: Icon(
                        obscure
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 19,
                        color: _textMuted)))
            : null,
        suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        filled: true,
        fillColor: const Color(0xFFF8FDFB),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFD6EDE5))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFD6EDE5))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _green, width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _errorRed)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _errorRed, width: 1.5)),
        errorStyle: const TextStyle(fontSize: 11.5, color: _errorRed),
      ),
      validator: validator,
    );
  }

  Widget _label(String text) => Text(text,
      style: GoogleFonts.nunito(
          fontSize: 13, fontWeight: FontWeight.w600, color: _textMain));
}
