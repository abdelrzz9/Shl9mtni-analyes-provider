import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../extensions/responsive.dart';
import '../theme/app_spacing.dart';
import '../theme/app_sizes.dart';
import '../theme/app_colors.dart';
import '../theme/app_animations.dart';
import '../theme/app_radius.dart';
import 'navigation_config.dart';

class AppScaffold extends StatefulWidget {
  final Widget child;

  const AppScaffold({super.key, required this.child});

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  @override
  Widget build(BuildContext context) {
    if (context.useNavigationRail) {
      return _buildDesktopLayout();
    } else if (context.useNavigationBar) {
      return _buildMobileLayout();
    } else {
      return _buildMobileLayout();
    }
  }

  Widget _buildDesktopLayout() {
    final location = GoRouterState.of(context).uri.toString();
    final selectedIndex = _selectedNavIndex(location);

    return Row(
      children: [
        _NavigationRail(
          selectedIndex: selectedIndex,
          onDestinationSelected: (index) => _onNavTap(
            NavigationConfig.primaryItems[index].route,
          ),
        ),
        const VerticalDivider(width: 1, thickness: 1),
        Expanded(
          child: Scaffold(
            drawer: _buildDrawer(),
            body: widget.child,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    final location = GoRouterState.of(context).uri.toString();
    final selectedIndex = _selectedNavIndex(location);

    return Scaffold(
      drawer: _buildDrawer(),
      body: widget.child,
      bottomNavigationBar: _BottomNavBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) => _onNavTap(
          NavigationConfig.primaryItems[index].route,
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      width: AppSizes.drawerWidth,
      child: _DrawerContent(
        currentRoute: GoRouterState.of(context).uri.toString(),
        onTap: (route) {
          Navigator.pop(context);
          _onNavTap(route);
        },
      ),
    );
  }

  void _onNavTap(String route) {
    final currentRoute = GoRouterState.of(context).uri.toString();
    if (currentRoute != route) {
      context.go(route);
    }
  }

  int _selectedNavIndex(String location) {
    for (int i = 0; i < NavigationConfig.primaryItems.length; i++) {
      if (location == NavigationConfig.primaryItems[i].route) {
        return i;
      }
    }
    return 0;
  }
}

class _NavigationRail extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const _NavigationRail({
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      labelType: NavigationRailLabelType.all,
      backgroundColor: theme.colorScheme.surface,
      indicatorColor: theme.colorScheme.primaryContainer,
      leading: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_awesome,
              color: theme.colorScheme.primary,
              size: 28,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'MV',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
      destinations: NavigationConfig.primaryItems.map((item) {
        return NavigationRailDestination(
          icon: Icon(item.icon),
          selectedIcon: Icon(item.activeIcon),
          label: Text(item.label),
        );
      }).toList(),
      trailing: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () => Scaffold.of(context).openDrawer(),
          tooltip: 'Menu',
        ),
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const _BottomNavBar({
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant.withAlpha(77),
            width: 0.5,
          ),
        ),
      ),
      child: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        backgroundColor: Colors.transparent,
        elevation: 0,
        height: AppSizes.navigationBarHeight,
        animationDuration: AppAnimations.normal,
        destinations: NavigationConfig.primaryItems.map((item) {
          return NavigationDestination(
            icon: Icon(item.icon),
            selectedIcon: Icon(item.activeIcon),
            label: item.label,
          );
        }).toList(),
      ),
    );
  }
}

class _DrawerContent extends StatelessWidget {
  final String currentRoute;
  final void Function(String route) onTap;

  const _DrawerContent({
    required this.currentRoute,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DrawerHeader(
            isDark: isDark,
            onTap: () => onTap(NavigationConfig.home),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _DrawerSection(
                  title: 'Mathematics',
                  items: NavigationConfig.mathItems,
                  currentRoute: currentRoute,
                  onTap: onTap,
                ),
                _DrawerSection(
                  title: 'Tools',
                  items: NavigationConfig.toolItems,
                  currentRoute: currentRoute,
                  onTap: onTap,
                ),
                _DrawerSection(
                  title: 'Personal',
                  items: NavigationConfig.personalItems,
                  currentRoute: currentRoute,
                  onTap: onTap,
                ),
              ],
            ),
          ),
          _DrawerFooter(currentRoute: currentRoute, onTap: onTap),
        ],
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  final bool isDark;
  final VoidCallback onTap;

  const _DrawerHeader({required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.xxl,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.gradientStart, AppColors.gradientEnd],
                ),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MathVerse',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                Text(
                  'Advanced Mathematics',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerSection extends StatelessWidget {
  final String title;
  final List<NavigationItem> items;
  final String currentRoute;
  final void Function(String route) onTap;

  const _DrawerSection({
    required this.title,
    required this.items,
    required this.currentRoute,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.xs,
          ),
          child: Text(
            title.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
              letterSpacing: 1.2,
            ),
          ),
        ),
        ...items.map((item) {
          final isSelected = currentRoute == item.route;
          return _DrawerItem(
            item: item,
            isSelected: isSelected,
            onTap: () => onTap(item.route),
          );
        }),
      ],
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final NavigationItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 1),
      child: Material(
        color: isSelected
            ? theme.colorScheme.primaryContainer.withAlpha(128)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? item.activeIcon : item.icon,
                  size: 20,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  item.label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DrawerFooter extends StatelessWidget {
  final String currentRoute;
  final void Function(String route) onTap;

  const _DrawerFooter({
    required this.currentRoute,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: theme.colorScheme.outlineVariant.withAlpha(77),
              ),
            ),
          ),
          child: Column(
            children: [
              _DrawerItem(
                item: const NavigationItem(
                  label: 'Settings',
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings_rounded,
                  route: NavigationConfig.settings,
                ),
                isSelected: currentRoute == NavigationConfig.settings,
                onTap: () {},
              ),
              if (state is AuthAuthenticated) ...[
                _DrawerItem(
                  item: const NavigationItem(
                    label: 'Profile',
                    icon: Icons.person_outlined,
                    activeIcon: Icons.person_rounded,
                    route: NavigationConfig.profile,
                  ),
                  isSelected: currentRoute == NavigationConfig.profile,
                  onTap: () {},
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Text(
                          state.user.displayName.isNotEmpty
                              ? state.user.displayName[0].toUpperCase()
                              : '?',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          state.user.displayName,
                          style: theme.textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout, size: 18),
                        onPressed: () => context.read<AuthCubit>().logout(),
                        tooltip: 'Sign Out',
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  child: OutlinedButton.icon(
                    onPressed: () => onTap(NavigationConfig.login),
                    icon: const Icon(Icons.login, size: 18),
                    label: const Text('Sign In'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 40),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
