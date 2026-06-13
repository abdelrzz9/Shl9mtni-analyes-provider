import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/mathverse_button.dart';
import '../../../../core/widgets/mathverse_card.dart';
import '../../../../core/widgets/mathverse_input.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../../data/repositories/graph_repository_impl.dart';
import '../../domain/entities/graph_data.dart';
import '../../domain/usecases/plot_graph.dart';
import '../bloc/graph_bloc.dart';

class GraphPage extends StatelessWidget {
  const GraphPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Function Graph')),
      body: BlocProvider(
        create: (_) => GraphBloc(
          plotGraph: PlotGraph(GraphRepositoryImpl()),
        ),
        child: const _GraphBody(),
      ),
    );
  }
}

class _GraphBody extends StatefulWidget {
  const _GraphBody();

  @override
  State<_GraphBody> createState() => _GraphBodyState();
}

class _GraphBodyState extends State<_GraphBody> {
  final _functionController = TextEditingController();
  final _xMinController = TextEditingController(text: '-10');
  final _xMaxController = TextEditingController(text: '10');
  final _stepController = TextEditingController(text: '0.1');

  bool _isFullScreen = false;
  Point? _trackedPoint;
  double _yMin = 0;
  double _yMax = 0;

  static const _suggestions = ['x^2', 'sin(x)', 'cos(x)', 'tan(x)', 'exp(x)', '1/x'];

  @override
  void dispose() {
    _functionController.dispose();
    _xMinController.dispose();
    _xMaxController.dispose();
    _stepController.dispose();
    super.dispose();
  }

  void _plot() {
    if (_functionController.text.isEmpty) return;
    setState(() {
      _trackedPoint = null;
    });
    final xMin = double.tryParse(_xMinController.text) ?? -10;
    final xMax = double.tryParse(_xMaxController.text) ?? 10;
    final step = double.tryParse(_stepController.text) ?? 0.1;
    context.read<GraphBloc>().add(Plot(
      function: _functionController.text,
      xMin: xMin,
      xMax: xMax,
      step: step,
    ));
  }

  void _onSuggestionTap(String example) {
    _functionController.text = example;
    _functionController.selection = TextSelection.fromPosition(
      TextPosition(offset: example.length),
    );
  }

  void _resetView() {
    _xMinController.text = '-10';
    _xMaxController.text = '10';
    _stepController.text = '0.1';
    _plot();
  }

  void _zoomIn() {
    final currentMin = double.tryParse(_xMinController.text) ?? -10;
    final currentMax = double.tryParse(_xMaxController.text) ?? 10;
    final range = currentMax - currentMin;
    final center = (currentMin + currentMax) / 2;
    final newRange = range * 0.7;
    _xMinController.text = (center - newRange / 2).toStringAsFixed(2);
    _xMaxController.text = (center + newRange / 2).toStringAsFixed(2);
    _plot();
  }

