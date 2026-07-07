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
import '../../widgets/orientation_lock.dart';

// หน้าเข้าสู่ระบบ/สร้างบัญชีของผู้ปกครอง (ก้าวเก่ง) — email/password + Google
// สลับโหมดด้วยลิงก์ล่างการ์ด (ไม่ใช่แท็บ) ตามดีไซน์การ์ดเดียว
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  var _isRegister = false;
  String? _error;

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
    final busy = submitState.isLoading;

    final user = authState.valueOrNull;
    if (user != null && !user.isAnonymous) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go(kRouteDashboard);
      });
    }

    return OrientationLock(
      portrait: true,
      child: Scaffold(
        backgroundColor: kWarmWhite,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(kSpace6),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Container(
                  padding: const EdgeInsets.all(kSpace8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: kRadiusXl,
                    boxShadow: const [kShadowLg],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _logo(),
                      const SizedBox(height: kSpace4),
                      Text(
                        _isRegister ? 'สร้างบัญชีใหม่' : 'ยินดีต้อนรับกลับ!',
                        style: kTextLg,
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        _isRegister
                            ? 'สร้างบัญชีเพื่อติดตามพัฒนาการของลูก'
                            : 'เข้าสู่ระบบเพื่อติดตามพัฒนาการของลูก',
                        style: kTextSm,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: kSpace6),

                      Text(
                        'อีเมล',
                        style: kTextSm.copyWith(color: kTextPrimary),
                      ),
                      const SizedBox(height: kSpace1),
                      TextField(
                        key: const Key('parent-email-field'),
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        enabled: !busy,
                        decoration: _fieldDecoration('your@email.com'),
                      ),
                      const SizedBox(height: kSpace4),

                      Text(
                        'รหัสผ่าน',
                        style: kTextSm.copyWith(color: kTextPrimary),
                      ),
                      const SizedBox(height: kSpace1),
                      TextField(
                        key: const Key('parent-password-field'),
                        controller: _passwordController,
                        obscureText: true,
                        autofillHints: const [AutofillHints.password],
                        enabled: !busy,
                        decoration: _fieldDecoration('••••••••'),
                      ),

                      if (!_isRegister)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            key: const Key('parent-forgot'),
                            onPressed: busy ? null : _forgotPassword,
                            child: Text(
                              'ลืมรหัสผ่าน?',
                              style: kTextSm.copyWith(color: kBlueDark),
                            ),
                          ),
                        ),

                      if (_error != null) ...[
                        const SizedBox(height: kSpace2),
                        Text(
                          _error!,
                          style: kTextSm.copyWith(color: kError),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: kSpace5),

                      _primaryButton(busy),
                      const SizedBox(height: kSpace5),

                      _orDivider(),
                      const SizedBox(height: kSpace5),

                      _googleButton(busy),
                      const SizedBox(height: kSpace5),

                      _toggleRow(busy),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _logo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [kBluePrimary, kYellowPrimary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Icon(
            Icons.child_care_rounded,
            color: Colors.white,
            size: 34,
          ),
        ),
        const SizedBox(width: kSpace3),
        Flexible(
          child: Text(
            'ก้าวเก่ง',
            style: kTextXL.copyWith(color: kBlueDark),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: kWarmSurface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: kSpace4,
        vertical: kSpace4,
      ),
      border: OutlineInputBorder(
        borderRadius: kRadiusMd,
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _primaryButton(bool busy) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: kRadiusFull,
        color: kYellowPrimary,
        boxShadow: const [kShadowMd],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: const Key('parent-auth-submit'),
          borderRadius: kRadiusFull,
          onTap: busy ? null : _submit,
          child: Container(
            height: 56,
            alignment: Alignment.center,
            child:
                busy
                    ? const SizedBox.square(
                      dimension: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: kTextPrimary,
                      ),
                    )
                    : Text(
                      _isRegister ? 'สร้างบัญชี' : 'เข้าสู่ระบบ',
                      style: kButtonLabel.copyWith(color: kTextPrimary),
                    ),
          ),
        ),
      ),
    );
  }

  Widget _orDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: kWarmBorder)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: kSpace3),
          child: Text('หรือเข้าสู่ระบบด้วย', style: kTextXs),
        ),
        const Expanded(child: Divider(color: kWarmBorder)),
      ],
    );
  }

  Widget _googleButton(bool busy) {
    return OutlinedButton(
      key: const Key('parent-google-signin'),
      onPressed: busy ? null : _signInWithGoogle,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: kSpace4),
        side: const BorderSide(color: kWarmBorder, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: kRadiusFull),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ตราสัญลักษณ์ G อย่างง่าย (ไม่มี asset โลโก้จริง)
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [kShadowSm],
            ),
            child: const Text(
              'G',
              style: TextStyle(
                color: Color(0xFF4285F4),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: kSpace3),
          Flexible(
            child: Text(
              'เข้าสู่ระบบด้วย Google',
              style: kTextMd.copyWith(color: kTextPrimary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _toggleRow(bool busy) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            _isRegister ? 'มีบัญชีอยู่แล้ว? ' : 'ยังไม่มีบัญชี? ',
            style: kTextSm,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        TextButton(
          key: const Key('parent-toggle-mode'),
          onPressed:
              busy
                  ? null
                  : () => setState(() {
                    _isRegister = !_isRegister;
                    _error = null;
                  }),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: kSpace2),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            _isRegister ? 'เข้าสู่ระบบ' : 'สมัครสมาชิก',
            style: kTextSm.copyWith(
              color: kBlueDark,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
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
        // สมัครแล้วอีเมลซ้ำ → สลับไปโหมดเข้าสู่ระบบให้อัตโนมัติ
        if (error is FirebaseAuthException &&
            error.code == 'email-already-in-use') {
          _isRegister = false;
        }
      });
      return;
    }

    if (mounted) context.go(kRouteDashboard);
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _error = null);
    try {
      await ref.read(parentAuthControllerProvider.notifier).signInWithGoogle();
      if (mounted) context.go(kRouteDashboard);
    } catch (error) {
      // ผู้ใช้กดยกเลิกหน้าเลือกบัญชี — ไม่ต้องแสดง error
      if (error is FirebaseAuthException && error.code == 'sign-in-cancelled') {
        return;
      }
      if (mounted) setState(() => _error = parentAuthErrorMessage(error));
    }
  }

  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();
    if (!_emailValid(email)) {
      setState(() => _error = 'กรอกอีเมลก่อน แล้วกด "ลืมรหัสผ่าน"');
      return;
    }
    setState(() => _error = null);
    try {
      await ref
          .read(parentAuthControllerProvider.notifier)
          .sendPasswordReset(email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ส่งลิงก์รีเซ็ตรหัสผ่านไปที่อีเมลแล้ว')),
      );
    } catch (error) {
      if (mounted) setState(() => _error = parentAuthErrorMessage(error));
    }
  }

  String? _validate(String email, String password) {
    if (!_emailValid(email)) return 'รูปแบบอีเมลไม่ถูกต้อง';
    if (password.length < 8) return 'รหัสผ่านต้องมีอย่างน้อย 8 ตัวอักษร';
    return null;
  }

  bool _emailValid(String email) =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
}
