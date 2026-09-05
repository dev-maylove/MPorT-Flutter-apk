import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Floating hamburger that respects status-bar / notch (SafeArea).
/// Used by role shells so the menu is never hidden under system UI or AppBar.
class HamburgerButton extends StatelessWidget {
  const HamburgerButton({super.key});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    // Align with typical AppBar leading vertical center (toolbar ~56).
    final toolbarOffset = (kToolbarHeight - 40) / 2;
    return Positioned(
      top: top + toolbarOffset,
      left: 8,
      child: Material(
        color: Colors.transparent,
        elevation: 0,
        child: IconButton(
          tooltip: 'Menu',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          visualDensity: VisualDensity.compact,
          onPressed: () {
            final scaffold = Scaffold.maybeOf(context);
            if (scaffold?.hasDrawer == true) {
              scaffold!.openDrawer();
            }
          },
          icon: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: .92),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .35),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(Icons.menu_rounded, size: 20),
          ),
        ),
      ),
    );
  }
}
