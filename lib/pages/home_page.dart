import 'package:flutter/material.dart';
import 'package:alterego/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:alterego/l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _auth = AuthService();
  Map<String, dynamic>? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
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
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = Supabase.instance.client.auth.currentUser?.email ?? '';
    final username = _profile?['username']?.toString() ?? '';
    String? updatedAtStr;
    final rawUpdated = _profile?['updated_at']?.toString() ?? _profile?['created_at']?.toString();
    if (rawUpdated != null) {
      try {
        final utc = DateTime.parse(rawUpdated).toUtc();
        final beijing = utc.add(const Duration(hours: 8));
        updatedAtStr = DateFormat('yyyy-MM-dd HH:mm').format(beijing);
      } catch (_) {
        updatedAtStr = rawUpdated;
      }
    }
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t?.navHome ?? 'Home')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Email: $userEmail'),
                  const SizedBox(height: 8),
                  Text('Username: $username'),
                  if (updatedAtStr != null) ...[
                    const SizedBox(height: 8),
                    Text('资料更新时间（北京时间）: $updatedAtStr'),
                  ],
                  const SizedBox(height: 20),
                  ElevatedButton(onPressed: _signOut, child: const Text('Sign Out')),
                ],
              ),
            ),
    );
  }
}