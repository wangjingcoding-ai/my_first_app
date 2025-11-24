import 'dart:async';
import 'package:flutter/material.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final _pageController = PageController(viewportFraction: 0.9);
  int _page = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      _page = (_page + 1) % 3;
      _pageController.animateToPage(_page, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cards = [
      _bannerItem(
        context,
        title: 'GPT Agents',
        a: Colors.deepPurple,
        b: Colors.indigo,
        sub: '构建自治智能体工作流',
        body:
            '介绍如何基于大型语言模型构建自治Agent，包括记忆、工具调用、任务编排与评估，适配生产环境的稳定性与安全策略。',
      ),
      _bannerItem(
        context,
        title: 'Vision Models',
        a: Colors.blue,
        b: Colors.cyan,
        sub: '图像理解与生成',
        body: '覆盖OCR、检测与分割、文生图与图生图的实践路径，模型选择、部署与推理加速要点。',
      ),
      _bannerItem(
        context,
        title: 'Edge AI',
        a: Colors.teal,
        b: Colors.green,
        sub: '端侧高效推理',
        body: '移动端与嵌入式上的模型量化、蒸馏与硬件加速方案，功耗与时延优化经验。',
      ),
    ];
    final news = [
      {'title': 'RAG 优化实践', 'desc': '向量检索、分块策略与重排序'},
      {'title': '多模态趋势', 'desc': '文本-图像-音频融合应用'},
      {'title': '推理加速', 'desc': '量化、蒸馏与KV缓存'},
      {'title': '企业落地', 'desc': '安全、合规与可观测性'},
    ];
    return CustomScrollView(
      slivers: [
        SliverAppBar(title: const Text('首页'), pinned: true, floating: true),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 180,
            child: PageView(controller: _pageController, children: cards),
          ),
        ),
        SliverPadding(padding: const EdgeInsets.all(12),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, i) {
              final item = news[i];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(item['title']!),
                  subtitle: Text(item['desc']!),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/content',
                    arguments: {
                      'title': item['title'],
                      'subtitle': item['desc'],
                      'body': '${item['title']} - ${item['desc']} 的详细内容将在此展示。',
                    },
                  ),
                ),
              );
            }, childCount: news.length),
          ),
        ),
      ],
    );
  }

  Widget _bannerItem(BuildContext context, {required String title, required Color a, required Color b, required String sub, required String body}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(
          context,
          '/content',
          arguments: {
            'title': title,
            'subtitle': sub,
            'body': body,
          },
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(colors: [a, b]),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(sub),
              ],
            ),
          ),
        ),
      ),
    );
  }
}