  void _zoomOut() {
    final currentMin = double.tryParse(_xMinController.text) ?? -10;
    final currentMax = double.tryParse(_xMaxController.text) ?? 10;
    final range = currentMax - currentMin;
    final center = (currentMin + currentMax) / 2;
    final newRange = range * 1.4;
    _xMinController.text = (center - newRange / 2).toStringAsFixed(2);
    _xMaxController.text = (center + newRange / 2).toStringAsFixed(2);
    _plot();
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });
  }

  void _onGraphTap(Offset localPosition, BoxConstraints constraints, GraphData data) {
    if (data.points.isEmpty) return;
    final yValues = data.points.map((p) => p.y).where((y) => y.isFinite).toList();
    if (yValues.isEmpty) return;
    final yMin = yValues.reduce((a, b) => a < b ? a : b);
    final yMax = yValues.reduce((a, b) => a > b ? a : b);
    final xRange = data.xMax - data.xMin;
    final yRange = yMax - yMin;
    if (xRange == 0 || yRange == 0) return;

    final graphX = (localPosition.dx / constraints.maxWidth) * xRange + data.xMin;
    final graphY = ((constraints.maxHeight - localPosition.dy) / constraints.maxHeight) * yRange + yMin;

    setState(() {
      _trackedPoint = Point(x: graphX, y: graphY);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GraphBloc, GraphState>(
      builder: (context, state) {
        return _isFullScreen
            ? _buildFullScreen(state)
            : _buildNormalScreen(state);
      },
    );
  }

  Widget _buildFullScreen(GraphState state) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Stack(
          children: [
            _buildGraphArea(state, fullScreen: true),
            Positioned(
              top: AppSpacing.md,
              left: AppSpacing.md,
              child: _FullScreenCloseButton(onTap: _toggleFullScreen),
            ),
            _buildCoordinateTracker(),
            Positioned(
              right: AppSpacing.md,
              bottom: AppSpacing.xxl,
              child: _buildFABColumn(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNormalScreen(GraphState state) {
    final isDesktop = context.isDesktop;

    if (isDesktop) {
      return Row(
        children: [
          Expanded(
            flex: 3,
            child: _buildGraphPanel(state),
          ),
          SizedBox(
            width: 360,
            child: _buildControlsPanel(state),
          ),
        ],
      );
    }

    return Column(
      children: [
        Expanded(
          flex: 3,
          child: _buildGraphPanel(state),
        ),
        _buildControlsHandle(),
      ],
    );
  }

  Widget _buildGraphPanel(GraphState state) {
    return Stack(
      children: [
        _buildGraphArea(state, fullScreen: false),
        _buildCoordinateTracker(),
        Positioned(
          right: AppSpacing.sm,
          bottom: AppSpacing.sm,
          child: _buildMiniFABRow(state),
        ),
      ],
    );
  }

  Widget _buildGraphArea(GraphState state, {required bool fullScreen}) {
    if (state is GraphLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is GraphResultState) {
      final data = state.data;
      if (data.points.isEmpty) {
        return const Center(child: Text('No points to display'));
      }
      final yValues = data.points.map((p) => p.y).where((y) => y.isFinite).toList();
      if (yValues.isNotEmpty) {
        _yMin = yValues.reduce((a, b) => a < b ? a : b);
        _yMax = yValues.reduce((a, b) => a > b ? a : b);
      }

      return LayoutBuilder(
        builder: (context, constraints) {
          return GestureDetector(
            onTapUp: (details) => _onGraphTap(details.localPosition, constraints, data),
            child: Container(
              color: Theme.of(context).colorScheme.surface,
              child: CustomPaint(
                size: Size(constraints.maxWidth, constraints.maxHeight),
                painter: _GraphPainter(
                  points: data.points,
                  xMin: data.xMin,
                  xMax: data.xMax,
                  yMin: _yMin,
                  yMax: _yMax,
                  color: AppColors.chartColors[0],
                  trackedPoint: _trackedPoint,
                  isDark: context.isDarkMode,
                ),
              ),
            ),
          );
        },
      );
    }

    if (state is GraphError) {
      return ErrorState(
        icon: Icons.show_chart_rounded,
        title: 'Unable to plot graph',
        message: state.message,
        onRetry: _plot,
      );
    }

    return EmptyState(
      icon: Icons.show_chart_rounded,
      title: 'Graph Calculator',
      subtitle: 'Enter a function and tap Plot to see the graph',
      actionLabel: 'Get Started',
      onAction: () {},
    );
  }

  Widget _buildCoordinateTracker() {
    if (_trackedPoint == null) return const SizedBox.shrink();

    return Positioned(
      top: AppSpacing.sm,
      right: AppSpacing.sm,
      child: MathVerseCard(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _CoordinateChip(
              label: 'x',
              value: _trackedPoint!.x.toStringAsFixed(3),
              color: AppColors.chart1,
            ),
            const SizedBox(width: AppSpacing.sm),
            _CoordinateChip(
              label: 'y',
              value: _trackedPoint!.y.toStringAsFixed(3),
              color: AppColors.chart2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlsHandle() {
    return GestureDetector(
      onTap: () => _showControlsSheet(),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withAlpha(30),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withAlpha(77),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Function Controls',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showControlsSheet() {
    final isDesktop = context.isDesktop;
    final sheetHeight = isDesktop ? 0.8 : 0.7;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      ),
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: sheetHeight,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: EdgeInsets.only(
                left: AppSpacing.screenPadding,
                right: AppSpacing.screenPadding,
                top: AppSpacing.lg,
                bottom: MediaQuery.of(context).padding.bottom + AppSpacing.lg,
              ),
              child: _buildControlsPanel(stateFromContext(sheetContext)),
            );
          },
        );
      },
    );
  }

  GraphState stateFromContext(BuildContext sheetContext) {
    return context.read<GraphBloc>().state;
  }

  Widget _buildControlsPanel(GraphState state) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withAlpha(77),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                Icons.functions_rounded,
                size: AppSizes.iconMedium,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              'Graph Controls',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        MathVerseInput(
          controller: _functionController,
          labelText: 'f(x)',
          hintText: 'x^2, sin(x), cos(x)',
          prefixIcon: Icon(
            Icons.functions_rounded,
            size: AppSizes.iconMedium,
            color: theme.colorScheme.primary,
          ),
          onSubmitted: (_) => _plot(),
        ),
        const SizedBox(height: AppSpacing.md),
        _buildSuggestions(theme),
        const SizedBox(height: AppSpacing.xl),
        _buildRangeControls(theme),
        const SizedBox(height: AppSpacing.lg),
        _buildPlotButton(),
        if (state is GraphResultState) ...[
          const SizedBox(height: AppSpacing.xl),
          _buildLegend(theme, state.data),
        ],
      ],
    );
  }

  Widget _buildSuggestions(ThemeData theme) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: _suggestions.map((suggestion) {
        return ActionChip(
          label: Text(
            suggestion,
            style: theme.textTheme.labelMedium?.copyWith(
              fontFamily: 'monospace',
              fontWeight: FontWeight.w500,
            ),
          ),
          onPressed: () => _onSuggestionTap(suggestion),
          visualDensity: VisualDensity.compact,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.chip),
            side: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRangeControls(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'X-Axis Range',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: MathVerseInput(
                controller: _xMinController,
                labelText: 'Min',
                hintText: '-10',
                keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.only(top: AppSpacing.xl),
              child: Icon(
                Icons.arrow_forward_rounded,
                size: AppSizes.iconSmall,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: MathVerseInput(
                controller: _xMaxController,
                labelText: 'Max',
                hintText: '10',
                keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        MathVerseInput(
          controller: _stepController,
          labelText: 'Step Size',
          hintText: '0.1',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
      ],
    );
  }

  Widget _buildPlotButton() {
    return MathVerseButton(
      label: 'Plot Graph',
      icon: Icons.show_chart_rounded,
      onPressed: _plot,
    );
  }

  Widget _buildLegend(ThemeData theme, GraphData data) {
    final color = AppColors.chartColors[0];
    return MathVerseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.legend_toggle_rounded, size: AppSizes.iconMedium, color: theme.colorScheme.primary),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Legend',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _LegendItem(
            color: color,
            label: 'f(x) = ${data.function}',
            range: '[${data.xMin.toStringAsFixed(1)}, ${data.xMax.toStringAsFixed(1)}]',
            points: data.points.length,
          ),
        ],
      ),
    );
  }

  Widget _buildFABColumn() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _GraphFAB(
          icon: Icons.fullscreen_exit_rounded,
          tooltip: 'Exit Full Screen',
          onPressed: _toggleFullScreen,
        ),
        const SizedBox(height: AppSpacing.sm),
        _GraphFAB(
          icon: Icons.center_focus_strong_rounded,
          tooltip: 'Reset View',
          onPressed: _resetView,
        ),
        const SizedBox(height: AppSpacing.sm),
        _GraphFAB(
          icon: Icons.add_rounded,
          tooltip: 'Zoom In',
          onPressed: _zoomIn,
        ),
        const SizedBox(height: AppSpacing.sm),
        _GraphFAB(
          icon: Icons.remove_rounded,
          tooltip: 'Zoom Out',
          onPressed: _zoomOut,
        ),
      ],
    );
  }

  Widget _buildMiniFABRow(GraphState state) {
    final hasData = state is GraphResultState;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _GraphMiniFAB(
          icon: Icons.fullscreen_rounded,
          tooltip: 'Full Screen',
          onPressed: _toggleFullScreen,
        ),
        const SizedBox(width: AppSpacing.xs),
        _GraphMiniFAB(
          icon: Icons.center_focus_strong_rounded,
          tooltip: 'Reset View',
          onPressed: hasData ? _resetView : null,
        ),
        const SizedBox(width: AppSpacing.xs),
        _GraphMiniFAB(
          icon: Icons.add_rounded,
          tooltip: 'Zoom In',
          onPressed: hasData ? _zoomIn : null,
        ),
        const SizedBox(width: AppSpacing.xs),
        _GraphMiniFAB(
          icon: Icons.remove_rounded,
          tooltip: 'Zoom Out',
          onPressed: hasData ? _zoomOut : null,
        ),
      ],
    );
  }
}

