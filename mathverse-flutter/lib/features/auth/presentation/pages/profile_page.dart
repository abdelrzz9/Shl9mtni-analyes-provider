import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/responsive.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/mathverse_button.dart';
import '../../../../core/widgets/mathverse_card.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../bloc/auth_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            return _ProfileContent(user: state.user);
          }
          return const EmptyState(
            icon: Icons.person_outline_rounded,
            title: 'Not Signed In',
            subtitle: 'Sign in to view your profile',
            actionLabel: 'Sign In',
          );
        },
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final dynamic user;

  const _ProfileContent({required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: context.screenPadding,
      children: [
        Center(
          child: Column(
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Text(
                  user.displayName.isNotEmpty
                      ? user.displayName[0].toUpperCase()
                      : '?',
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                user.displayName,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                user.email,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxxl),
        MathVerseCard(
          child: Column(
            children: [
              _ProfileTile(
                icon: Icons.person_outline,
                title: 'Display Name',
                subtitle: user.displayName,
              ),
              Divider(height: 1, color: theme.colorScheme.outlineVariant),
              _ProfileTile(
                icon: Icons.email_outlined,
                title: 'Email',
                subtitle: user.email,
              ),
              Divider(height: 1, color: theme.colorScheme.outlineVariant),
              const _ProfileTile(
                icon: Icons.calendar_today_outlined,
                title: 'Member Since',
                subtitle: 'New Member',
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        MathVerseButton(
          label: 'Sign Out',
          onPressed: () {
            context.read<AuthCubit>().logout();
            context.go('/');
          },
          icon: Icons.logout_rounded,
          color: theme.colorScheme.error,
        ),
      ],
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(title, style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      )),
      subtitle: Text(subtitle, style: theme.textTheme.bodyLarge?.copyWith(
        fontWeight: FontWeight.w500,
      )),
    );
  }
}
