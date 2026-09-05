import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Floating hamburger that respects status-bar / notch (SafeArea).
/// Used by role shells so the menu is never hidden under system UI or AppBar.
class HamburgerButton extends StatelessWidget {
  const HamburgerButton({super.key});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Positioned(
      top: top + 4,
      left: 10,
      child: Material(
        color: Colors.transparent,
        child: IconButton(
          tooltip: 'Menu',
          onPressed: () {
            final scaffold = Scaffold.maybeOf(context);
            if (scaffold?.hasDrawer == true) {
              scaffold!.openDrawer();
            }
          },
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: .90),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.menu_rounded, size: 22),
          ),
        ),
      ),
    );
  }
}
