import 'package:flutter/material.dart';

/// Centered title app bar with optional leading back and trailing actions.
class EsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const EsAppBar({
    super.key,
    required this.title,
    this.leading,
    this.onLeadingPressed,
    this.actions,
    this.automaticallyImplyLeading = true,
  });

  final String title;
  final Widget? leading;
  final VoidCallback? onLeadingPressed;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveLeading = leading ??
        (automaticallyImplyLeading
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                onPressed: onLeadingPressed ?? () => Navigator.of(context).maybePop(),
              )
            : null);

    return AppBar(
      title: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.015 * 18,
        ),
      ),
      centerTitle: true,
      leading: effectiveLeading != null ? Center(child: effectiveLeading) : null,
      leadingWidth: 48,
      actions: actions != null
          ? [
              ...actions!,
              const SizedBox(width: 12),
            ]
          : null,
    );
  }
}
