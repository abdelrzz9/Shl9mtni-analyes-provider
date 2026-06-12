import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/graph_data.dart';
import '../../domain/usecases/plot_graph.dart';

sealed class GraphEvent extends Equatable {
  const GraphEvent();

  @override
  List<Object?> get props => [];
}

final class Plot extends GraphEvent {
  final String function;
  final double xMin;
  final double xMax;
  final double step;

  const Plot({
    required this.function,
    this.xMin = -10,
    this.xMax = 10,
    this.step = 0.1,
  });

  @override
  List<Object?> get props => [function, xMin, xMax, step];
}

final class ClearGraph extends GraphEvent {
  const ClearGraph();
}

sealed class GraphState extends Equatable {
  const GraphState();

  @override
  List<Object?> get props => [];
}

final class GraphInitial extends GraphState {
  const GraphInitial();
}

final class GraphLoading extends GraphState {
  const GraphLoading();
}

final class GraphResultState extends GraphState {
  final GraphData data;

  const GraphResultState(this.data);

  @override
  List<Object?> get props => [data];
}

final class GraphError extends GraphState {
  final String message;

  const GraphError(this.message);

  @override
  List<Object?> get props => [message];
}

class GraphBloc extends Bloc<GraphEvent, GraphState> {
  final PlotGraph _plotGraph;

  GraphBloc({required PlotGraph plotGraph})
      : _plotGraph = plotGraph,
        super(const GraphInitial()) {
    on<Plot>(_onPlot);
    on<ClearGraph>(_onClear);
  }

  Future<void> _onPlot(Plot event, Emitter<GraphState> emit) async {
    emit(const GraphLoading());
    try {
      final data = await _plotGraph(
        event.function,
        event.xMin,
        event.xMax,
        step: event.step,
      );
      emit(GraphResultState(data));
    } catch (e) {
      emit(GraphError(e.toString()));
    }
  }

  void _onClear(ClearGraph event, Emitter<GraphState> emit) {
    emit(const GraphInitial());
  }
}