class _GraphPainter extends CustomPainter {
  final List<Point> points;
  final double xMin;
  final double xMax;
  final double yMin;
  final double yMax;
  final Color color;
  final Point? trackedPoint;
  final bool isDark;

  _GraphPainter({
    required this.points,
    required this.xMin,
    required this.xMax,
    this.yMin = 0,
    this.yMax = 0,
    this.color = AppColors.chart1,
    this.trackedPoint,
    this.isDark = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final xRange = xMax - xMin;
    final yRange = yMax - yMin;
    if (xRange == 0 || yRange == 0) return;

    final effectiveYMin = yMin;
    final effectiveYMax = yMax;

    _drawGrid(canvas, size, xRange, effectiveYMax - effectiveYMin);
    _drawAxes(canvas, size, xRange, effectiveYMax - effectiveYMin, effectiveYMin);
    _drawGraphLine(canvas, size, xRange, effectiveYMax - effectiveYMin, effectiveYMin);

    if (trackedPoint != null) {
      _drawTracker(canvas, size, xRange, effectiveYMax - effectiveYMin, effectiveYMin);
    }
  }

  void _drawGrid(Canvas canvas, Size size, double xRange, double yRange) {
    final gridPaint = Paint()
      ..color = (isDark ? AppColors.darkOutlineVariant : AppColors.outlineVariant).withAlpha(60)
      ..strokeWidth = 0.5;

    final xStep = _niceStep(xRange / 5);
    final yStep = _niceStep(yRange / 5);

    for (double x = (xMin / xStep).floor() * xStep; x <= xMax; x += xStep) {
      final px = ((x - xMin) / xRange) * size.width;
      canvas.drawLine(Offset(px, 0), Offset(px, size.height), gridPaint);
    }

    for (double y = (yMin / yStep).floor() * yStep; y <= yMax; y += yStep) {
      final py = size.height - ((y - yMin) / yRange) * size.height;
      canvas.drawLine(Offset(0, py), Offset(size.width, py), gridPaint);
    }
  }

  double _niceStep(double range) {
    if (range <= 0) return 1;
    final exp = (math.log(range) / math.ln10).floor();
    final base = math.pow(10, exp).toDouble();
    final r = range / base;
    if (r <= 2) return 0.2 * base;
    if (r <= 5) return 0.5 * base;
    return base;
  }

  void _drawAxes(Canvas canvas, Size size, double xRange, double yRange, double effectiveYMin) {
    final axisPaint = Paint()
      ..color = (isDark ? AppColors.darkOutline : AppColors.outline).withAlpha(120)
      ..strokeWidth = 1.5;

    final y0 = size.height - ((0 - effectiveYMin) / yRange) * size.height;
    if (y0 >= 0 && y0 <= size.height) {
      canvas.drawLine(Offset(0, y0), Offset(size.width, y0), axisPaint);
    }

    final x0 = ((0 - xMin) / xRange) * size.width;
    if (x0 >= 0 && x0 <= size.width) {
      canvas.drawLine(Offset(x0, 0), Offset(x0, size.height), axisPaint);
    }

    _drawLabels(canvas, size, xRange, yRange);
  }

  void _drawLabels(Canvas canvas, Size size, double xRange, double yRange) {
    final labelStyle = TextStyle(
      color: (isDark ? AppColors.darkOnSurfaceVariant : AppColors.onSurfaceVariant).withAlpha(150),
      fontSize: 10,
    );
    final xStep = _niceStep(xRange / 5);
    final yStep = _niceStep(yRange / 5);

    for (double x = (xMin / xStep).floor() * xStep; x <= xMax; x += xStep) {
      if (x == 0) continue;
      final px = ((x - xMin) / xRange) * size.width;
      final label = x == x.roundToDouble() ? x.toInt().toString() : x.toStringAsFixed(1);
      final textSpan = TextSpan(text: label, style: labelStyle);
      final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr)..layout();
      textPainter.paint(canvas, Offset(px - textPainter.width / 2, size.height - 14));
    }

    for (double y = (yMin / yStep).floor() * yStep; y <= yMax; y += yStep) {
      if (y == 0) continue;
      final py = size.height - ((y - yMin) / yRange) * size.height;
      final label = y == y.roundToDouble() ? y.toInt().toString() : y.toStringAsFixed(1);
      final textSpan = TextSpan(text: label, style: labelStyle);
      final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr)..layout();
      textPainter.paint(canvas, Offset(4, py - textPainter.height / 2));
    }
  }

  void _drawGraphLine(Canvas canvas, Size size, double xRange, double yRange, double effectiveYMin) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    double transformX(double x) => ((x - xMin) / xRange) * size.width;
    double transformY(double y) => size.height - ((y - effectiveYMin) / yRange) * size.height;

    final path = Path();
    bool pathStarted = false;

    for (var i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      if (!p1.y.isFinite || !p2.y.isFinite) {
        pathStarted = false;
        continue;
      }
      final x1 = transformX(p1.x);
      final y1 = transformY(p1.y);
      if (!pathStarted) {
        path.moveTo(x1, y1);
        pathStarted = true;
      }
      path.lineTo(transformX(p2.x), transformY(p2.y));
    }

    canvas.drawPath(path, paint);

    final glowPaint = Paint()
      ..color = color.withAlpha(40)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, glowPaint);
  }

  void _drawTracker(Canvas canvas, Size size, double xRange, double yRange, double effectiveYMin) {
    if (trackedPoint == null) return;

    final trackX = ((trackedPoint!.x - xMin) / xRange) * size.width;
    final trackY = size.height - ((trackedPoint!.y - effectiveYMin) / yRange) * size.height;

    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(trackX, trackY), 5, dotPaint);

    final ringPaint = Paint()
      ..color = color.withAlpha(80)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(Offset(trackX, trackY), 8, ringPaint);

    final crossPaint = Paint()
      ..color = (isDark ? AppColors.darkOutlineVariant : AppColors.outlineVariant).withAlpha(100)
      ..strokeWidth = 1;

    canvas.drawLine(Offset(trackX, 0), Offset(trackX, size.height), crossPaint);
    canvas.drawLine(Offset(0, trackY), Offset(size.width, trackY), crossPaint);
  }

  @override
  bool shouldRepaint(covariant _GraphPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.xMin != xMin ||
        oldDelegate.xMax != xMax ||
        oldDelegate.yMin != yMin ||
        oldDelegate.yMax != yMax ||
        oldDelegate.color != color ||
        oldDelegate.trackedPoint != trackedPoint;
  }
}

