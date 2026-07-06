import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/app_types.dart';
import '../../models/scenario_config.dart';
import '../../models/session_record.dart';
import '../../providers/auth_provider.dart';
import '../../providers/content_providers.dart';
import '../../providers/parent_dashboard_providers.dart';
import '../../services/auth_service.dart' show parentAuthErrorMessage;
import '../../routes/app_routes.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/typography.dart';
import '../../widgets/child/child_async_view.dart';
import 'progress_dashboard.dart';

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
    final isParentAuthenticated = ref.watch(parentAuthenticatedProvider);
    if (!isParentAuthenticated) {
      return Scaffold(
        backgroundColor: kWarmWhite,
        appBar: AppBar(title: const Text('ส่วนผู้ปกครอง')),
        body: Center(
          child: FilledButton(
            onPressed: () => context.go(kRouteAuth),
            child: const Text('เข้าสู่ระบบ'),
          ),
        ),
      );
    }

    // มือถือแนวนอน (จอเตี้ย): ย้ายสลับแท็บไปไว้ที่ AppBar แล้วซ่อนแถบเมนูล่าง
    // เพื่อคืนพื้นที่แนวตั้งให้เนื้อหา (dashboard ต้องเห็นครบไม่ต้องเลื่อน)
    final isLandscape = MediaQuery.of(context).size.height < 500;

    return Scaffold(
      backgroundColor: kWarmWhite,
      appBar: AppBar(
        title: Text(_tabs[_tab].titleTh),
        actions: [
          if (isLandscape)
            for (var i = 0; i < _tabs.length; i++)
              IconButton(
                tooltip: _tabs[i].titleTh,
                isSelected: i == _tab,
                icon: Icon(_tabs[i].icon),
                onPressed: () => setState(() => _tab = i),
              ),
          IconButton(
            tooltip: 'ออกจากระบบ',
            icon: const Icon(Icons.account_circle_rounded),
            onPressed: _showLogoutSheet,
          ),
        ],
      ),
      body: switch (_tab) {
        0 => const _ActivityLogTab(),
        1 => const ProgressDashboard(),
        _ => const _ScenarioSettingsTab(),
      },
      bottomNavigationBar: isLandscape
          ? null
          : NavigationBar(
              selectedIndex: _tab,
              onDestinationSelected: (i) => setState(() => _tab = i),
              destinations: [
                for (final t in _tabs)
                  NavigationDestination(
                    icon: Icon(t.icon),
                    label: t.titleTh,
                  ),
              ],
            ),
    );
  }

  Future<void> _showLogoutSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      builder:
          (context) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(kSpace6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('ออกจากระบบ', style: kTextLg),
                  const SizedBox(height: kSpace4),
                  FilledButton(
                    key: const Key('parent-logout-submit'),
                    onPressed: () async {
                      await ref
                          .read(parentAuthControllerProvider.notifier)
                          .logout();
                      if (!context.mounted) return;
                      Navigator.of(context).pop();
                      context.go(kRouteModeSelect);
                    },
                    child: const Text('ออกจากระบบ'),
                  ),
                  const SizedBox(height: kSpace2),
                  TextButton(
                    key: const Key('parent-delete-account'),
                    onPressed: () {
                      Navigator.of(context).pop(); // ปิด sheet ก่อน
                      _confirmDeleteAccount();
                    },
                    child: Text(
                      'ลบบัญชีและข้อมูลทั้งหมด',
                      style: TextStyle(color: kError),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('ยกเลิก'),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  // ยืนยันสองชั้นก่อนลบถาวร (ลบไม่ได้กู้คืน) — dialog + ปุ่มสีแดง
  Future<void> _confirmDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ลบบัญชีและข้อมูล'),
        content: const Text(
          'การลบจะลบประวัติการเล่นและบัญชีทั้งหมดอย่างถาวร '
          'ไม่สามารถกู้คืนได้ ต้องการดำเนินการต่อหรือไม่?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('ยกเลิก'),
          ),
          FilledButton(
            key: const Key('parent-delete-confirm'),
            style: FilledButton.styleFrom(backgroundColor: kError),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('ลบถาวร'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await ref.read(parentAuthControllerProvider.notifier).deleteAccount();
      if (!mounted) return;
      context.go(kRouteModeSelect);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(parentAuthErrorMessage(error))),
      );
    }
  }
}

