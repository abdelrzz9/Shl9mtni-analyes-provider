import 'package:flutter/material.dart';

import '../../../../core/extensions/responsive.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/mathverse_card.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _hapticFeedback = true;
  bool _showHistory = true;
  bool _autoCalculate = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: context.screenPadding,
        children: [
          const _SectionTitle(title: 'Preferences'),
          const SizedBox(height: AppSpacing.sm),
          MathVerseCard(
            child: Column(
              children: [
                _SettingsSwitch(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  subtitle: 'Receive calculation alerts',
                  value: _notificationsEnabled,
                  onChanged: (v) => setState(() => _notificationsEnabled = v),
                ),
                Divider(height: 1, color: theme.colorScheme.outlineVariant),
                _SettingsSwitch(
                  icon: Icons.vibration_outlined,
                  title: 'Haptic Feedback',
                  subtitle: 'Vibrate on button press',
                  value: _hapticFeedback,
                  onChanged: (v) => setState(() => _hapticFeedback = v),
                ),
                Divider(height: 1, color: theme.colorScheme.outlineVariant),
                _SettingsSwitch(
                  icon: Icons.history_outlined,
                  title: 'Save History',
                  subtitle: 'Automatically save calculations',
                  value: _showHistory,
                  onChanged: (v) => setState(() => _showHistory = v),
                ),
                Divider(height: 1, color: theme.colorScheme.outlineVariant),
                _SettingsSwitch(
                  icon: Icons.auto_mode_outlined,
                  title: 'Auto Calculate',
                  subtitle: 'Evaluate expressions in real-time',
                  value: _autoCalculate,
                  onChanged: (v) => setState(() => _autoCalculate = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          const _SectionTitle(title: 'Appearance'),
          const SizedBox(height: AppSpacing.sm),
          MathVerseCard(
            child: ListTile(
              leading: Icon(Icons.palette_outlined, color: theme.colorScheme.primary),
              title: const Text('Theme'),
              subtitle: const Text('System Default'),
              trailing: const Icon(Icons.chevron_right_rounded),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          const _SectionTitle(title: 'About'),
          const SizedBox(height: AppSpacing.sm),
          MathVerseCard(
            child: Column(
              children: [
                const _InfoTile(title: 'Version', subtitle: '1.0.0'),
                Divider(height: 1, color: theme.colorScheme.outlineVariant),
                const _InfoTile(title: 'Build', subtitle: '2024.1'),
                Divider(height: 1, color: theme.colorScheme.outlineVariant),
                const _InfoTile(title: 'Developer', subtitle: 'MathVerse Team'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.sm),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _SettingsSwitch extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitch({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SwitchListTile(
      secondary: Icon(icon, color: theme.colorScheme.primary),
      title: Text(title),
      subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
      value: value,
      onChanged: onChanged,
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String title;
  final String subtitle;

  const _InfoTile({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title, style: Theme.of(context).textTheme.bodyMedium),
      trailing: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
