import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/colors.dart';
import '../../theme/typography.dart';

// Parent dashboard shell (spec 02 §DashboardScreen). Bottom nav: Log | Progress
// | Scenarios. Tab bodies are placeholders until Firebase is wired up.
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _tab = 0;

  static const _tabs = [
    _TabSpec('Log', 'บันทึกการเล่น', Icons.list_alt_rounded),
    _TabSpec('Progress', 'ความก้าวหน้า', Icons.bar_chart_rounded),
    _TabSpec('Scenarios', 'ตั้งค่าสถานการณ์', Icons.tune_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWarmWhite,
      appBar: AppBar(title: Text(_tabs[_tab].titleTh)),
      body: Center(
        child: Text(
          '${_tabs[_tab].titleTh}\n(pending Firebase)',
          style: kTextMd,
          textAlign: TextAlign.center,
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: [
          for (final t in _tabs)
            NavigationDestination(icon: Icon(t.icon), label: t.titleTh),
        ],
      ),
    );
  }
}

class _TabSpec {
  const _TabSpec(this.key, this.titleTh, this.icon);
  final String key;
  final String titleTh;
  final IconData icon;
}
