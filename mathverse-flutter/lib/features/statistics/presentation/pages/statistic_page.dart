import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/loading_widgets.dart';
import '../../../../core/widgets/mathverse_button.dart';
import '../../../../core/widgets/mathverse_card.dart';
import '../../../../core/widgets/mathverse_input.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../../data/repositories/statistic_repository_impl.dart';
import '../../domain/usecases/calculate_statistic.dart';
import '../bloc/statistic_bloc.dart';

class StatisticPage extends StatelessWidget {
  const StatisticPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: BlocProvider(
        create: (_) => StatisticBloc(
          calculateStatistic: CalculateStatistic(StatisticRepositoryImpl()),
        ),
        child: const _StatisticBody(),
      ),
    );
  }
}

class _StatisticBody extends StatefulWidget {
  const _StatisticBody();

  @override
  State<_StatisticBody> createState() => _StatisticBodyState();
}

class _StatisticBodyState extends State<_StatisticBody> {
  final _dataController = TextEditingController();
  final _data2Controller = TextEditingController();
  String _selectedOperation = 'mean';
  bool _showBarChart = true;
  bool _isLoading = false;

  final _results = <String, String>{};
  String? _currentOperation;
  String? _currentDetails;
  String? _errorMessage;

  final _operations = [
    'mean', 'median', 'mode', 'stdDev', 'variance', 'correlation',
  ];

  static const _operationLabels = {
    'mean': 'Mean',
    'median': 'Median',
    'mode': 'Mode',
    'stdDev': 'Std Deviation',
    'variance': 'Variance',
    'correlation': 'Correlation',
  };

  static const _operationIcons = {
    'mean': Icons.calculate_outlined,
    'median': Icons.sort_rounded,
    'mode': Icons.multiline_chart_rounded,
    'stdDev': Icons.show_chart_rounded,
    'variance': Icons.space_bar_rounded,
    'correlation': Icons.link_rounded,
  };

  @override
  void dispose() {
    _dataController.dispose();
    _data2Controller.dispose();
    super.dispose();
  }

  bool get _needsTwoDataSets => _selectedOperation == 'correlation';

  List<double> _parseData(String input) {
    return input.split(',')
        .map((e) => double.tryParse(e.trim()))
        .where((e) => e != null)
        .cast<double>()
        .toList();
  }

