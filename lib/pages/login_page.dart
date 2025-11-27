import 'package:flutter/material.dart';
import 'package:alterego/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alterego/l10n/app_localizations.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = AuthService();
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadLastEmail();
  }

  Future<void> _loadLastEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final last = prefs.getString('last_email');
    if (last != null && last.isNotEmpty) {
      _emailController.text = last;
    }
  }

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final ok = await _auth.signIn(_emailController.text.trim(), _passwordController.text.trim());
      if (ok) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('last_email', _emailController.text.trim());
        final profile = await _auth.fetchProfile();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('登录成功')));
        final username = profile?['username'];
        if (username == null || (username is String && username.isEmpty)) {
          Navigator.pushReplacementNamed(context, '/profile-setup');
        } else {
          Navigator.pushReplacementNamed(context, '/', arguments: 2);
        }
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
      if (mounted) {
        final s = e.toString();
        final isInvalid = s.contains('invalid_credentials');
        final msg = isInvalid ? '邮箱或密码错误，请重试或前往忘记密码' : '登录失败: $s';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('登录')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : _login,
              child: _loading ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2)) : Text(t?.loginTitle ?? '登录'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pushReplacementNamed(context, '/register'),
              child: Text(t?.noAccountGoRegister ?? '没有账号？去注册'),
            ),
            TextButton(
              onPressed: () => Navigator.pushReplacementNamed(context, '/forgot-password'),
              child: Text(t?.forgotTitle ?? '忘记密码'),
            ),
          ],
        ),
      ),
    );
  }
}
