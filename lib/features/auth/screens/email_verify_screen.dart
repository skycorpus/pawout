import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/routes.dart';
import '../providers/auth_provider.dart';

class EmailVerifyScreen extends StatefulWidget {
  const EmailVerifyScreen({super.key});

  @override
  State<EmailVerifyScreen> createState() => _EmailVerifyScreenState();
}

class _EmailVerifyScreenState extends State<EmailVerifyScreen> {
  bool _resending = false;

  Future<void> _resend(String email) async {
    setState(() => _resending = true);
    final ok =
        await context.read<AuthProvider>().resendVerificationEmail(email);
    if (!mounted) return;
    setState(() => _resending = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? '인증 메일을 재발송했습니다' : '재발송에 실패했습니다. 잠시 후 다시 시도해주세요.'),
        backgroundColor: ok ? const Color(0xFFFF6B9D) : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final email =
        ModalRoute.of(context)?.settings.arguments as String? ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 아이콘
              const Icon(
                Icons.mark_email_unread_outlined,
                size: 80,
                color: Color(0xFFFF6B9D),
              ),
              const SizedBox(height: 24),

              // 제목
              const Text(
                '이메일 인증이 필요해요',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3436),
                ),
              ),
              const SizedBox(height: 12),

              // 안내
              Text(
                '아래 이메일로 인증 링크를 발송했습니다.\n메일함을 확인해 링크를 클릭해 주세요.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),

              // 이메일 표시
              Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 12, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: const Color(0xFFFF6B9D), width: 1.5),
                ),
                child: Text(
                  email,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3436),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // 재발송 버튼
              ElevatedButton.icon(
                onPressed: _resending ? null : () => _resend(email),
                icon: _resending
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.refresh),
                label: const Text('인증 메일 재발송'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B9D),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 로그인 화면으로
              OutlinedButton(
                onPressed: () => Navigator.of(context)
                    .pushReplacementNamed(AppRoutes.login),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFFF6B9D),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: const BorderSide(color: Color(0xFFFF6B9D)),
                ),
                child: const Text('인증 완료 후 로그인하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
