import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _functionController,
            decoration: const InputDecoration(
              labelText: 'Function f(x)',
              hintText: 'e.g., x^2, sin(x), cos(x)',
            ),
          ),
          const SizedBox(height: AppDimensions.md),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _xMinController,
                  decoration: const InputDecoration(labelText: 'X min'),
                ),
              ),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: TextField(
                  controller: _xMaxController,
                  decoration: const InputDecoration(labelText: 'X max'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          TextField(
            controller: _stepController,
            decoration: const InputDecoration(labelText: 'Step'),
          ),
          const SizedBox(height: AppDimensions.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _plot,
              child: const Text('Plot'),
            ),
          ),
          const SizedBox(height: AppDimensions.lg),
          BlocBuilder<GraphBloc, GraphState>(
            builder: (context, state) {
              if (state is GraphLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is GraphResultState) {
                final data = state.data;
                return Column(
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppDimensions.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Graph Info', style: TextStyle(fontWeight: FontWeight.bold, fontSize: AppDimensions.fontSizeLg)),
                            const SizedBox(height: AppDimensions.sm),
                            Text('f(x) = ${data.function}'),
                            Text('Range: [${data.xMin}, ${data.xMax}]'),
                            Text('Points: ${data.points.length}'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.md),
                    SizedBox(
                      height: 300,
                      child: CustomPaint(
                        size: Size.infinite,
                        painter: _GraphPainter(
                          points: data.points,
                          xMin: data.xMin,
                          xMax: data.xMax,
                        ),
                      ),
                    ),
                  ],
                );
              }
              if (state is GraphError) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.md),
                    child: Text(state.message, style: const TextStyle(color: AppColors.error)),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}

class _GraphPainter extends CustomPainter {
  final List<Point> points;
  final double xMin;
  final double xMax;

  _GraphPainter({
    required this.points,
    required this.xMin,
    required this.xMax,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final paint = Paint()
      ..color = AppColors.chartLine1
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final yValues = points.map((p) => p.y).where((y) => y.isFinite).toList();
    if (yValues.isEmpty) return;
    final yMin = yValues.reduce((a, b) => a < b ? a : b);
    final yMax = yValues.reduce((a, b) => a > b ? a : b);
    final yRange = yMax - yMin;
    final xRange = xMax - xMin;

    if (xRange == 0 || yRange == 0) return;

    double transformX(double x) => ((x - xMin) / xRange) * size.width;
    double transformY(double y) => size.height - ((y - yMin) / yRange) * size.height;

    for (var i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      if (!p1.y.isFinite || !p2.y.isFinite) continue;
      canvas.drawLine(
        Offset(transformX(p1.x), transformY(p1.y)),
        Offset(transformX(p2.x), transformY(p2.y)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GraphPainter oldDelegate) {
    return oldDelegate.points != points;
  }
}
