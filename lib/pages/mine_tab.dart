import 'package:flutter/material.dart';
import 'package:alterego/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:alterego/providers/locale_provider.dart';
import 'package:alterego/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MineTab extends StatefulWidget {
  const MineTab({super.key});

  @override
  State<MineTab> createState() => _MineTabState();
}

class _MineTabState extends State<MineTab> {
  final _auth = AuthService();
  Map<String, dynamic>? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      setState(() {
        _loading = false;
      });
      return;
    }
    final p = await _auth.fetchProfile();
    if (!mounted) return;
    setState(() {
      _profile = p;
      _loading = false;
    });
  }

  Future<void> _signOut() async {
    await _auth.signOut();
    if (!mounted) return;
    setState(() {
      _profile = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已退出登录')));
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final session = Supabase.instance.client.auth.currentSession;
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (session == null) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(t?.myTabTitle ?? 'My'),
          const SizedBox(height: 12),
          const Text('登录以查看你的资料与偏好设置'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
            child: Text(t?.login ?? 'Login'),
          ),
          const SizedBox(height: 24),
          Text(t?.settings ?? 'Settings', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Consumer<LocaleProvider>(builder: (context, lp, _) {
            return ListTile(
              title: Text(t?.language ?? 'Language'),
              trailing: DropdownButton<Locale>(
                value: lp.locale,
                items: const [
                  DropdownMenuItem(value: Locale('en'), child: Text('English')),
                  DropdownMenuItem(value: Locale('zh'), child: Text('中文')),
                ],
                onChanged: (loc) {
                  if (loc != null) lp.setLocale(loc);
                },
              ),
            );
          }),
        ],
      );
    }
    final email = Supabase.instance.client.auth.currentUser?.email ?? '';
    final username = _profile?['username']?.toString() ?? '';
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(t?.myTabTitle ?? 'My'),
        const SizedBox(height: 12),
        Text('Email: $email'),
        const SizedBox(height: 8),
        Text('Username: $username'),
        const SizedBox(height: 20),
        ElevatedButton(onPressed: _signOut, child: Text(t?.logout ?? 'Logout')),
        const SizedBox(height: 24),
        Text(t?.settings ?? 'Settings', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Consumer<LocaleProvider>(builder: (context, lp, _) {
          return ListTile(
            title: Text(t?.language ?? 'Language'),
            trailing: DropdownButton<Locale>(
              value: lp.locale,
              items: const [
                DropdownMenuItem(value: Locale('en'), child: Text('English')),
                DropdownMenuItem(value: Locale('zh'), child: Text('中文')),
              ],
              onChanged: (loc) {
                if (loc != null) lp.setLocale(loc);
              },
            ),
          );
        }),
      ],
    );
  }
}