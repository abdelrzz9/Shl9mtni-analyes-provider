import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/responsive.dart';
import '../../../../core/navigation/navigation_config.dart';
import '../../../../core/theme/animation_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/mathverse_card.dart';
import '../../../../core/widgets/mathverse_input.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../history/presentation/bloc/history_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const List<_FeatureItem> _features = [
    _FeatureItem('Calculator', 'Basic & scientific calculator', Icons.calculate_rounded, '/calculator', MathToolCategory.math),
    _FeatureItem('Derivatives', 'Symbolic differentiation', Icons.functions_rounded, '/derivatives', MathToolCategory.math),
    _FeatureItem('Integrals', 'Definite & indefinite integrals', Icons.integration_instructions_rounded, '/integrals', MathToolCategory.math),
    _FeatureItem('Limits', 'Limit solver with steps', Icons.trending_up_rounded, '/limits', MathToolCategory.math),
    _FeatureItem('Taylor Series', 'Taylor & Maclaurin expansions', Icons.linear_scale_rounded, '/taylor', MathToolCategory.math),
    _FeatureItem('DL', 'Développements limités', Icons.auto_fix_high_rounded, '/dl', MathToolCategory.math),
    _FeatureItem('Matrix', 'Matrix operations & algebra', Icons.grid_on_rounded, '/matrix', MathToolCategory.math),
    _FeatureItem('Statistics', 'Statistical calculations', Icons.bar_chart_rounded, '/statistics', MathToolCategory.data),
    _FeatureItem('Graph', 'Function plotting', Icons.show_chart_rounded, '/graph', MathToolCategory.data),
    _FeatureItem('History', 'Calculation history', Icons.history_rounded, '/history', MathToolCategory.personal),
    _FeatureItem('Favorites', 'Saved calculations', Icons.star_rounded, '/favorites', MathToolCategory.personal),
    _FeatureItem('OCR', 'Scan math expressions', Icons.document_scanner_rounded, '/ocr', MathToolCategory.data),
    _FeatureItem('AI Assistant', 'AI-powered math help', Icons.smart_toy_rounded, '/assistant', MathToolCategory.personal),
  ];

  static const List<_FeatureItem> _mathTools = [
    _FeatureItem('Calculator', 'Basic & scientific calculator', Icons.calculate_rounded, '/calculator', MathToolCategory.math),
    _FeatureItem('Derivatives', 'Symbolic differentiation', Icons.functions_rounded, '/derivatives', MathToolCategory.math),
    _FeatureItem('Integrals', 'Definite & indefinite integrals', Icons.integration_instructions_rounded, '/integrals', MathToolCategory.math),
    _FeatureItem('Limits', 'Limit solver with steps', Icons.trending_up_rounded, '/limits', MathToolCategory.math),
    _FeatureItem('Taylor Series', 'Taylor & Maclaurin expansions', Icons.linear_scale_rounded, '/taylor', MathToolCategory.math),
    _FeatureItem('DL', 'Développements limités', Icons.auto_fix_high_rounded, '/dl', MathToolCategory.math),
    _FeatureItem('Matrix', 'Matrix operations & algebra', Icons.grid_on_rounded, '/matrix', MathToolCategory.math),
  ];

  static const List<_FeatureItem> _dataTools = [
    _FeatureItem('Statistics', 'Statistical calculations', Icons.bar_chart_rounded, '/statistics', MathToolCategory.data),
    _FeatureItem('Graph', 'Function plotting', Icons.show_chart_rounded, '/graph', MathToolCategory.data),
    _FeatureItem('OCR', 'Scan math expressions', Icons.document_scanner_rounded, '/ocr', MathToolCategory.data),
  ];

  static const List<_FeatureItem> _personalTools = [
    _FeatureItem('History', 'Calculation history', Icons.history_rounded, '/history', MathToolCategory.personal),
    _FeatureItem('Favorites', 'Saved calculations', Icons.star_rounded, '/favorites', MathToolCategory.personal),
    _FeatureItem('AI Assistant', 'AI-powered math help', Icons.smart_toy_rounded, '/assistant', MathToolCategory.personal),
  ];

  static const List<_SuggestionChip> _suggestions = [
    _SuggestionChip('2 + 2', Icons.calculate_outlined),
    _SuggestionChip('x² + 2x + 1', Icons.functions_outlined),
    _SuggestionChip('sin(π/2)', Icons.auto_awesome_outlined),
    _SuggestionChip('∫ x² dx', Icons.integration_instructions_outlined),
    _SuggestionChip('d/dx x³', Icons.auto_fix_high_outlined),
    _SuggestionChip('Matrix 3x3', Icons.grid_on_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = context.isMobile ? 2 : (context.isTablet ? 3 : 4);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: context.screenPadding.copyWith(bottom: 0),
            sliver: SliverToBoxAdapter(
              child: _SearchSection(),
            ),
          ),
          SliverPadding(
            padding: context.screenPadding.copyWith(bottom: 0),
            sliver: SliverToBoxAdapter(
              child: _GreetingSection(),
            ),
          ),
          SliverToBoxAdapter(
            child: _SuggestionsRow(),
          ),
          SliverToBoxAdapter(
            child: _QuickActionCards(),
          ),
          SliverToBoxAdapter(
            child: _RecentSection(),
          ),
          SliverToBoxAdapter(
            child: _FavoritesShortcut(),
          ),
          SliverPadding(
            padding: EdgeInsets.only(
              top: AppSpacing.xxxl,
              left: context.horizontalPadding,
              right: context.horizontalPadding,
            ),
            sliver: SliverToBoxAdapter(
              child: _AnimatedSectionHeader(
                title: 'Math Tools',
                icon: Icons.functions_rounded,
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: context.horizontalPadding,
            ),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 1.3,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => _FeatureCard(feature: _mathTools[index]),
                childCount: _mathTools.length,
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.only(
              top: AppSpacing.xxxl,
              left: context.horizontalPadding,
              right: context.horizontalPadding,
            ),
            sliver: SliverToBoxAdapter(
              child: _AnimatedSectionHeader(
                title: 'Data Tools',
                icon: Icons.bar_chart_rounded,
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: context.horizontalPadding,
            ),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount.clamp(0, 3),
                childAspectRatio: 1.3,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => _FeatureCard(feature: _dataTools[index]),
                childCount: _dataTools.length,
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.only(
              top: AppSpacing.xxxl,
              left: context.horizontalPadding,
              right: context.horizontalPadding,
            ),
            sliver: SliverToBoxAdapter(
              child: _AnimatedSectionHeader(
                title: 'Personal',
                icon: Icons.person_rounded,
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: context.horizontalPadding,
              vertical: AppSpacing.xxl,
            ),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount.clamp(0, 3),
                childAspectRatio: 1.3,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => _FeatureCard(feature: _personalTools[index]),
                childCount: _personalTools.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum MathToolCategory { math, data, personal }

class _FeatureItem {
  final String title;
  final String description;
  final IconData icon;
  final String route;
  final MathToolCategory category;

  const _FeatureItem(this.title, this.description, this.icon, this.route, this.category);
}

class _SuggestionChip {
  final String label;
  final IconData icon;

  const _SuggestionChip(this.label, this.icon);
}

class _SearchSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.lg),
      child: MathVerseSearchBar(
        hintText: 'Search math tools, expressions...',
        onTap: () => _showSearchOverlay(context),
      ),
    );
  }

  void _showSearchOverlay(BuildContext context) {
    showSearch(context: context, delegate: _MathSearchDelegate());
  }
}

class _MathSearchDelegate extends SearchDelegate<String?> {
  @override
  String get searchFieldLabel => 'Search tools, formulas...';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_rounded),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildSuggestions(context);

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSuggestions(context);
  }

  Widget _buildSuggestions(BuildContext context) {
    final results = query.isEmpty
        ? HomePage._features
        : HomePage._features.where((f) =>
            f.title.toLowerCase().contains(query.toLowerCase()) ||
            f.description.toLowerCase().contains(query.toLowerCase()),
          ).toList();

    if (results.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xxxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: AppSizes.iconMassive,
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              ),
              SizedBox(height: AppSpacing.lg),
              Text(
                'No results found',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: AppSpacing.xs),
              Text(
                'Try a different search term',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];
        return ListTile(
          leading: Container(
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(item.icon, size: AppSizes.iconMedium, color: Theme.of(context).colorScheme.primary),
          ),
          title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(item.description, style: Theme.of(context).textTheme.bodySmall),
          trailing: Icon(Icons.chevron_right_rounded, color: Theme.of(context).colorScheme.onSurfaceVariant),
          onTap: () {
            close(context, null);
            context.go(item.route);
          },
        );
      },
    );
  }
}

