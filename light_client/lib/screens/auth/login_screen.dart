import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../widgets/common/kinetic_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailCtrl.text.trim();
    final password = _passCtrl.text;
    if (email.isEmpty || password.isEmpty) return;
    await context.read<AuthProvider>().login(email, password);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // Logo / brand
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 48,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Gym', style: AppTextStyles.displaySm),
                      Text(
                        'Gym Performance Engine',
                        style: AppTextStyles.labelSmCaps,
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 64),

              Text('SIGN IN', style: AppTextStyles.headlineLg),
              const SizedBox(height: 8),
              Text(
                'Access your account to continue.',
                style: AppTextStyles.bodyLg,
              ),

              const SizedBox(height: 40),

              // Email
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: AppTextStyles.bodyLg.copyWith(color: AppColors.onBackground),
                decoration: const InputDecoration(
                  labelText: 'EMAIL ADDRESS',
                  prefixIcon: Icon(Icons.email_outlined, size: 18),
                ),
              ),
              const SizedBox(height: 16),

              // Password
              TextField(
                controller: _passCtrl,
                obscureText: _obscure,
                style: AppTextStyles.bodyLg.copyWith(color: AppColors.onBackground),
                decoration: InputDecoration(
                  labelText: 'PASSWORD',
                  prefixIcon: const Icon(Icons.lock_outline, size: 18),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      size: 18,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),

              // Error message
              if (auth.error != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  color: AppColors.error.withValues(alpha: 0.1),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.error_outline,
                          color: AppColors.error, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          auth.error!,
                          style: AppTextStyles.labelMd
                              .copyWith(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),

              KineticButton(
                label: auth.isLoading ? 'SIGNING IN...' : 'SIGN IN',
                onPressed: auth.isLoading ? null : _login,
                fullWidth: true,
              ),

              const SizedBox(height: 24),

              // Demo hint
              Container(
                padding: const EdgeInsets.all(16),
                color: AppColors.surfaceContainerLow,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('DEMO ACCOUNTS', style: AppTextStyles.labelSmCaps.copyWith(color: AppColors.primary)),
                    const SizedBox(height: 8),
                    _DemoHint('Client', 'alex@example.com'),
                    _DemoHint('Staff', 'jordan@example.com'),
                    _DemoHint('Admin', 'sam@example.com'),
                    const SizedBox(height: 4),
                    Text('Password: password', style: AppTextStyles.labelMd),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DemoHint extends StatelessWidget {
  final String role;
  final String email;

  const _DemoHint(this.role, this.email);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            '$role: ',
            style: AppTextStyles.labelMd.copyWith(color: AppColors.onSurface),
          ),
          Text(
            email,
            style: AppTextStyles.labelMd.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
