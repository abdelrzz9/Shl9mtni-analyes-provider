import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_sizes.dart';
import '../theme/app_spacing.dart';

class MathResultDisplay extends StatelessWidget {
  final String expression;
  final String result;
  final List<String>? steps;
  final VoidCallback? onCopy;
  final VoidCallback? onShare;
  final VoidCallback? onSave;
  final VoidCallback? onFavorite;
  final bool isFavorite;

  const MathResultDisplay({
    super.key,
    required this.expression,
    required this.result,
    this.steps,
    this.onCopy,
    this.onShare,
    this.onSave,
    this.onFavorite,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildResultCard(context, theme),
        if (steps != null && steps!.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          _buildStepsCard(context, theme),
        ],
      ],
    );
  }

  Widget _buildResultCard(BuildContext context, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.cardPaddingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.secondaryContainer.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary, size: AppSizes.iconMedium),
              const SizedBox(width: AppSpacing.sm),
              Text('Result', style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onPrimaryContainer,
              )),
              const Spacer(),
              _ActionButton(icon: Icons.copy_rounded, onTap: onCopy, tooltip: 'Copy'),
              if (onShare != null)
                _ActionButton(icon: Icons.share_rounded, onTap: onShare, tooltip: 'Share'),
              if (onSave != null)
                _ActionButton(icon: Icons.bookmark_border_rounded, onTap: onSave, tooltip: 'Save'),
              if (onFavorite != null)
                _ActionButton(
                  icon: isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                  onTap: onFavorite,
                  tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
                  color: isFavorite ? AppColors.warning : null,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            expression,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SelectableText(
            result,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimaryContainer,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepsCard(BuildContext context, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.list_alt_rounded, color: theme.colorScheme.primary, size: AppSizes.iconMedium),
              const SizedBox(width: AppSpacing.sm),
              Text('Step-by-Step Solution', style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              )),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...List.generate(steps!.length, (index) {
            return Padding(
              padding: EdgeInsets.only(bottom: index < steps!.length - 1 ? AppSpacing.md : 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: theme.colorScheme.onPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        steps![index],
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontFamily: 'monospace',
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final String tooltip;
  final Color? color;

  const _ActionButton({
    required this.icon,
    this.onTap,
    required this.tooltip,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Icon(
              icon,
              size: AppSizes.iconMedium,
              color: color ?? theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
            ),
          ),
        ),
      ),
    );
  }
}
