import 'package:flutter/material.dart';

class ContentDetailPage extends StatelessWidget {
  const ContentDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    String title = '详情';
    String subtitle = '';
    String body = '';
    if (args is Map) {
      title = args['title']?.toString() ?? title;
      subtitle = args['subtitle']?.toString() ?? '';
      body = args['body']?.toString() ?? '';
    }
    final scheme = Theme.of(context).colorScheme;
    final colors = [scheme.primary, scheme.secondary];
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(colors: colors),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(subtitle),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(body.isEmpty ? '暂无更多内容' : body),
        ],
      ),
    );
  }
}