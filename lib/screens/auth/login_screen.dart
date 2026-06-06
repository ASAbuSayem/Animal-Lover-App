import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  late final AnimationController _bgAnim;
  late final AnimationController _cardAnim;
  late final Animation<double> _bgScale;
  late final Animation<double> _cardFade;
  late final Animation<Offset> _cardSlide;

  bool _obscure = true;
  bool _loading = false;
  String? _error;

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
        AnimationController(vsync: this, duration: const Duration(seconds: 6))
          ..repeat(reverse: true);
    _bgScale = Tween<double>(begin: 1.0, end: 1.12)
        .animate(CurvedAnimation(parent: _bgAnim, curve: Curves.easeInOut));

    _cardAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
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
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
      );
      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      setState(() {
        _error = switch (e.code) {
          'user-not-found' => 'No account found with this email.',
          'wrong-password' => 'Incorrect password. Please try again.',
          'invalid-email' => 'Please enter a valid email address.',
          'too-many-requests' => 'Too many attempts. Try again later.',
          _ => 'Login failed. Please try again.',
        };
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _forgotPassword() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      _showSnack('Enter your email first.', isError: true);
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _showSnack('Reset link sent to $email');
    } on FirebaseAuthException catch (e) {
      _showSnack(e.message ?? 'Something went wrong.', isError: true);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgTop,
      body: Stack(children: [
        // Animated background blob
        AnimatedBuilder(
          animation: _bgAnim,
          builder: (_, __) => Positioned(
            top: -100,
            right: -80,
            child: Transform.scale(
              scale: _bgScale.value,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                    color: _greenMid.withOpacity(0.28), shape: BoxShape.circle),
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
                    const SizedBox(height: 60),
                    // Header
                    Column(children: [
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                            color: _greenLight,
                            shape: BoxShape.circle,
                            border: Border.all(color: _greenMid, width: 2)),
                        child: Image.asset(
                            'assets/images/animal_lover_logo.png',
                            width: 80,
                            height: 80,
                            fit: BoxFit.contain),
                      ),
                      const SizedBox(height: 18),
                      Text('Animal Lover',
                          style: GoogleFonts.nunito(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              color: _textMain,
                              letterSpacing: -0.8)),
                      const SizedBox(height: 6),
                      Text('Care smarter. Love deeper.',
                          style: GoogleFonts.nunito(
                              fontSize: 14, color: _textMuted)),
                    ]),
                    const SizedBox(height: 40),
                    // Form card
                    Container(
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
                            Text('Welcome back',
                                style: GoogleFonts.nunito(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: _textMain)),
                            const SizedBox(height: 4),
                            Text('Sign in to continue',
                                style: GoogleFonts.nunito(
                                    fontSize: 13, color: _textMuted)),
                            const SizedBox(height: 24),
                            // Email
                            Text('Email address',
                                style: GoogleFonts.nunito(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: _textMain)),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              decoration: _fieldDeco(
                                  hint: 'you@example.com',
                                  icon: Icons.mail_outline_rounded),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Email is required';
                                }
                                if (!RegExp(
                                        r'^[\w\-.]+@([\w\-]+\.)+[\w\-]{2,}$')
                                    .hasMatch(v.trim())) {
                                  return 'Enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 18),
                            // Password label row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Password',
                                    style: GoogleFonts.nunito(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: _textMain)),
                                GestureDetector(
                                    onTap: _forgotPassword,
                                    child: Text('Forgot password?',
                                        style: GoogleFonts.nunito(
                                            fontSize: 12,
                                            color: _green,
                                            fontWeight: FontWeight.w500))),
                              ],
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _passwordCtrl,
                              obscureText: _obscure,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _login(),
                              decoration: _fieldDeco(
                                  hint: '••••••••',
                                  icon: Icons.lock_outline_rounded,
                                  suffix: GestureDetector(
                                      onTap: () =>
                                          setState(() => _obscure = !_obscure),
                                      child: Icon(
                                          _obscure
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                          size: 19,
                                          color: _textMuted))),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Password is required';
                                }
                                if (v.length < 6) {
                                  return 'At least 6 characters';
                                }
                                return null;
                              },
                            ),
                            if (_error != null) ...[
                              const SizedBox(height: 14),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                    color: const Color(0xFFFEF2F2),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: _errorRed.withOpacity(0.35))),
                                child: Row(children: [
                                  const Icon(Icons.error_outline_rounded,
                                      size: 16, color: _errorRed),
                                  const SizedBox(width: 8),
                                  Expanded(
                                      child: Text(_error!,
                                          style: const TextStyle(
                                              fontSize: 12.5,
                                              color: _errorRed))),
                                ]),
                              ),
                            ],
                            const SizedBox(height: 22),
                            // Login button
                            SizedBox(
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _loading ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _green,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor:
                                      _green.withOpacity(0.6),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14)),
                                ),
                                child: _loading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color: Colors.white))
                                    : Text('Sign in',
                                        style: GoogleFonts.nunito(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.3)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have an account?  ",
                            style: GoogleFonts.nunito(
                                fontSize: 14, color: _textMuted)),
                        GestureDetector(
                            onTap: () =>
                                Navigator.pushNamed(context, '/register'),
                            child: Text('Register now',
                                style: GoogleFonts.nunito(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: _green))),
                      ],
                    ),
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

  InputDecoration _fieldDeco({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) =>
      InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: _textMuted.withOpacity(0.5), fontSize: 14),
        prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 14, right: 10),
            child: Icon(icon, size: 19, color: _textMuted)),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        suffixIcon: suffix != null
            ? Padding(padding: const EdgeInsets.only(right: 14), child: suffix)
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
      );
}
