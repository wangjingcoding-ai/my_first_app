import 'package:flutter/material.dart';
import 'package:my_first_app/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final _auth = AuthService();
  Map<String, dynamic>? _profile;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final p = await _auth.fetchProfile();
      if (!mounted) return;
      setState(() {
        _profile = p;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
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
    return Scaffold(
      appBar: AppBar(title: const Text('欢迎')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('欢迎回来'),
                  const SizedBox(height: 8),
                  Text('Email: $userEmail'),
                  const SizedBox(height: 8),
                  Text('Username: $username'),
                  if (updatedAtStr != null) ...[
                    const SizedBox(height: 8),
                    Text('资料更新时间（北京时间）: $updatedAtStr'),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, '/'),
                    child: const Text('进入主页'),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                  ],
                ],
              ),
            ),
    );
  }
}