import '../../core/config/app_config.dart';
import '../models/app_user.dart';

class AuthException implements Exception {
  AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Phone + OTP authentication.
///
/// This local implementation keeps the prototype usable before a backend is
/// connected. Replace the bodies with Supabase Auth calls:
/// `signInWithOtp(phone: '+962...')` and `verifyOTP(type: OtpType.sms, ...)`,
/// keeping the same interface so the UI does not change.
class AuthRepository {
  Future<void> requestOtp(String phone) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
  }

  Future<AppUser> verifyOtp({
    required String phone,
    required String code,
    required UserRole role,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (code != AppConfig.demoOtpCode) {
      throw AuthException('رمز التحقق غير صحيح، حاول مرة أخرى.');
    }
    return AppUser(
      id: 'demo-$phone',
      phone: phone,
      name: '',
      role: role,
    );
  }
}
