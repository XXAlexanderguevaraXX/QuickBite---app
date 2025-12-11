// components/custom_bottom_nav.dart

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/models.dart';

class CustomBottomNav extends StatelessWidget {
  final AppView currentView;
  final ValueChanged<AppView> onViewChanged;
  final int cartCount;

  const CustomBottomNav({
    super.key,
    required this.currentView,
    required this.onViewChanged,
    required this.cartCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // CORRECCIÓN: El diseño ahora es flotante gracias al Margin y BorderRadius.
    return SafeArea(
      top: false,
      child: Container(
        height: 70,
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _BottomNavItem(
              icon: LucideIcons.home,
              label: 'Inicio',
              targetView: AppView.home,
              isActive: currentView == AppView.home,
              onTap: onViewChanged,
            ),
            _BottomNavItem(
              icon: LucideIcons.layoutGrid,
              label: 'Menú',
              targetView: AppView.menu,
              isActive: currentView == AppView.menu,
              onTap: onViewChanged,
            ),
            _BottomNavItem(
              icon: LucideIcons.shoppingBag,
              label: 'Pedido',
              targetView: AppView.cart,
              isActive: currentView == AppView.cart,
              onTap: onViewChanged,
              badgeCount: cartCount,
            ),
            _BottomNavItem(
              icon: LucideIcons.user,
              label: 'Perfil',
              targetView: AppView.profile,
              isActive: currentView == AppView.profile,
              onTap: onViewChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final AppView targetView;
  final bool isActive;
  final ValueChanged<AppView> onTap;
  final int badgeCount;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.targetView,
    required this.isActive,
    required this.onTap,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final activeColor = colorScheme.primary;
    final inactiveColor = colorScheme.onSurface.withOpacity(0.6);

    return Expanded(
      child: InkWell(
        onTap: () => onTap(targetView),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon,
                    size: 24, color: isActive ? activeColor : inactiveColor),
                if (badgeCount > 0)
                  Positioned(
                    top: -4,
                    right: -8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                          color: colorScheme.error, shape: BoxShape.circle),
                      constraints:
                          const BoxConstraints(minWidth: 18, minHeight: 18),
                      child: Text(
                        '$badgeCount',
                        style: TextStyle(
                            color: colorScheme.onError,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive ? activeColor : inactiveColor),
            ),
          ],
        ),
      ),
    );
  }
}
