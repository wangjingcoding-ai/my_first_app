import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:alterego/models/story_line.dart';
import 'package:alterego/services/story_service.dart';

class StoryProvider extends ChangeNotifier {
  final StoryService _service;
  final String sessionId;
  final String currentUserId = 'player_1';
  final List<StoryLine> messages = [];
  bool isLoading = false;
  String sessionStatus = 'active';
  int? visibleOptionsIndex;
  bool isReaderMode = true;

  StoryProvider({StoryService? service})
      : _service = service ?? StoryService(),
        sessionId = const Uuid().v4();

  Future<void> makeAction(String actionInput, {String language = 'en'}) async {
    visibleOptionsIndex = null;
    messages.add(StoryLine(role: 'user', content: actionInput));
    isLoading = true;
    notifyListeners();
    final res = await _service.sendAction(currentUserId, sessionId, actionInput, language: language);
    isLoading = false;
    messages.add(StoryLine(
      role: 'ai',
      content: (res['content'] ?? '') as String,
      options: (res['options'] as List<String>? ?? <String>[]),
      isTyping: true,
    ));
    notifyListeners();
  }

  void onTypingFinished() {
    for (int i = messages.length - 1; i >= 0; i--) {
      final m = messages[i];
      if (m.role == 'ai' && m.isTyping) {
        messages[i] = StoryLine(
          role: m.role,
          content: m.content,
          options: m.options,
          isTyping: false,
        );
        visibleOptionsIndex = i;
        notifyListeners();
        break;
      }
    }
  }

  Future<void> rollbackDraft() async {
    isLoading = true;
    notifyListeners();
    try {
      await _service.rollbackSession(sessionId, currentUserId);
      int removedAiIndex = -1;
      for (int i = messages.length - 1; i >= 0; i--) {
        if (messages[i].role == 'ai') {
          messages.removeAt(i);
          removedAiIndex = i;
          break;
        }
      }
      if (removedAiIndex > 0 && messages[removedAiIndex - 1].role == 'user') {
        messages.removeAt(removedAiIndex - 1);
      }
      int? idx;
      for (int i = messages.length - 1; i >= 0; i--) {
        if (messages[i].role == 'ai' && !messages[i].isTyping && messages[i].options.isNotEmpty) {
          idx = i;
          break;
        }
      }
      visibleOptionsIndex = idx;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> endStory() async {
    isLoading = true;
    notifyListeners();
    try {
      await _service.finishSession(sessionId, currentUserId);
      sessionStatus = 'completed';
      visibleOptionsIndex = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  bool isOptionsVisibleFor(int index) => visibleOptionsIndex == index;

  Future<void> editMessage(int index, String newContent) async {
    final original = messages[index];
    messages[index] = original.copyWith(content: newContent);
    notifyListeners();
    final id = original.id;
    if (id != null && id.isNotEmpty) {
      try {
        await _service.updateMessage(id, newContent);
      } catch (_) {}
    }
  }

  void toggleReaderMode() {
    isReaderMode = !isReaderMode;
    notifyListeners();
  }
}