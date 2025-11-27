class StoryLine {
  final String role;
  final String content;
  final List<String> options;
  final bool isTyping;
  final String? id;

  StoryLine({
    required this.role,
    required this.content,
    this.options = const [],
    this.isTyping = false,
    this.id,
  });

  StoryLine copyWith({
    String? role,
    String? content,
    List<String>? options,
    bool? isTyping,
    String? id,
  }) {
    return StoryLine(
      role: role ?? this.role,
      content: content ?? this.content,
      options: options ?? this.options,
      isTyping: isTyping ?? this.isTyping,
      id: id ?? this.id,
    );
  }
}