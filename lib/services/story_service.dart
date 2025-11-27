import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class DuplicateTitleException implements Exception {
  final String message;
  DuplicateTitleException([this.message = 'DuplicateTitle']);
  @override
  String toString() => 'DuplicateTitleException: $message';
}

class StoryService {
  String get _baseUrl => Platform.isAndroid
      ? 'http://10.0.2.2:8000/api/v1'
      : 'http://127.0.0.1:8000/api/v1';

  Future<Map<String, dynamic>> sendAction(
      String userId, String sessionId, String action, {String language = 'en'}) async {
    try {
      final uri = Uri.parse('$_baseUrl/generate');
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'session_id': sessionId,
          'action': action,
          'language': language,
        }),
      ).timeout(const Duration(seconds: 15));
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final decoded = jsonDecode(res.body) as Map<String, dynamic>;
        final data = decoded['data'] as Map<String, dynamic>?;
        return {
          'content': data?['content'] ?? '',
          'options': (data?['options'] as List?)?.map((e) => e.toString()).toList() ?? <String>[],
        };
      }
      debugPrint('StoryService error status=${res.statusCode} body=${res.body}');
      return {'content': '', 'options': <String>[]};
    } on TimeoutException catch (e) {
      debugPrint('StoryService timeout: $e');
      return {'content': '', 'options': <String>[]};
    } on SocketException catch (e) {
      debugPrint('StoryService socket: $e');
      return {'content': '', 'options': <String>[]};
    } catch (e) {
      debugPrint('StoryService unknown error: $e');
      return {'content': '', 'options': <String>[]};
    }
  }

  Future<void> rollbackSession(String sessionId, String userId) async {
    final url = Uri.parse('$_baseUrl/rollback');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'session_id': sessionId, 'user_id': userId}),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to rollback: ${response.body}');
      }
    } catch (e) {
      debugPrint('Rollback Error: $e');
      rethrow;
    }
  }

  Future<void> finishSession(String sessionId, String userId) async {
    final url = Uri.parse('$_baseUrl/finish');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'session_id': sessionId, 'user_id': userId}),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to finish session: ${response.body}');
      }
    } catch (e) {
      debugPrint('FinishSession Error: $e');
      rethrow;
    }
  }

  Future<String?> uploadCover(File file) async {
    try {
      final client = Supabase.instance.client;
      final bucket = client.storage.from('story-covers');
      final ext = file.path.split('.').last;
      final objectPath = 'covers/${const Uuid().v4()}.$ext';
      final uploadedPath = await bucket.upload(objectPath, file);
      final publicUrl = bucket.getPublicUrl(uploadedPath);
      return publicUrl;
    } catch (e) {
      debugPrint('uploadCover error: $e');
      return null;
    }
  }

  Future<String?> createSession(String title, String summary, String? imageUrl) async {
    try {
      final uri = Uri.parse('$_baseUrl/sessions/create');
      final res = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'user_id': 'player_1',
              'title': title,
              'summary': summary,
              'cover_image': imageUrl,
            }),
          )
          .timeout(const Duration(seconds: 15));
      if (res.statusCode == 409) {
        throw DuplicateTitleException('DuplicateTitle');
      }
      if (res.statusCode >= 200 && res.statusCode < 300) {
        try {
          final decoded = jsonDecode(res.body);
          if (decoded is Map<String, dynamic>) {
            final data = decoded['data'];
            if (data is Map<String, dynamic>) {
              final sid = data['session_id'] ?? data['id'];
              return sid?.toString();
            }
            final sid = decoded['session_id'] ?? decoded['id'];
            return sid?.toString();
          }
        } catch (_) {}
        return null;
      }
      debugPrint('createSession status=${res.statusCode} body=${res.body}');
      return null;
    } on TimeoutException catch (e) {
      debugPrint('createSession timeout: $e');
      return null;
    } on SocketException catch (e) {
      debugPrint('createSession socket: $e');
      return null;
    } catch (e) {
      debugPrint('createSession error: $e');
      return null;
    }
  }

  Future<void> updateMessage(String messageId, String newContent) async {
    final url = Uri.parse('$_baseUrl/messages/$messageId');
    try {
      final res = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'content': newContent}),
      );
      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw Exception('Failed to update message: ${res.statusCode} ${res.body}');
      }
    } catch (e) {
      debugPrint('updateMessage error: $e');
      rethrow;
    }
  }
}