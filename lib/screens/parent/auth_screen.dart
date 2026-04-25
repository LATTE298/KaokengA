import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/colors.dart';
import '../../theme/typography.dart';

// Auth (spec 02 §AuthScreen, spec 03 Flows 4 & 5).
// TODO(auth): wire Firebase Auth email+password + error surface once
// firebase_options.dart exists.
class AuthScreen extends ConsumerWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: kWarmWhite,
      appBar: AppBar(title: const Text('เข้าสู่ระบบ / สร้างบัญชี')),
      body: Center(
        child: Text(
          'Auth UI — pending firebase_options.dart',
          style: kTextMd,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