class _GreetingSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final isAuthenticated = state is AuthAuthenticated;
        final name = isAuthenticated ? state.user.displayName : '';
        final greeting = _greetingForTime();
        final displayName = isAuthenticated && name.isNotEmpty ? name : 'there';

        return Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.xxl),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$greeting$displayName',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      isAuthenticated
                          ? 'Ready to solve something?'
                          : 'Sign in to sync your calculations across devices',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (isAuthenticated)
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: AppSizes.avatarSmall / 2,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                )
              else
                TextButton.icon(
                  onPressed: () => context.go(NavigationConfig.login),
                  icon: Icon(Icons.login_rounded, size: AppSizes.iconMedium),
                  label: const Text('Sign In'),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                    backgroundColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.button),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  String _greetingForTime() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning, ';
    if (hour < 17) return 'Good afternoon, ';
    return 'Good evening, ';
  }
}

class _SuggestionsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: context.horizontalPadding,
        bottom: AppSpacing.xxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick solve',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: HomePage._suggestions.length,
              separatorBuilder: (_, _) => SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) {
                final chip = HomePage._suggestions[index];
                return ActionChip(
                  avatar: Icon(chip.icon, size: 16),
                  label: Text(
                    chip.label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () => _onSuggestionTap(context, chip.label),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.chip),
                    side: BorderSide(
                      color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  backgroundColor: theme.colorScheme.surfaceContainerLow,
                  elevation: 0,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _onSuggestionTap(BuildContext context, String expression) {
    context.go(NavigationConfig.calculator);
  }
}

class _QuickActionCards extends StatelessWidget {
  static const List<_QuickAction> _actions = [
    _QuickAction('Calculator', Icons.calculate_rounded, AppColors.primary, NavigationConfig.calculator),
    _QuickAction('Graph', Icons.show_chart_rounded, AppColors.tertiary, NavigationConfig.graph),
    _QuickAction('AI Assistant', Icons.smart_toy_rounded, AppColors.secondary, NavigationConfig.assistant),
    _QuickAction('OCR', Icons.document_scanner_rounded, AppColors.info, NavigationConfig.ocr),
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;

    return Padding(
      padding: EdgeInsets.only(
        left: context.horizontalPadding,
        right: context.horizontalPadding,
        bottom: AppSpacing.xxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick actions',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          if (isMobile)
            ..._actions.map((action) => Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.sm),
              child: _QuickActionCard(action: action),
            ))
          else
            Row(
              children: _actions.map((action) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: action == _actions.last ? 0 : AppSpacing.md,
                  ),
                  child: _QuickActionCard(action: action),
                ),
              )).toList(),
            ),
        ],
      ),
    );
  }
}

