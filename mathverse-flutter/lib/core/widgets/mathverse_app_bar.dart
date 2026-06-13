import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_elevation.dart';

class MathVerseAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final bool showBackButton;
  final bool? centerTitle;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool useGradient;
  final double elevation;
  final Widget? leading;
  final PreferredSizeWidget? bottom;

  const MathVerseAppBar({
    super.key,
    this.title,
    this.actions,
    this.showBackButton = true,
    this.centerTitle,
    this.backgroundColor,
    this.foregroundColor,
    this.useGradient = false,
    this.elevation = AppElevation.none,
    this.leading,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    final effectiveCenter = centerTitle ?? !isDesktop;

    return AppBar(
      title: title != null ? Text(title!, style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
      )) : null,
      actions: actions,
      automaticallyImplyLeading: showBackButton,
      leading: leading,
      centerTitle: effectiveCenter,
      backgroundColor: backgroundColor ?? theme.colorScheme.surface,
      foregroundColor: foregroundColor ?? theme.colorScheme.onSurface,
      elevation: elevation,
      surfaceTintColor: Colors.transparent,
      bottom: bottom,
      flexibleSpace: useGradient ? Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.secondary,
            ],
          ),
        ),
      ) : null,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
    56 + (bottom?.preferredSize.height ?? 0),
  );
}
