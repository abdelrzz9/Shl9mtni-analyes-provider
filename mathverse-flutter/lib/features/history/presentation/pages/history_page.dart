import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/loading_widgets.dart';
import '../../../../core/widgets/mathverse_card.dart';
import '../../../../core/widgets/mathverse_input.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../../domain/entities/history_entry.dart';
import '../bloc/history_bloc.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded),
            tooltip: 'Clear all history',
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Clear History'),
                  content: const Text('Clear all history entries? This cannot be undone.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () {
                        context.read<HistoryBloc>().add(const ClearAllHistory());
                        Navigator.pop(ctx);
                      },
                      child: const Text('Clear', style: TextStyle(color: AppColors.error)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: const _HistoryBody(),
    );
  }
}

class _HistoryBody extends StatefulWidget {
  const _HistoryBody();
  @override
  State<_HistoryBody> createState() => _HistoryBodyState();
}

class _HistoryBodyState extends State<_HistoryBody> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedFeature;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  static const _features = [
    null,
    'calculator',
    'derivatives',
    'integrals',
    'limits',
    'taylor',
    'matrix',
    'statistics',
  ];

  IconData _getIcon(String feature) {
    switch (feature.toLowerCase()) {
      case 'calculator': return Icons.calculate_rounded;
      case 'derivatives': return Icons.functions_rounded;
      case 'integrals': return Icons.integration_instructions_rounded;
      case 'limits': return Icons.trending_up_rounded;
      case 'taylor': return Icons.linear_scale_rounded;
      case 'matrix': return Icons.grid_on_rounded;
      case 'statistics': return Icons.bar_chart_rounded;
      default: return Icons.calculate_rounded;
    }
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final entryDate = DateTime(dt.year, dt.month, dt.day);

    if (entryDate == today) return 'Today';
    if (entryDate == yesterday) return 'Yesterday';
    if (entryDate.isAfter(today.subtract(Duration(days: today.weekday - 1)))) {
      return 'This Week';
    }
    return 'Earlier';
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Map<String, List<HistoryEntry>> _groupEntries(List<HistoryEntry> entries) {
    final groups = <String, List<HistoryEntry>>{};
    final order = ['Today', 'Yesterday', 'This Week', 'Earlier'];
    for (final entry in entries) {
      final key = _formatDate(entry.timestamp);
      groups.putIfAbsent(key, () => []);
      groups[key]!.add(entry);
    }
    final sorted = <String, List<HistoryEntry>>{};
    for (final key in order) {
      if (groups.containsKey(key)) {
        sorted[key] = groups[key]!;
      }
    }
    for (final key in groups.keys) {
      if (!order.contains(key)) {
        sorted.putIfAbsent(key, () => groups[key]!);
      }
    }
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<HistoryBloc, HistoryState>(
      builder: (context, state) {
        if (state is HistoryLoading) {
          return const Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: SkeletonList(),
          );
        }
        if (state is HistoryError) {
          return ErrorState(
            message: state.message,
            title: 'Failed to load history',
            icon: Icons.history_rounded,
            onRetry: () => context.read<HistoryBloc>().add(const LoadHistory()),
          );
        }
        if (state is! HistoryLoaded) {
          return const SizedBox.shrink();
        }
        var entries = state.entries;
        if (_searchQuery.isNotEmpty) {
          entries = entries.where((e) =>
            e.input.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            e.result.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            e.feature.toLowerCase().contains(_searchQuery.toLowerCase())
          ).toList();
        }
        if (_selectedFeature != null) {
          entries = entries.where((e) =>
            e.feature.toLowerCase() == _selectedFeature!.toLowerCase()
          ).toList();
        }
        if (entries.isEmpty) {
          return EmptyState(
            icon: Icons.history_rounded,
            title: 'No history yet',
            subtitle: 'Your calculations and results will appear here',
            actionLabel: _searchQuery.isEmpty && _selectedFeature == null ? null : 'Clear filters',
            onAction: () {
              setState(() {
                _searchController.clear();
                _searchQuery = '';
                _selectedFeature = null;
              });
            },
          );
        }
        final grouped = _groupEntries(entries);
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
              child: Column(
                children: [
                  MathVerseSearchBar(
                    controller: _searchController,
                    hintText: 'Search history...',
                    onChanged: (value) => setState(() => _searchQuery = value),
                    onClear: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _features.length,
                      separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final feature = _features[index];
                        final isSelected = _selectedFeature == feature;
                        return FilterChip(
                          label: Text(
                            feature == null ? 'All' : feature[0].toUpperCase() + feature.substring(1),
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (_) => setState(() => _selectedFeature = isSelected ? null : feature),
                          visualDensity: VisualDensity.compact,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xxl),
                children: grouped.entries.map((group) {
                  return _buildGroup(context, theme, group.key, group.value);
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGroup(BuildContext context, ThemeData theme, String label, List<HistoryEntry> entries) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Row(
            children: [
              Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  '${entries.length}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...entries.map((entry) => _buildEntry(context, theme, entry)),
      ],
    );
  }

  Widget _buildEntry(BuildContext context, ThemeData theme, HistoryEntry entry) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: AppSpacing.md),
            width: 2,
            height: 40,
            decoration: BoxDecoration(
              color: entry.isFavorite
                  ? AppColors.warning
                  : theme.colorScheme.primary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: MathVerseCard(
              onTap: () {},
              onLongPress: () => context.read<HistoryBloc>().add(DeleteHistory(entry.id)),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(
                      _getIcon(entry.feature),
                      size: AppSizes.iconMedium,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.input,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontFamily: 'monospace',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          '= ${entry.result}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontFamily: 'monospace',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 1),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(AppRadius.full),
                              ),
                              child: Text(
                                entry.feature,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              _formatTime(entry.timestamp),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      entry.isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                      color: entry.isFavorite ? AppColors.warning : null,
                    ),
                    onPressed: () => context.read<HistoryBloc>().add(ToggleHistoryFavorite(entry.id)),
                    tooltip: entry.isFavorite ? 'Remove from favorites' : 'Add to favorites',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