class _ActivityLogTab extends ConsumerWidget {
  const _ActivityLogTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(activityLogProvider);
    final scenarios = ref.watch(scenarioListProvider).valueOrNull ?? const [];
    final titles = {
      for (final scenario in scenarios) scenario.scenarioId: scenario.titleTh,
    };

    return ChildAsyncView<List<SessionRecord>>(
      value: records,
      loading: const Center(child: CircularProgressIndicator()),
      error:
          (_, __) => Center(child: Text('โหลดข้อมูลไม่สำเร็จ', style: kTextMd)),
      isEmpty: (items) => items.isEmpty,
      empty: Center(
        child: Text(
          'ยังไม่มีข้อมูลการเล่น เริ่มเล่นกับน้องเลยนะครับ',
          style: kTextMd,
          textAlign: TextAlign.center,
        ),
      ),
      data:
          (items) => ListView.separated(
            padding: const EdgeInsets.all(kSpace6),
            itemCount: items.length + 1,
            separatorBuilder: (_, __) => const SizedBox(height: kSpace3),
            itemBuilder: (context, index) {
              if (index == items.length) {
                return OutlinedButton(
                  onPressed:
                      () =>
                          ref
                              .read(activityLogLimitProvider.notifier)
                              .loadMore(),
                  child: const Text('โหลดเพิ่มเติม'),
                );
              }
              final record = items[index];
              return _SessionRecordTile(
                record: record,
                title: titles[record.scenarioId] ?? record.scenarioId,
              );
            },
          ),
    );
  }
}

class _SessionRecordTile extends StatelessWidget {
  const _SessionRecordTile({required this.record, required this.title});

  final SessionRecord record;
  final String title;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: kRadiusMd),
      title: Text(title, style: kTextMd),
      subtitle: Text(
        '${_moduleLabel(record.module)} · ${_formatDate(record.endedAt)}',
      ),
      trailing: Text(_formatDuration(record.durationMs), style: kTextBase),
    );
  }
}

class _ScenarioSettingsTab extends ConsumerWidget {
  const _ScenarioSettingsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scenarios = ref.watch(scenarioListProvider);
    final settings = ref.watch(scenarioSettingsProvider);
    final saving = ref.watch(scenarioToggleSavingProvider);
    final overrides = settings.valueOrNull ?? const <String, bool>{};

    return ChildAsyncView<List<ScenarioSummary>>(
      value: scenarios,
      loading: const Center(child: CircularProgressIndicator()),
      error:
          (_, __) =>
              Center(child: Text('โหลดสถานการณ์ไม่สำเร็จ', style: kTextMd)),
      data:
          (items) => ListView.separated(
            padding: const EdgeInsets.all(kSpace6),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: kSpace3),
            itemBuilder: (context, index) {
              final scenario = items[index];
              final enabled = overrides[scenario.scenarioId] ?? true;
              final isSaving = saving.contains(scenario.scenarioId);
              return SwitchListTile(
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: kRadiusMd),
                title: Text(scenario.titleTh, style: kTextMd),
                subtitle: Text(scenario.category),
                value: enabled,
                onChanged:
                    isSaving
                        ? null
                        : (value) async {
                          try {
                            await ref
                                .read(scenarioToggleControllerProvider)
                                .setEnabled(
                                  scenarioId: scenario.scenarioId,
                                  enabled: value,
                                );
                          } catch (_) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'ไม่สามารถบันทึกได้ กรุณาลองใหม่',
                                ),
                              ),
                            );
                          }
                        },
              );
            },
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

String _moduleLabel(String module) {
  return switch (module) {
    kModuleDailyLife => 'ชีวิตประจำวัน',
    kModuleMemory => 'จับคู่ภาพ',
    kModuleVocab => 'เกมตอบคำถามคำศัพท์',
    _ => module,
  };
}

String _formatDuration(int durationMs) {
  final seconds = (durationMs / 1000).round();
  final minutes = seconds ~/ 60;
  final remainingSeconds = seconds % 60;
  if (minutes == 0) return '$remainingSeconds วินาที';
  return '$minutes นาที $remainingSeconds วินาที';
}

String _formatDate(String isoString) {
  final date = DateTime.tryParse(isoString)?.toLocal();
  if (date == null) return isoString;
  return '${date.day}/${date.month}/${date.year + 543} '
      '${date.hour.toString().padLeft(2, '0')}:'
      '${date.minute.toString().padLeft(2, '0')}';
}
