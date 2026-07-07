import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/tts_strings_th.dart';
import '../../routes/app_routes.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/typography.dart';
import '../../widgets/orientation_lock.dart';

// Parent gate (spec 02 §ParentGateScreen). MVP: friction-only confirm button,
// no PIN/biometric.
class ParentGateScreen extends ConsumerWidget {
  const ParentGateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OrientationLock(
      portrait: true,
      child: Scaffold(
        backgroundColor: kWarmWhite,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(kSpace6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  kParentGateTitle,
                  style: kTextXL,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: kSpace6),
                Text(
                  'กรุณายืนยันว่าคุณเป็นผู้ปกครอง',
                  style: kTextMd.copyWith(color: kTextSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: kSpace10),
                FilledButton(
                  onPressed: () => context.push(kRouteAuth),
                  style: FilledButton.styleFrom(
                    backgroundColor: kYellowPrimary,
                    foregroundColor: kTextPrimary,
                    padding: const EdgeInsets.symmetric(vertical: kSpace4),
                    shape: RoundedRectangleBorder(borderRadius: kRadiusMd),
                  ),
                  child: Text(kParentGateEnter, style: kTextLg),
                ),
                const SizedBox(height: kSpace4),
                TextButton(
                  onPressed: () => context.go(kRouteModeSelect),
                  child: Text(
                    'กลับ',
                    style: kTextMd.copyWith(color: kTextSecondary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
