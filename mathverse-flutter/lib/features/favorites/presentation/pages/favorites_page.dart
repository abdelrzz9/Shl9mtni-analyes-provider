import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/loading_widgets.dart';
import '../../../../core/widgets/mathverse_card.dart';
import '../../../../core/widgets/mathverse_input.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../../../history/domain/entities/history_entry.dart';
import '../../../history/presentation/bloc/history_bloc.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: const _FavoritesBody(),
    );
  }
}

class _FavoritesBody extends StatefulWidget {
  const _FavoritesBody();
  @override
  State<_FavoritesBody> createState() => _FavoritesBodyState();
}

class _FavoritesBodyState extends State<_FavoritesBody> {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<HistoryBloc, HistoryState>(
      builder: (context, state) {
        if (state is HistoryLoading) {
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: SkeletonGrid(itemCount: 4, crossAxisCount: context.isDesktop ? 3 : context.isTablet ? 2 : 2),
          );
        }
        if (state is HistoryError) {
          return ErrorState(
            message: state.message,
            title: 'Failed to load favorites',
            icon: Icons.star_rounded,
            onRetry: () => context.read<HistoryBloc>().add(const LoadHistory()),
          );
        }
        if (state is! HistoryLoaded) {
          return const SizedBox.shrink();
        }
        var favorites = state.entries.where((e) => e.isFavorite).toList();
        if (_searchQuery.isNotEmpty) {
          favorites = favorites.where((e) =>
            e.input.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            e.result.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            e.feature.toLowerCase().contains(_searchQuery.toLowerCase())
          ).toList();
        }
        if (_selectedFeature != null) {
          favorites = favorites.where((e) =>
            e.feature.toLowerCase() == _selectedFeature!.toLowerCase()
          ).toList();
        }
        if (favorites.isEmpty) {
          return EmptyState(
            icon: Icons.star_rounded,
            title: 'No favorites yet',
            subtitle: 'Tap the star icon on any calculation result to save it here',
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
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
              child: Column(
                children: [
                  MathVerseSearchBar(
                    controller: _searchController,
                    hintText: 'Search favorites...',
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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth > 900 ? 3 : constraints.maxWidth > 600 ? 2 : 2;
                  final childAspectRatio = constraints.maxWidth > 900 ? 1.2 : 1.1;
                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xxl),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: childAspectRatio,
                      crossAxisSpacing: AppSpacing.md,
                      mainAxisSpacing: AppSpacing.md,
                    ),
                    itemCount: favorites.length,
                    itemBuilder: (context, index) {
                      final entry = favorites[index];
                      return _FavoriteCard(
                        entry: entry,
                        icon: _getIcon(entry.feature),
                        onUnfavorite: () => context.read<HistoryBloc>().add(ToggleHistoryFavorite(entry.id)),
                        onTap: () {},
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  final HistoryEntry entry;
  final IconData icon;
  final VoidCallback onUnfavorite;
  final VoidCallback onTap;

  const _FavoriteCard({
    required this.entry,
    required this.icon,
    required this.onUnfavorite,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MathVerseCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  icon,
                  size: AppSizes.iconMedium,
                  color: theme.colorScheme.primary,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.star_rounded, color: AppColors.warning),
                onPressed: onUnfavorite,
                tooltip: 'Remove from favorites',
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            entry.input,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontFamily: 'monospace',
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '= ${entry.result}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontFamily: 'monospace',
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
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
        ],
      ),
    );
  }
}
