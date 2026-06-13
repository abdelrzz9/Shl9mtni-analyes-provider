import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/loading_widgets.dart';
import '../../../../core/widgets/mathverse_button.dart';
import '../../../../core/widgets/mathverse_card.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../../data/repositories/matrix_repository_impl.dart';
import '../../domain/usecases/matrix_operation.dart';
import '../bloc/matrix_bloc.dart';

class MatrixPage extends StatelessWidget {
  const MatrixPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Matrix Operations')),
      body: BlocProvider(
        create: (_) => MatrixBloc(
          matrixOperation: MatrixOperation(MatrixRepositoryImpl()),
        ),
        child: const _MatrixBody(),
      ),
    );
  }
}

class _MatrixBody extends StatefulWidget {
  const _MatrixBody();

  @override
  State<_MatrixBody> createState() => _MatrixBodyState();
}

class _MatrixBodyState extends State<_MatrixBody> {
  int _rowsA = 3;
  int _colsA = 3;
  int _rowsB = 3;
  int _colsB = 3;
  late List<List<TextEditingController>> _matrixA;
  late List<List<TextEditingController>> _matrixB;
  String _selectedOperation = 'add';

  static const _operations = [
    'add',
    'subtract',
    'multiply',
    'determinant',
    'inverse',
    'transpose',
    'eigenvalues',
  ];

  static const _operationLabels = {
    'add': 'Add',
    'subtract': 'Subtract',
    'multiply': 'Multiply',
    'determinant': 'Determinant',
    'inverse': 'Inverse',
    'transpose': 'Transpose',
    'eigenvalues': 'Eigenvalues',
  };

  static const _operationIcons = {
    'add': Icons.add_rounded,
    'subtract': Icons.remove_rounded,
    'multiply': Icons.close_rounded,
    'determinant': Icons.calculate_rounded,
    'inverse': Icons.replay_rounded,
    'transpose': Icons.swap_horiz_rounded,
    'eigenvalues': Icons.data_array_rounded,
  };

  static const _examples = [
    _Example('2\u00D72', 2, 2, '1,2;3,4'),
    _Example('3\u00D73', 3, 3, '1,2,3;4,5,6;7,8,9'),
    _Example('Identity 3\u00D73', 3, 3, '1,0,0;0,1,0;0,0,1'),
    _Example('2\u00D73', 2, 3, '1,2,3;4,5,6'),
    _Example('Diagonal 3\u00D73', 3, 3, '2,0,0;0,3,0;0,0,5'),
    _Example('4\u00D74', 4, 4, '1,0,0,0;0,1,0,0;0,0,1,0;0,0,0,1'),
  ];

  bool get _needsTwoMatrices =>
      _selectedOperation == 'add' ||
      _selectedOperation == 'subtract' ||
      _selectedOperation == 'multiply';

  @override
  void initState() {
    super.initState();
    _matrixA = _createGrid(_rowsA, _colsA);
    _matrixB = _createGrid(_rowsB, _colsB);
  }

  @override
  void dispose() {
    _disposeGrid(_matrixA);
    _disposeGrid(_matrixB);
    super.dispose();
  }

  List<List<TextEditingController>> _createGrid(int rows, int cols) {
    return List.generate(
      rows,
      (_) => List.generate(cols, (_) => TextEditingController()),
    );
  }

  void _disposeGrid(List<List<TextEditingController>> grid) {
    for (final row in grid) {
      for (final cell in row) {
        cell.dispose();
      }
    }
  }

  void _rebuildMatrixA({bool fill = false}) {
    final old = _matrixA;
    _matrixA = _createGrid(_rowsA, _colsA);
    if (fill) {
      for (var i = 0; i < _rowsA && i < old.length; i++) {
        for (var j = 0; j < _colsA && j < old[i].length; j++) {
          _matrixA[i][j].text = old[i][j].text;
        }
      }
    }
    _disposeGrid(old);
  }

  void _rebuildMatrixB({bool fill = false}) {
    final old = _matrixB;
    _matrixB = _createGrid(_rowsB, _colsB);
    if (fill) {
      for (var i = 0; i < _rowsB && i < old.length; i++) {
        for (var j = 0; j < _colsB && j < old[i].length; j++) {
          _matrixB[i][j].text = old[i][j].text;
        }
      }
    }
    _disposeGrid(old);
  }

  void _onRowsAChanged(int value) {
    setState(() {
      _rowsA = value.clamp(1, 10);
      _rebuildMatrixA(fill: true);
    });
  }

  void _onColsAChanged(int value) {
    setState(() {
      _colsA = value.clamp(1, 10);
      _rebuildMatrixA(fill: true);
    });
  }

  void _onRowsBChanged(int value) {
    setState(() {
      _rowsB = value.clamp(1, 10);
      _rebuildMatrixB(fill: true);
    });
  }

