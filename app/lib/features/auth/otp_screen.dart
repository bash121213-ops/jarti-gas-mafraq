import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/app_scope.dart';
import '../../app/theme.dart';
import '../../core/config/app_config.dart';
import '../../core/utils/arabic.dart';
import '../../data/models/app_user.dart';
import '../../data/repositories/auth_repository.dart';
import '../../shared/widgets/brand_mark.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, required this.phone, required this.role});

  final String phone;
  final UserRole role;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _code = TextEditingController();
  Timer? _timer;
  int _secondsLeft = 60;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    _code.addListener(() => setState(() {}));
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _secondsLeft = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsLeft <= 1) {
        timer.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft -= 1);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _code.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final state = AppScope.of(context);
    if (_code.text.length != 4) {
      setState(() => _error = 'أدخل رمز التحقق المكوّن من ٤ أرقام.');
      return;
    }
    setState(() => _error = null);
    try {
      await state.verifyOtp(_code.text);
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on AuthException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    }
  }

  Future<void> _resend() async {
    final state = AppScope.of(context);
    await state.sendOtp(phone: widget.phone, role: widget.role);
    if (!mounted) return;
    _startCountdown();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('أُرسل رمز التحقق مرة أخرى.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final canSubmit = _code.text.length == 4 && !state.isBusy;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_forward_rounded),
        ),
        title: const Text('رمز التحقق'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(child: BrandMark(size: 60)),
              const SizedBox(height: 18),
              const Text(
                'أدخل رمز التحقق',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              Text(
                'أُرسل الرمز إلى ${formatPhone(widget.phone)}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: AppColors.muted),
              ),
              const SizedBox(height: 26),
              TextField(
                controller: _code,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                textDirection: TextDirection.ltr,
                maxLength: 4,
                autofocus: true,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 18,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                decoration: const InputDecoration(
                  counterText: '',
                  hintText: '----',
                  hintStyle: TextStyle(
                    fontSize: 26,
                    letterSpacing: 16,
                    color: AppColors.line,
                  ),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.danger,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'لم يصلك الرمز؟',
                    style: TextStyle(fontSize: 12.5, color: AppColors.muted),
                  ),
                  const SizedBox(width: 6),
                  _secondsLeft > 0
                      ? Text(
                          'إعادة الإرسال بعد 0:${_secondsLeft.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.apricotInk,
                          ),
                        )
                      : TextButton(
                          onPressed: _resend,
                          child: const Text('إعادة إرسال الرمز'),
                        ),
                ],
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: canSubmit ? _verify : null,
                child: state.isBusy
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      )
                    : const Text('تحقّق ودخول'),
              ),
              const SizedBox(height: 16),
              Text(
                'رمز التجربة في هذه النسخة: ${AppConfig.demoOtpCode}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AppColors.muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