  void _calculate() {
    final data = _parseData(_dataController.text);
    if (data.isEmpty) return;
    List<double>? data2;
    if (_needsTwoDataSets) {
      final parsed = _parseData(_data2Controller.text);
      if (parsed.isEmpty) return;
      data2 = parsed;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    context.read<StatisticBloc>().add(Calculate(
      operation: _selectedOperation,
      data: data,
      data2: data2,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final padding = context.screenPadding;

    return BlocListener<StatisticBloc, StatisticState>(
      listener: (context, state) {
        if (state is StatisticResultState) {
          setState(() {
            _isLoading = false;
            _results[state.result.operation] = state.result.result;
            _currentOperation = state.result.operation;
            _currentDetails = state.result.details;
          });
        } else if (state is StatisticError) {
          setState(() {
            _isLoading = false;
            _errorMessage = state.message;
          });
        }
      },
      child: SingleChildScrollView(
        padding: padding,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: context.maxContentWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildControls(context),
              const SizedBox(height: AppSpacing.xxl),
              _buildResultsSection(context),
              if (_dataController.text.isNotEmpty)
                _buildChartSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControls(BuildContext context) {
    final theme = Theme.of(context);
    return MathVerseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart_rounded, size: AppSizes.iconMedium, color: theme.colorScheme.primary),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Statistics Calculator',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          DropdownButtonFormField<String>(
            initialValue: _selectedOperation,
            decoration: InputDecoration(
              labelText: 'Operation',
              filled: true,
              fillColor: theme.colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.input),
                borderSide: BorderSide(color: theme.colorScheme.outline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.input),
                borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.input),
                borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.inputHorizontal,
                vertical: AppSpacing.inputVertical,
              ),
            ),
            items: _operations.map((op) {
              return DropdownMenuItem(
                value: op,
                child: Row(
                  children: [
                    Icon(_operationIcons[op], size: AppSizes.iconMedium),
                    const SizedBox(width: AppSpacing.sm),
                    Text(_operationLabels[op] ?? op),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() => _selectedOperation = value!);
            },
          ),
          const SizedBox(height: AppSpacing.md),
          MathVerseInput(
            controller: _dataController,
            labelText: 'Dataset',
            hintText: 'e.g., 1, 2, 3, 4, 5',
            helperText: 'Comma-separated numbers',
            prefixIcon: const Icon(Icons.data_array_rounded, size: AppSizes.iconMedium),
          ),
          if (_needsTwoDataSets) ...[
            const SizedBox(height: AppSpacing.md),
            MathVerseInput(
              controller: _data2Controller,
              labelText: 'Second dataset',
              hintText: 'e.g., 2, 4, 6, 8, 10',
              helperText: 'Comma-separated numbers',
              prefixIcon: const Icon(Icons.data_array_rounded, size: AppSizes.iconMedium),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          MathVerseButton(
            label: 'Calculate ${_operationLabels[_selectedOperation]}',
            onPressed: _calculate,
            isLoading: _isLoading,
            icon: Icons.play_arrow_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildResultsSection(BuildContext context) {
    if (_isLoading) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'Results'),
          SizedBox(height: AppSpacing.md),
          SkeletonCard(height: 100),
        ],
      );
    }

    if (_errorMessage != null) {
      return ErrorState(
        message: _errorMessage!,
        title: 'Calculation Error',
        onRetry: _calculate,
        icon: Icons.error_outline_rounded,
      );
    }

    if (_results.isEmpty) {
      return const EmptyState(
        icon: Icons.bar_chart_rounded,
        title: 'No Results Yet',
        subtitle: 'Enter your dataset above and tap Calculate',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Results'),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            for (final op in _operations)
              _buildStatCard(context, op),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String operation) {
    final theme = Theme.of(context);
    final isActive = operation == _currentOperation;
    final value = _results[operation];
    final label = _operationLabels[operation] ?? operation;
    final icon = _operationIcons[operation] ?? Icons.calculate_outlined;
    final showDetails = isActive && _currentDetails != null;

    if (value == null && !isActive) {
      return SizedBox(
        width: context.isDesktop ? 200 : (context.screenWidth - context.horizontalPadding * 2 - AppSpacing.md) / 2,
        child: MathVerseCard(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: AppSizes.iconMedium, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
              const SizedBox(height: AppSpacing.sm),
              Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '—',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      width: context.isDesktop ? 200 : (context.screenWidth - context.horizontalPadding * 2 - AppSpacing.md) / 2,
      child: MathVerseCard(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        color: isActive ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3) : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: AppSizes.iconMedium,
                  color: isActive ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isActive ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isActive) ...[
                  const SizedBox(width: AppSpacing.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      'active',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm, horizontal: AppSpacing.sm),
              decoration: BoxDecoration(
                color: isActive
                    ? theme.colorScheme.primaryContainer.withValues(alpha: 0.2)
                    : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Text(
                value ?? '—',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isActive ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                ),
              ),
            ),
            if (showDetails) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                _currentDetails!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChartSection(BuildContext context) {
    final data = _parseData(_dataController.text);
    if (data.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.xxl),
        Row(
          children: [
            Icon(Icons.visibility_rounded, size: AppSizes.iconMedium, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Visualization',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: true,
                  icon: Icon(Icons.bar_chart_rounded, size: AppSizes.iconMedium),
                  label: Text('Bar'),
                ),
                ButtonSegment(
                  value: false,
                  icon: Icon(Icons.show_chart_rounded, size: AppSizes.iconMedium),
                  label: Text('Line'),
                ),
              ],
              selected: {_showBarChart},
              onSelectionChanged: (value) => setState(() => _showBarChart = value.first),
              style: const ButtonStyle(
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        MathVerseCard(
          child: SizedBox(
            height: AppSizes.graphHeight,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: _showBarChart ? _buildBarChart(context, data) : _buildLineChart(context, data),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart(BuildContext context, List<double> data) {
    final theme = Theme.of(context);
    final maxY = data.reduce((a, b) => a > b ? a : b) * 1.3;
    final effectiveMaxY = maxY > 0 ? maxY : 1.0;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: effectiveMaxY,
        minY: 0,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipRoundedRadius: AppRadius.sm,
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                rod.toY.toStringAsFixed(2),
                TextStyle(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                  fontSize: AppTypography.labelMediumSize,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < data.length) {
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(
                      '${index + 1}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 42,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
        ),
        gridData: FlGridData(
          horizontalInterval: (effectiveMaxY / 4).clamp(0.1, double.infinity),
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
              strokeWidth: 1,
            );
          },
          drawVerticalLine: false,
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(data.length, (index) {
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: data[index],
                color: AppColors.chartColors[index % AppColors.chartColors.length],
                width: 16,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.xs),
                  topRight: Radius.circular(AppRadius.xs),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildLineChart(BuildContext context, List<double> data) {
    final theme = Theme.of(context);
    final maxY = data.reduce((a, b) => a > b ? a : b) * 1.2;
    final minY = data.reduce((a, b) => a < b ? a : b);
    final adjustedMinY = minY > 0 ? 0.0 : minY * 1.2;

    return LineChart(
      LineChartData(
        minY: adjustedMinY,
        maxY: maxY > 0 ? maxY : 1.0,
        clipData: const FlClipData.all(),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  spot.y.toStringAsFixed(2),
                  TextStyle(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                    fontSize: AppTypography.labelMediumSize,
                  ),
                );
              }).toList();
            },
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < data.length) {
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(
                      '${index + 1}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 42,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
        ),
        gridData: FlGridData(
          horizontalInterval: (maxY / 4).clamp(0.1, double.infinity),
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.1),
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(color: theme.colorScheme.outlineVariant),
            left: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(data.length, (index) => FlSpot(index.toDouble(), data[index])),
            isCurved: true,
            preventCurveOverShooting: true,
            color: AppColors.chart1,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: AppColors.chart1,
                  strokeWidth: 2,
                  strokeColor: theme.colorScheme.surface,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.chart1.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }
}
