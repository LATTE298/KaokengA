import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/typography.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  var _tab = 0;
  String? _error;

  bool get _isRegister => _tab == 0;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final submitState = ref.watch(parentAuthControllerProvider);
    final user = authState.valueOrNull;
    if (user != null && !user.isAnonymous) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go(kRouteDashboard);
      });
    }

    return Scaffold(
      backgroundColor: kWarmWhite,
      appBar: AppBar(title: const Text('เข้าสู่ระบบ / สร้างบัญชี')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(kSpace6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 0, label: Text('สร้างบัญชี')),
                    ButtonSegment(value: 1, label: Text('เข้าสู่ระบบ')),
                  ],
                  selected: {_tab},
                  onSelectionChanged:
                      submitState.isLoading
                          ? null
                          : (selected) {
                            setState(() {
                              _tab = selected.single;
                              _error = null;
                            });
                          },
                ),
                const SizedBox(height: kSpace6),
                TextField(
                  key: const Key('parent-email-field'),
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  decoration: const InputDecoration(labelText: 'อีเมล'),
                  enabled: !submitState.isLoading,
                ),
                const SizedBox(height: kSpace4),
                TextField(
                  key: const Key('parent-password-field'),
                  controller: _passwordController,
                  obscureText: true,
                  autofillHints: const [AutofillHints.password],
                  decoration: const InputDecoration(labelText: 'รหัสผ่าน'),
                  enabled: !submitState.isLoading,
                ),
                if (_error != null) ...[
                  const SizedBox(height: kSpace4),
                  Text(
                    _error!,
                    style: kTextSm.copyWith(color: Colors.red.shade700),
                  ),
                ],
                const SizedBox(height: kSpace6),
                FilledButton(
                  key: const Key('parent-auth-submit'),
                  onPressed: submitState.isLoading ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: kYellowPrimary,
                    foregroundColor: kTextPrimary,
                    padding: const EdgeInsets.symmetric(vertical: kSpace4),
                    shape: RoundedRectangleBorder(borderRadius: kRadiusMd),
                  ),
                  child:
                      submitState.isLoading
                          ? const SizedBox.square(
                            dimension: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : Text(
                            _isRegister ? 'สร้างบัญชี' : 'เข้าสู่ระบบ',
                            style: kTextMd,
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final validationError = _validate(email, password);
    if (validationError != null) {
      setState(() => _error = validationError);
      return;
    }

    setState(() => _error = null);
    final controller = ref.read(parentAuthControllerProvider.notifier);
    if (_isRegister) {
      await controller.register(email: email, password: password);
    } else {
      await controller.login(email: email, password: password);
    }

    final state = ref.read(parentAuthControllerProvider);
    if (state.hasError) {
      final error = state.error!;
      setState(() {
        _error = parentAuthErrorMessage(error);
        if (error is FirebaseAuthException &&
            error.code == 'email-already-in-use') {
          _tab = 1;
        }
      });
      return;
    }

    if (mounted) context.go(kRouteDashboard);
  }

  String? _validate(String email, String password) {
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'รูปแบบอีเมลไม่ถูกต้อง';
    }
    if (password.length < 8) {
      return 'รหัสผ่านต้องมีอย่างน้อย 8 ตัวอักษร';
    }
    return null;
  }
}