class _GraphFAB extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _GraphFAB({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tooltip(
      message: tooltip,
      child: Material(
        color: theme.colorScheme.surfaceContainerLow,
        elevation: 3,
        shadowColor: theme.shadowColor,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            child: Icon(icon, size: AppSizes.iconLarge, color: theme.colorScheme.primary),
          ),
        ),
      ),
    );
  }
}

class _GraphMiniFAB extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  const _GraphMiniFAB({
    required this.icon,
    required this.tooltip,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tooltip(
      message: tooltip,
      child: Material(
        color: onPressed != null
            ? theme.colorScheme.surfaceContainerLow.withAlpha(240)
            : theme.colorScheme.surfaceContainerLow.withAlpha(80),
        elevation: 2,
        shadowColor: theme.shadowColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: AppSizes.iconMedium,
              color: onPressed != null
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant.withAlpha(80),
            ),
          ),
        ),
      ),
    );
  }
}

class _FullScreenCloseButton extends StatelessWidget {
  final VoidCallback onTap;

  const _FullScreenCloseButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerLow.withAlpha(220),
      elevation: 3,
      shadowColor: theme.shadowColor,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          child: Icon(Icons.close_rounded, size: AppSizes.iconLarge, color: theme.colorScheme.primary),
        ),
      ),
    );
  }
}

class _CoordinateChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _CoordinateChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String range;
  final int points;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.range,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 20,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: 'monospace',
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          range,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '$points pts',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
