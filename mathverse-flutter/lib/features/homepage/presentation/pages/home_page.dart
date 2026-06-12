import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const List<_FeatureItem> _features = [
    _FeatureItem('Calculator', 'Basic & scientific calculator', Icons.calculate, '/calculator'),
    _FeatureItem('Derivatives', 'Symbolic differentiation', Icons.functions, '/derivatives'),
    _FeatureItem('Integrals', 'Definite & indefinite integrals', Icons.integration_instructions, '/integrals'),
    _FeatureItem('Limits', 'Limit solver with steps', Icons.trending_up, '/limits'),
    _FeatureItem('Taylor Series', 'Taylor & Maclaurin expansions', Icons.linear_scale, '/taylor'),
    _FeatureItem('DL', 'Développements limités', Icons.auto_fix_high, '/dl'),
    _FeatureItem('Matrix', 'Matrix operations & algebra', Icons.grid_on, '/matrix'),
    _FeatureItem('Statistics', 'Statistical calculations', Icons.bar_chart, '/statistics'),
    _FeatureItem('Graph', 'Function plotting', Icons.show_chart, '/graph'),
    _FeatureItem('History', 'Calculation history', Icons.history, '/history'),
    _FeatureItem('Favorites', 'Saved calculations', Icons.star, '/favorites'),
    _FeatureItem('OCR', 'Scan math expressions', Icons.camera_alt, '/ocr'),
    _FeatureItem('AI Assistant', 'AI-powered math help', Icons.smart_toy, '/assistant'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MathVerse'),
        actions: [
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              if (state is AuthAuthenticated) {
                return PopupMenuButton<String>(
                  icon: CircleAvatar(
                    backgroundColor: AppColors.primary,
                    radius: 16,
                    child: Text(
                      state.user.displayName.isNotEmpty
                          ? state.user.displayName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                  onSelected: (value) {
                    if (value == 'logout') {
                      context.read<AuthCubit>().logout();
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      enabled: false,
                      child: Text(
                        state.user.displayName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout, size: 20),
                          SizedBox(width: 8),
                          Text('Sign Out'),
                        ],
                      ),
                    ),
                  ],
                );
              }
              return TextButton.icon(
                onPressed: () => context.go('/login'),
                icon: const Icon(Icons.login),
                label: const Text('Sign In'),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mathematics Tools',
              style: TextStyle(
                fontSize: AppDimensions.fontSizeXxl,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.sm),
            const Text(
              'Select a tool to get started',
              style: TextStyle(
                fontSize: AppDimensions.fontSizeMd,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: AppDimensions.lg),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.1,
                  crossAxisSpacing: AppDimensions.sm,
                  mainAxisSpacing: AppDimensions.sm,
                ),
                itemCount: _features.length,
                itemBuilder: (context, index) {
                  final feature = _features[index];
                  return _FeatureCard(feature: feature);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureItem {
  final String title;
  final String description;
  final IconData icon;
  final String route;

  const _FeatureItem(this.title, this.description, this.icon, this.route);
}

class _FeatureCard extends StatelessWidget {
  final _FeatureItem feature;

  const _FeatureCard({required this.feature});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => context.go(feature.route),
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(feature.icon, size: 36, color: AppColors.primary),
              const SizedBox(height: AppDimensions.sm),
              Text(
                feature.title,
                style: const TextStyle(
                  fontSize: AppDimensions.fontSizeMd,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.xs),
              Text(
                feature.description,
                style: const TextStyle(
                  fontSize: AppDimensions.fontSizeXs,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
