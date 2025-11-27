import 'package:flutter/material.dart';
import 'package:alterego/pages/home_tab.dart';
import 'package:alterego/pages/recommend_tab.dart';
import 'package:alterego/pages/mine_tab.dart';
import 'package:alterego/l10n/app_localizations.dart';

class RootTabs extends StatefulWidget {
  const RootTabs({super.key});

  @override
  State<RootTabs> createState() => _RootTabsState();
}

class _RootTabsState extends State<RootTabs> {
  int _index = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is int) _index = arg.clamp(0, 2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [HomeTab(), RecommendTab(), MineTab()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.home_outlined), selectedIcon: const Icon(Icons.home), label: AppLocalizations.of(context)?.navHome ?? '首页'),
          NavigationDestination(icon: const Icon(Icons.star_outline), selectedIcon: const Icon(Icons.star), label: AppLocalizations.of(context)?.navRecommend ?? '推荐'),
          NavigationDestination(icon: const Icon(Icons.person_outline), selectedIcon: const Icon(Icons.person), label: AppLocalizations.of(context)?.navMine ?? '我的'),
        ],
      ),
    );
  }
}