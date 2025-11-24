import 'package:flutter/material.dart';

class RecommendTab extends StatelessWidget {
  const RecommendTab({super.key});

  @override
  Widget build(BuildContext context) {
    final news = [
      {'title': 'NBA 常规赛热点', 'desc': '球星数据与排名观察'},
      {'title': '战术解析', 'desc': '空间拉开与挡拆策略'},
      {'title': '新秀观察', 'desc': '本赛季潜力新星表现'},
      {'title': '季后赛前瞻', 'desc': '强队走势与对位分析'},
    ];
    return CustomScrollView(
      slivers: [
        SliverAppBar(title: const Text('推荐'), pinned: true, floating: true),
        SliverPadding(
          padding: const EdgeInsets.all(12),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, i) {
              final item = news[i];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.sports_basketball),
                  title: Text(item['title']!),
                  subtitle: Text(item['desc']!),
                ),
              );
            }, childCount: news.length),
          ),
        ),
      ],
    );
  }
}