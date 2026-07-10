import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user_profile.dart';
import '../../providers/user_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key, this.onToggleMode});

  /// When provided (e.g. by AuthGate), tapping "Log in" calls this
  /// instead of pushing a named route.
  final VoidCallback? onToggleMode;

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _role = UserRole.student;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final userProvider = context.read<UserProvider>();
    final success = await userProvider.signUp(
      name: _nameController.text.trim(),
      email: _emailController.text,
      password: _passwordController.text,
      role: _role,
    );

    if (!mounted) return;
    if (!success && userProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userProvider.errorMessage!)),
      );
    }
    // On success, AuthGate routes automatically based on the newly
    // created Firestore profile's role.
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final isStartup = _role == UserRole.startup;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Create account'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'I am a...',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.charcoal,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _RoleCard(
                        label: 'Student',
                        subtitle: 'Find internships',
                        icon: Icons.school_outlined,
                        selected: _role == UserRole.student,
                        onTap: () =>
                            setState(() => _role = UserRole.student),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _RoleCard(
                        label: 'Startup',
                        subtitle: 'Post opportunities',
                        icon: Icons.rocket_launch_outlined,
                        selected: _role == UserRole.startup,
                        onTap: () =>
                            setState(() => _role = UserRole.startup),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  controller: _nameController,
                  label: isStartup ? 'Company name' : 'Full name',
                  prefixIcon:
                      isStartup ? Icons.business_outlined : Icons.person_outline,
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return isStartup
                          ? 'Enter your company name'
                          : 'Enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _emailController,
                  label: 'Email',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter an email';
                    }
                    if (!value.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _passwordController,
                  label: 'Password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                if (isStartup) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.pending.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: AppColors.pending.withOpacity(0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline,
                            color: AppColors.pending, size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Startup accounts are reviewed before opportunities go live.',
                            style: TextStyle(
                                fontSize: 12.5, color: AppColors.charcoal),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                CustomButton(
                  label: 'Create Account',
                  isLoading: userProvider.isBusy,
                  onPressed: _submit,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account?',
                        style: TextStyle(color: AppColors.grey)),
                    TextButton(
                      onPressed: widget.onToggleMode ??
                          () {
                            Navigator.of(context)
                                .pushReplacementNamed(AppRoutes.login);
                          },
                      child: const Text('Log in'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.maroon.withOpacity(0.08) : AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.maroon : AppColors.lightGrey,
            width: selected ? 1.8 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? AppColors.maroon : AppColors.grey),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: selected ? AppColors.maroon : AppColors.charcoal,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 11, color: AppColors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