class _QuickAction {
  final String label;
  final IconData icon;
  final Color color;
  final String route;

  const _QuickAction(this.label, this.icon, this.color, this.route);
}

class _QuickActionCard extends StatelessWidget {
  final _QuickAction action;

  const _QuickActionCard({required this.action});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = context.isDarkMode;

    return MathVerseCard(
      onTap: () => context.go(action.route),
      padding: EdgeInsets.all(AppSpacing.lg),
      color: isDark
          ? action.color.withValues(alpha: 0.12)
          : action.color.withValues(alpha: 0.08),
      border: Border.all(
        color: action.color.withValues(alpha: isDark ? 0.2 : 0.15),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: action.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(action.icon, color: action.color, size: AppSizes.iconLarge),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              action.label,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
            size: AppSizes.iconMedium,
          ),
        ],
      ),
    );
  }
}

class _RecentSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: context.horizontalPadding,
        right: context.horizontalPadding,
        bottom: AppSpacing.xxl,
      ),
      child: BlocBuilder<HistoryBloc, HistoryState>(
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                title: 'Continue working',
                actionLabel: state is HistoryLoaded && state.entries.isNotEmpty ? 'View all' : null,
                onAction: state is HistoryLoaded && state.entries.isNotEmpty
                    ? () => context.go(NavigationConfig.history)
                    : null,
              ),
              SizedBox(height: AppSpacing.md),
              if (state is HistoryLoaded && state.entries.isNotEmpty)
                ...state.entries.take(3).map((entry) => Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.sm),
                  child: MathVerseCard(
                    onTap: () => context.go(NavigationConfig.history),
                    padding: EdgeInsets.all(AppSpacing.lg),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(AppSpacing.xs),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Icon(
                            Icons.history_rounded,
                            size: AppSizes.iconMedium,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.input,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'monospace',
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: AppSpacing.xxs),
                              Text(
                                entry.result.isNotEmpty ? '= ${entry.result}' : '',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontFamily: 'monospace',
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Text(
                          _timeAgo(entry.timestamp),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ))
              else
                _buildEmptyRecent(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyRecent(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.xxxl),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.history_rounded,
              size: AppSizes.iconHuge,
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          Text(
            'No recent calculations',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            'Your calculations will appear here',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}

class _FavoritesShortcut extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = context.isMobile;

    return Padding(
      padding: EdgeInsets.only(
        left: context.horizontalPadding,
        right: context.horizontalPadding,
        bottom: AppSpacing.xxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Favorites',
            actionLabel: 'View all',
            onAction: () => context.go(NavigationConfig.favorites),
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: MathVerseCard(
                  onTap: () => context.go(NavigationConfig.favorites),
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: Icon(
                              Icons.star_rounded,
                              color: AppColors.warning,
                              size: AppSizes.iconLarge,
                            ),
                          ),
                          Spacer(),
                          if (!isMobile)
                            Text(
                              'Saved calculations',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.md),
                      Text(
                        'Quick access to your favorites',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (!isMobile) ...[
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: MathVerseCard(
                    onTap: () => context.go(NavigationConfig.history),
                    padding: EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(AppSpacing.sm),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(AppRadius.md),
                              ),
                              child: Icon(
                                Icons.history_rounded,
                                color: theme.colorScheme.secondary,
                                size: AppSizes.iconLarge,
                              ),
                            ),
                            Spacer(),
                            Text(
                              'All history',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppSpacing.md),
                        Text(
                          'Browse past calculations',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _AnimatedSectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _AnimatedSectionHeader({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: AnimationConstants.normal,
      curve: AnimationConstants.decelerateCurve,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 8 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              icon,
              size: AppSizes.iconSmall,
              color: theme.colorScheme.primary,
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final _FeatureItem feature;

  const _FeatureCard({required this.feature});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = context.isDarkMode;

    return MathVerseCard(
      onTap: () => context.go(feature.route),
      padding: EdgeInsets.all(AppSpacing.lg),
      hasShadow: false,
      color: theme.colorScheme.surfaceContainerLow,
      border: Border.all(
        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: _categoryColor(theme).withValues(alpha: isDark ? 0.15 : 0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              feature.icon,
              size: AppSizes.iconLarge,
              color: _categoryColor(theme),
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            feature.title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: AppSpacing.xxs),
          Text(
            feature.description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Color _categoryColor(ThemeData theme) {
    switch (feature.category) {
      case MathToolCategory.math:
        return theme.colorScheme.primary;
      case MathToolCategory.data:
        return theme.colorScheme.tertiary;
      case MathToolCategory.personal:
        return theme.colorScheme.secondary;
    }
  }
}
