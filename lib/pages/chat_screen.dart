import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alterego/providers/story_provider.dart';
import 'package:alterego/widgets/typewriter_text.dart';
import 'package:alterego/providers/locale_provider.dart';
import 'package:alterego/l10n/app_localizations.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _listController = ScrollController();
  final Map<int, GlobalKey> _itemKeys = {};
  int? _lastScrolledIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.storyEditorTitle ?? 'Story Editor'),
        actions: [
          Consumer<StoryProvider>(builder: (context, sp, _) {
            return IconButton(
              icon: const Icon(Icons.flag),
              onPressed: sp.sessionStatus == 'completed' || sp.isLoading
                  ? null
                  : () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Mark this story as finished?'),
                          content: const Text('You can rollback earlier steps, but this will stop new inputs.'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Finish')),
                          ],
                        ),
                      );
                      if (ok == true) {
                        await sp.endStory();
                      }
                    },
            );
          })
          ,
          Consumer<StoryProvider>(builder: (context, sp, _) {
            return IconButton(
              tooltip: AppLocalizations.of(context)?.showHidePrompts ?? 'Show/Hide Prompts',
              icon: Icon(sp.isReaderMode ? Icons.visibility_off : Icons.visibility),
              onPressed: () => sp.toggleReaderMode(),
            );
          })
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<StoryProvider>(
              builder: (context, sp, _) {
                final idx = sp.visibleOptionsIndex;
                if (idx != null && idx != _lastScrolledIndex) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    final key = _itemKeys[idx];
                    final ctx = key?.currentContext;
                    if (ctx != null) {
                      Scrollable.ensureVisible(ctx, alignment: 0.2, duration: const Duration(milliseconds: 300));
                      _lastScrolledIndex = idx;
                    }
                  });
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  controller: _listController,
                  itemCount: sp.messages.length,
                  itemBuilder: (context, index) {
                    final m = sp.messages[index];
                    final key = _itemKeys[index] ??= GlobalKey();
                    final isUser = m.role == 'user';
                    if (sp.isReaderMode && isUser) {
                      return const SizedBox.shrink();
                    }
                    final bg = isUser ? Colors.transparent : const Color(0xFFF8F9FC);
                    final border = Border.all(color: isUser ? Colors.transparent : const Color(0x11000000));
                    final textStyle = isUser
                        ? Theme.of(context).textTheme.bodySmall!.copyWith(fontStyle: FontStyle.italic, color: Colors.black45)
                        : Theme.of(context).textTheme.bodyMedium;
                    return Container(
                      key: key,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(12),
                        border: border,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: m.role == 'ai' && m.isTyping
                                    ? TypewriterText(text: m.content, onFinished: () => sp.onTypingFinished())
                                    : Text(m.content, style: textStyle),
                              ),
                              if (m.role == 'ai')
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 20),
                                  onPressed: () async {
                                    final controller = TextEditingController(text: m.content);
                                    final spNoListen = Provider.of<StoryProvider>(context, listen: false);
                                    final saved = await showDialog<String>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Edit Segment'),
                                        content: TextField(controller: controller, maxLines: 8),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                                          FilledButton(onPressed: () => Navigator.pop(ctx, controller.text.trim()), child: const Text('Save')),
                                        ],
                                      ),
                                    );
                                    if (saved != null && saved.isNotEmpty) {
                                      await spNoListen.editMessage(index, saved);
                                    }
                                  },
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Consumer<StoryProvider>(builder: (context, sp, _) {
            final latestOptionsIndex = () {
              for (int i = sp.messages.length - 1; i >= 0; i--) {
                final m = sp.messages[i];
                if (m.role == 'ai' && !m.isTyping && m.options.isNotEmpty) return i;
              }
              return null;
            }();
            final opts = latestOptionsIndex != null ? sp.messages[latestOptionsIndex].options : const <String>[];
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0x11000000))),
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (sp.isLoading)
                    Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text(AppLocalizations.of(context)?.writing ?? 'Writing...', textAlign: TextAlign.center),
                    ),
                  if (sp.sessionStatus == 'completed')
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(AppLocalizations.of(context)?.storyEnded ?? '🏁 This story has ended.', textAlign: TextAlign.center),
                    )
                  else ...[
                    if (opts.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: opts
                                .map((opt) => Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: ActionChip(label: Text(opt), onPressed: () {
                                        final code = Provider.of<LocaleProvider>(context, listen: false).locale.languageCode;
                                        sp.makeAction(opt, language: code);
                                      }),
                                    ))
                                .toList(),
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        OutlinedButton(
                          onPressed: sp.isLoading ? null : () => sp.rollbackDraft(),
                          child: Text(AppLocalizations.of(context)?.rollback ?? 'Rollback'),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            decoration: const InputDecoration(hintText: 'Write your next instruction...'),
                            onSubmitted: (v) {
                              if (v.trim().isEmpty) return;
                              final code = Provider.of<LocaleProvider>(context, listen: false).locale.languageCode;
                              sp.makeAction(v.trim(), language: code);
                              _controller.clear();
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: () {
                            final v = _controller.text.trim();
                            if (v.isEmpty) return;
                            final code = Provider.of<LocaleProvider>(context, listen: false).locale.languageCode;
                            sp.makeAction(v, language: code);
                            _controller.clear();
                          },
                          child: Text(AppLocalizations.of(context)?.send ?? 'Send'),
                        ),
                      ],
                    ),
                  ]
                ],
              ),
            );
          })
        ],
      ),
    );
  }
}