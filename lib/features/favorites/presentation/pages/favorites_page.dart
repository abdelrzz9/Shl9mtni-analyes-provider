import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../history/data/repositories/history_repository_impl.dart';
import '../../../history/domain/usecases/get_history.dart';
import '../../../history/presentation/bloc/history_bloc.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
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
        child: const _FavoritesBody(),
      ),
    );
  }
}

class _FavoritesBody extends StatelessWidget {
  const _FavoritesBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HistoryBloc, HistoryState>(
      builder: (context, state) {
        if (state is HistoryLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is HistoryLoaded) {
          final favorites = state.entries.where((e) => e.isFavorite).toList();
          if (favorites.isEmpty) {
            return const Center(child: Text('No favorites yet'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppDimensions.sm),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final entry = favorites[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: AppDimensions.xs),
                child: ListTile(
                  title: Text(entry.input, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('= ${entry.result}'),
                      Text(entry.feature, style: const TextStyle(fontSize: AppDimensions.fontSizeXs, color: Colors.grey)),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.star, color: AppColors.warning),
                    onPressed: () => context.read<HistoryBloc>().add(ToggleHistoryFavorite(entry.id)),
                  ),
                ),
              );
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
