import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:alterego/services/auth_service.dart';
import 'dart:ui';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _auth = AuthService();

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final session = Supabase.instance.client.auth.currentSession;
    if (!mounted) return;
    if (session == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }
    try {
      final profile = await _auth.fetchProfile();
      if (!mounted) return;
      final username = profile?['username'];
      if (username == null || (username is String && username.isEmpty)) {
        Navigator.pushReplacementNamed(context, '/profile-setup');
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (_) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final light = Theme.of(context).brightness == Brightness.light;
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Container(color: Theme.of(context).scaffoldBackgroundColor)),
          Positioned(
            left: 32,
            right: 32,
            bottom: 120,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  decoration: BoxDecoration(
                    color: (light ? Colors.black : Colors.white).withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: light ? 0.06 : 0.12), blurRadius: 30, spreadRadius: 1),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      _LogoMark(),
                      SizedBox(height: 16),
                      Text('AlterEgo', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
                      SizedBox(height: 8),
                      Text('AI Interactive Story Creator', style: TextStyle(color: Colors.black54)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoMark extends StatelessWidget {
  const _LogoMark();
  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF141E8C);
    const purple = Color(0xFF9D29EA);
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (r) => const LinearGradient(colors: [blue, purple], begin: Alignment.centerLeft, end: Alignment.centerRight).createShader(r),
          child: const Text('AE', style: TextStyle(fontSize: 64, fontWeight: FontWeight.w800, color: Colors.white)),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _stripe(80),
            const SizedBox(width: 6),
            _stripe(72),
            const SizedBox(width: 6),
            _stripe(64),
          ],
        ),
      ],
    );
  }

  Widget _stripe(double w) {
    const blue = Color(0xFF141E8C);
    const purple = Color(0xFF9D29EA);
    return Container(
      width: w,
      height: 10,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        gradient: LinearGradient(colors: [blue, purple]),
      ),
    );
  }
}