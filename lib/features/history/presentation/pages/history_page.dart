import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../data/repositories/history_repository_impl.dart';
import '../../domain/entities/history_entry.dart';
import '../../domain/usecases/get_history.dart';
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
            icon: const Icon(Icons.delete_sweep),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Clear History'),
                  content: const Text('Clear all history entries?'),
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
      body: BlocProvider(
        create: (_) {
          final repo = HistoryRepositoryImpl();
          return HistoryBloc(
            getHistory: GetHistory(repo),
            addHistoryEntry: AddHistoryEntry(repo),
            deleteHistoryEntry: DeleteHistoryEntry(repo),
            clearHistory: ClearHistory(repo),
            toggleFavorite: ToggleFavorite(repo),
          )..add(const LoadHistory());
        },
        child: const _HistoryBody(),
      ),
    );
  }
}

class _HistoryBody extends StatelessWidget {
  const _HistoryBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HistoryBloc, HistoryState>(
      builder: (context, state) {
        if (state is HistoryLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is HistoryLoaded) {
          if (state.entries.isEmpty) {
            return const Center(child: Text('No history yet'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppDimensions.sm),
            itemCount: state.entries.length,
            itemBuilder: (context, index) {
              final entry = state.entries[index];
              return _HistoryCard(entry: entry);
            },
          );
        }
        if (state is HistoryError) {
          return Center(child: Text(state.message, style: const TextStyle(color: AppColors.error)));
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final HistoryEntry entry;

  const _HistoryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: AppDimensions.xs),
      child: ListTile(
        leading: Icon(
          _getIcon(entry.feature),
          color: AppColors.primary,
        ),
        title: Text(entry.input, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('= ${entry.result}'),
            Text(
              '${entry.feature} • ${_formatDate(entry.timestamp)}',
              style: const TextStyle(fontSize: AppDimensions.fontSizeXs, color: Colors.grey),
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            entry.isFavorite ? Icons.star : Icons.star_border,
            color: entry.isFavorite ? AppColors.warning : null,
          ),
          onPressed: () => context.read<HistoryBloc>().add(ToggleHistoryFavorite(entry.id)),
        ),
        onLongPress: () {
          context.read<HistoryBloc>().add(DeleteHistory(entry.id));
        },
      ),
    );
  }

  IconData _getIcon(String feature) {
    switch (feature.toLowerCase()) {
      case 'calculator': return Icons.calculate;
      case 'derivatives': return Icons.functions;
      case 'integrals': return Icons.integration_instructions;
      case 'limits': return Icons.trending_up;
      case 'taylor': return Icons.linear_scale;
      case 'matrix': return Icons.grid_on;
      case 'statistics': return Icons.bar_chart;
      default: return Icons.calculate;
    }
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