  void _onColsBChanged(int value) {
    setState(() {
      _colsB = value.clamp(1, 10);
      _rebuildMatrixB(fill: true);
    });
  }

  String _buildMatrixString(List<List<TextEditingController>> matrix) {
    return matrix
        .map((row) => row.map((c) {
              final text = c.text.trim();
              return text.isEmpty ? '0' : text;
            }).join(','))
        .join(';');
  }

  void _applyExample(_Example example) {
    setState(() {
      _rowsA = example.rows;
      _colsA = example.cols;
      _rebuildMatrixA();
      final rows = example.matrixString.split(';');
      for (var i = 0; i < rows.length && i < _matrixA.length; i++) {
        final cols = rows[i].split(',');
        for (var j = 0; j < cols.length && j < _matrixA[i].length; j++) {
          _matrixA[i][j].text = cols[j];
        }
      }
    });
  }

  void _calculate() {
    final matrixAStr = _buildMatrixString(_matrixA);
    if (matrixAStr.isEmpty) return;

    context.read<MatrixBloc>().add(PerformMatrixOperation(
      operation: _selectedOperation,
      matrixA: matrixAStr,
      matrixB: _needsTwoMatrices ? _buildMatrixString(_matrixB) : null,
    ));
  }

  void _copyResult(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Result copied'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = context.isDarkMode;

    return BlocBuilder<MatrixBloc, MatrixState>(
      builder: (context, state) {
        final isLoading = state is MatrixLoading;
        final result = state is MatrixResultState ? state.result : null;
        final error = state is MatrixError ? state.message : null;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: AppSpacing.contentMaxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOperationSelector(theme),
                  const SizedBox(height: AppSpacing.lg),
                  _buildMatrixInputCard(theme, isDark),
                  if (_needsTwoMatrices) ...[
                    const SizedBox(height: AppSpacing.lg),
                    _buildMatrixBInputCard(theme, isDark),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  _buildExamplesCard(theme),
                  const SizedBox(height: AppSpacing.xl),
                  _buildCalculateButton(theme, state),
                  const SizedBox(height: AppSpacing.xxl),
                  if (isLoading)
                    _buildLoadingState()
                  else if (error != null)
                    _buildErrorState(error)
                  else if (result != null)
                    _buildResultSection(result, theme, isDark)
                  else
                    const SizedBox.shrink(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOperationSelector(ThemeData theme) {
    return MathVerseCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              Icons.grid_on_rounded,
              size: AppSizes.iconMedium,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: _selectedOperation,
              decoration: const InputDecoration(
                labelText: 'Operation',
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              items: _operations.map((op) {
                return DropdownMenuItem(
                  value: op,
                  child: Row(
                    children: [
                      Icon(
                        _operationIcons[op],
                        size: AppSizes.iconSmall,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(_operationLabels[op]!),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedOperation = value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatrixInputCard(ThemeData theme, bool isDark) {
    return MathVerseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  Icons.border_all_rounded,
                  size: AppSizes.iconMedium,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Matrix A',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildDimensionControls(
            theme: theme,
            rows: _rowsA,
            cols: _colsA,
            onRowsChanged: _onRowsAChanged,
            onColsChanged: _onColsAChanged,
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildMatrixGrid(_matrixA, _rowsA, _colsA, theme),
        ],
      ),
    );
  }

  Widget _buildMatrixBInputCard(ThemeData theme, bool isDark) {
    return MathVerseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  Icons.border_all_rounded,
                  size: AppSizes.iconMedium,
                  color: theme.colorScheme.secondary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Matrix B',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildDimensionControls(
            theme: theme,
            rows: _rowsB,
            cols: _colsB,
            onRowsChanged: _onRowsBChanged,
            onColsChanged: _onColsBChanged,
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildMatrixGrid(_matrixB, _rowsB, _colsB, theme),
        ],
      ),
    );
  }

  Widget _buildDimensionControls({
    required ThemeData theme,
    required int rows,
    required int cols,
    required ValueChanged<int> onRowsChanged,
    required ValueChanged<int> onColsChanged,
  }) {
    return Row(
      children: [
        _buildStepper(
          theme: theme,
          label: 'Rows',
          value: rows,
          min: 1,
          max: 10,
          onChanged: onRowsChanged,
        ),
        const SizedBox(width: AppSpacing.xxl),
        _buildStepper(
          theme: theme,
          label: 'Columns',
          value: cols,
          min: 1,
          max: 10,
          onChanged: onColsChanged,
        ),
      ],
    );
  }

  Widget _buildStepper({
    required ThemeData theme,
    required String label,
    required int value,
    required int min,
    required int max,
    required ValueChanged<int> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(AppRadius.input),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: value > min ? () => onChanged(value - 1) : null,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(AppRadius.input),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Icon(
                    Icons.remove_rounded,
                    size: AppSizes.iconMedium,
                    color: value > min
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant.withAlpha(77),
                  ),
                ),
              ),
              SizedBox(
                width: 36,
                child: Text(
                  '$value',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              InkWell(
                onTap: value < max ? () => onChanged(value + 1) : null,
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(AppRadius.input),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Icon(
                    Icons.add_rounded,
                    size: AppSizes.iconMedium,
                    color: value < max
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant.withAlpha(77),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMatrixGrid(
    List<List<TextEditingController>> matrix,
    int rows,
    int cols,
    ThemeData theme,
  ) {
    if (rows == 0 || cols == 0) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 400;
        final cellWidth = isMobile
            ? (constraints.maxWidth - (cols + 1) * 4) / cols
            : 60.0;
        final cellWidthClamped = cellWidth.clamp(40.0, 80.0);

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: theme.colorScheme.outlineVariant,
              ),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Column headers
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        border: Border(
                          right: BorderSide(
                            color: theme.colorScheme.outlineVariant,
                          ),
                          bottom: BorderSide(
                            color: theme.colorScheme.outlineVariant,
                          ),
                        ),
                      ),
                    ),
                    ...List.generate(cols, (j) {
                      return Container(
                        width: cellWidthClamped,
                        height: 32,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          border: Border(
                            right: j < cols - 1
                                ? BorderSide(
                                    color: theme.colorScheme.outlineVariant)
                                : BorderSide.none,
                            bottom: BorderSide(
                              color: theme.colorScheme.outlineVariant,
                            ),
                          ),
                        ),
                        child: Text(
                          _columnLabel(j),
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
                // Data rows
                ...List.generate(rows, (i) {
                  return Row(
                    children: [
                      // Row header
                      Container(
                        width: 28,
                        height: cellWidthClamped.clamp(36, 48).toDouble(),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          border: Border(
                            right: BorderSide(
                              color: theme.colorScheme.outlineVariant,
                            ),
                            bottom: i < rows - 1
                                ? BorderSide(
                                    color: theme.colorScheme.outlineVariant)
                                : BorderSide.none,
                          ),
                        ),
                        child: Text(
                          '${i + 1}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      // Cells
                      ...List.generate(cols, (j) {
                        return Container(
                          width: cellWidthClamped,
                          height: cellWidthClamped.clamp(36, 48).toDouble(),
                          decoration: BoxDecoration(
                            border: Border(
                              right: j < cols - 1
                                  ? BorderSide(
                                      color: theme.colorScheme.outlineVariant)
                                  : BorderSide.none,
                              bottom: i < rows - 1
                                  ? BorderSide(
                                      color: theme.colorScheme.outlineVariant)
                                  : BorderSide.none,
                            ),
                          ),
                          child: TextField(
                            controller: matrix[i][j],
                            textAlign: TextAlign.center,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                              signed: true,
                            ),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontFamily: 'monospace',
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                            ),
                          ),
                        );
                      }),
                    ],
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  String _columnLabel(int index) {
    if (index < 26) return String.fromCharCode(65 + index);
    return String.fromCharCode(65 + (index ~/ 26) - 1) +
        String.fromCharCode(65 + (index % 26));
  }

  Widget _buildExamplesCard(ThemeData theme) {
    return MathVerseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                size: AppSizes.iconMedium,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Examples',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: _examples.map((example) {
              return ActionChip(
                avatar: Icon(
                  Icons.grid_on_rounded,
                  size: AppSizes.iconSmall,
                  color: theme.colorScheme.primary,
                ),
                label: Text(
                  example.label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontFamily: 'monospace',
                  ),
                ),
                onPressed: () => _applyExample(example),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.chip),
                  side: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculateButton(ThemeData theme, MatrixState state) {
    final isLoading = state is MatrixLoading;
    return MathVerseButton(
      label: _needsTwoMatrices
          ? '${_operationLabels[_selectedOperation]} Matrices'
          : 'Calculate ${_operationLabels[_selectedOperation]}',
      icon: Icons.calculate_rounded,
      isLoading: isLoading,
      onPressed: isLoading ? null : _calculate,
    );
  }

  Widget _buildLoadingState() {
    return const Column(
      children: [
        SkeletonCard(height: 160),
        SizedBox(height: AppSpacing.md),
        SkeletonCard(height: 80),
      ],
    );
  }

  Widget _buildErrorState(String message) {
    return ErrorState(
      icon: Icons.error_outline_rounded,
      title: 'Unable to compute operation',
      message: message,
      onRetry: _calculate,
    );
  }

  Widget _buildResultSection(
    dynamic result,
    ThemeData theme,
    bool isDark,
  ) {
    final stepsList = _parseSteps(result.steps);
    final expression = _buildMatrixExpression(result);
    final resultText = result.result;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGradientResultCard(theme, isDark, expression, resultText),
        if (stepsList != null && stepsList.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          StepByStepCard(
            title: 'Step-by-Step Solution',
            steps: stepsList,
          ),
        ],
      ],
    );
  }

  String _buildMatrixExpression(dynamic result) {
    final op = result.operation;
    final label = _operationLabels[op] ?? op;
    return '$label: ${result.matrixA ?? ''}${result.matrixB != null ? ' \u00D7 ${result.matrixB}' : ''}';
  }

  List<String>? _parseSteps(String? steps) {
    if (steps == null || steps.trim().isEmpty) return null;
    return steps
        .split('\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  Widget _buildGradientResultCard(
    ThemeData theme,
    bool isDark,
    String expression,
    String resultText,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.cardPaddingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppColors.darkPrimaryContainer,
                  AppColors.darkSecondaryContainer.withValues(alpha: 0.4),
                ]
              : [
                  AppColors.primaryContainer,
                  AppColors.secondaryContainer.withValues(alpha: 0.3),
                ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  size: AppSizes.iconMedium,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Result',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const Spacer(),
              _ActionButton(
                icon: Icons.copy_rounded,
                tooltip: 'Copy result',
                onTap: () => _copyResult(resultText),
              ),
              const _ActionButton(
                icon: Icons.share_rounded,
                tooltip: 'Share',
              ),
              const _ActionButton(
                icon: Icons.bookmark_border_rounded,
                tooltip: 'Save',
              ),
              const _ActionButton(
                icon: Icons.star_border_rounded,
                tooltip: 'Add to favorites',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: _isMatrixFormat(resultText)
                ? _buildMatrixDisplay(resultText, theme)
                : SelectableText(
                    resultText,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                      fontFamily: 'monospace',
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  bool _isMatrixFormat(String text) {
    final trimmed = text.trim();
    return trimmed.startsWith('[') && trimmed.endsWith(']');
  }

  Widget _buildMatrixDisplay(String text, ThemeData theme) {
    try {
      final parsed = _parseMatrixString(text);
      if (parsed == null) {
        return SelectableText(
          text,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onPrimaryContainer,
            fontFamily: 'monospace',
          ),
        );
      }

      return FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildBracket(theme, isLeft: true),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: parsed.map((row) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: row.map((cell) {
                        final display = _formatNumber(cell);
                        return SizedBox(
                          width: 72,
                          child: Text(
                            display,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onPrimaryContainer,
                              fontFamily: 'monospace',
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }).toList(),
              ),
            ),
            _buildBracket(theme, isLeft: false),
          ],
        ),
      );
    } catch (_) {
      return SelectableText(
        text,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onPrimaryContainer,
          fontFamily: 'monospace',
        ),
      );
    }
  }

  List<List<double>>? _parseMatrixString(String text) {
    final trimmed = text.trim();
    if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
      final inner = trimmed.substring(1, trimmed.length - 1).trim();
      if (inner.startsWith('[')) {
        final rows = <List<double>>[];
        var depth = 0;
        var start = 0;
        for (var i = 0; i < inner.length; i++) {
          if (inner[i] == '[') {
            if (depth == 0) start = i + 1;
            depth++;
          } else if (inner[i] == ']') {
            depth--;
            if (depth == 0) {
              final rowStr = inner.substring(start, i);
              final parts = rowStr.split(',');
              final row = parts.map((p) {
                final trimmed = p.trim();
                if (trimmed.isEmpty) return 0.0;
                if (trimmed.contains('/')) {
                  final fracParts = trimmed.split('/');
                  return double.tryParse(fracParts[0]) ?? 0.0 /
                      (double.tryParse(fracParts[1]) ?? 1.0);
                }
                return double.tryParse(trimmed) ?? 0.0;
              }).toList();
              rows.add(row);
            }
          }
        }
        return rows.isNotEmpty ? rows : null;
      }
    }
    return null;
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(4).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  Widget _buildBracket(ThemeData theme, {required bool isLeft}) {
    return Container(
      width: 16,
      alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
      child: Text(
        isLeft ? '\u23A1' : '\u23A4',
        style: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.w100,
          color: theme.colorScheme.primary,
          fontFamily: 'monospace',
          height: 1.2,
        ),
      ),
    );
  }
}

class _Example {
  final String label;
  final int rows;
  final int cols;
  final String matrixString;

  const _Example(this.label, this.rows, this.cols, this.matrixString);
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.tooltip,
    this.onTap,
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
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Icon(
              icon,
              size: AppSizes.iconMedium,
              color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
            ),
          ),
        ),
      ),
    );
  }
}
