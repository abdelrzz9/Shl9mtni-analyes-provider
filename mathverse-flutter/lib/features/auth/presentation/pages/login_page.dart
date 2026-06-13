import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/responsive.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/mathverse_button.dart';
import '../../../../core/widgets/mathverse_card.dart';
import '../../../../core/widgets/mathverse_input.dart';
import '../bloc/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().login(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;
    final theme = context.textTheme;
    final colors = context.colorScheme;

    return Scaffold(
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.go('/');
          }
        },
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(AppSpacing.screenPadding),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isDesktop ? AppSpacing.formMaxWidth : double.infinity,
                ),
                child: MathVerseGlassCard(
                  padding: EdgeInsets.all(AppSpacing.cardPaddingLarge),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(
                          Icons.calculate,
                          size: AppSizes.iconMassive,
                          color: colors.primary,
                        ),
                        SizedBox(height: AppSpacing.md),
                        Text(
                          'MathVerse',
                          textAlign: TextAlign.center,
                          style: theme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.primary,
                          ),
                        ),
                        SizedBox(height: AppSpacing.xs),
                        Text(
                          'Sign in to continue',
                          textAlign: TextAlign.center,
                          style: theme.bodyLarge?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: AppSpacing.xxxl),
                        MathVerseInput(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Email is required';
                            }
                            if (!value.contains('@')) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: AppSpacing.md),
                        MathVerseInput(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock_outlined),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: colors.onSurfaceVariant,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password is required';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            SizedBox(
                              height: 40,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Checkbox(
                                    value: _rememberMe,
                                    onChanged: (v) => setState(() => _rememberMe = v ?? false),
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  GestureDetector(
                                    onTap: () => setState(() => _rememberMe = !_rememberMe),
                                    child: Text(
                                      'Remember me',
                                      style: theme.bodyMedium,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () {},
                              child: const Text('Forgot password?'),
                            ),
                          ],
                        ),
                        SizedBox(height: AppSpacing.sm),
                        BlocBuilder<AuthCubit, AuthState>(
                          builder: (context, state) {
                            if (state is AuthError) {
                              return Padding(
                                padding: EdgeInsets.only(bottom: AppSpacing.md),
                                child: Container(
                                  padding: EdgeInsets.all(AppSpacing.md),
                                  decoration: BoxDecoration(
                                    color: colors.errorContainer.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(AppRadius.md),
                                    border: Border.all(color: colors.error.withValues(alpha: 0.3)),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.error_outline, color: colors.error, size: AppSizes.iconMedium),
                                      SizedBox(width: AppSpacing.sm),
                                      Expanded(
                                        child: Text(
                                          state.message,
                                          style: theme.bodyMedium?.copyWith(color: colors.onErrorContainer),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                        BlocBuilder<AuthCubit, AuthState>(
                          builder: (context, state) {
                            final isLoading = state is AuthLoading;
                            return MathVerseButton(
                              label: 'Sign In',
                              isLoading: isLoading,
                              onPressed: isLoading ? null : _submit,
                            );
                          },
                        ),
                        SizedBox(height: AppSpacing.xxl),
                        Row(
                          children: [
                            Expanded(child: Divider(color: colors.outlineVariant)),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                              child: Text(
                                'or continue with',
                                style: theme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                              ),
                            ),
                            Expanded(child: Divider(color: colors.outlineVariant)),
                          ],
                        ),
                        SizedBox(height: AppSpacing.lg),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {},
                                icon: Icon(Icons.g_mobiledata, size: AppSizes.iconLarge),
                                label: const Text('Google'),
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppRadius.button),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {},
                                icon: Icon(Icons.apple, size: AppSizes.iconLarge),
                                label: const Text('Apple'),
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppRadius.button),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppSpacing.xxl),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: theme.bodyMedium,
                            ),
                            TextButton(
                              onPressed: () => context.push('/register'),
                              child: const Text('Sign Up'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
