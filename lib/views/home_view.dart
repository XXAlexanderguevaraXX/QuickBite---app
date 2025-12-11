// views/home_view.dart

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool _isFabOpen = false;

  void _navigateToMenuWithCategory(CategoryFilter category) {
    final provider = context.read<AppProvider>();
    provider.setCategoryFilter(category);
    provider.setView(AppView.menu);
    setState(() => _isFabOpen = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Obtenemos el tema una vez

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 10,
              bottom: 100,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: _Header(),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: _HeroBanner(), // Aquí estaba el error de overflow
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text("Categorías Populares",
                      style: theme.textTheme.headlineSmall),
                ),
                const SizedBox(height: 15),
                _QuickCategories(),
              ],
            ),
          ),
          if (_isFabOpen)
            GestureDetector(
              onTap: () => setState(() => _isFabOpen = false),
              child: Container(color: Colors.black.withOpacity(0.5)),
            ),
          Positioned(
            bottom: 20,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _FabAction(
                  icon: LucideIcons.cookie,
                  label: 'Snacks',
                  color: Colors.orange,
                  visible: _isFabOpen,
                  onTap: () =>
                      _navigateToMenuWithCategory(CategoryFilter.snacks),
                ),
                const SizedBox(height: 12),
                _FabAction(
                  icon: LucideIcons.sandwich,
                  label: 'Hamburguesas',
                  color: Colors.redAccent,
                  visible: _isFabOpen,
                  onTap: () =>
                      _navigateToMenuWithCategory(CategoryFilter.burgers),
                ),
                const SizedBox(height: 16),
                FloatingActionButton(
                  onPressed: () => setState(() => _isFabOpen = !_isFabOpen),
                  // CORRECCIÓN: Definimos el color y la forma explícitamente.
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: const CircleBorder(),
                  child: AnimatedRotation(
                    turns: _isFabOpen ? 0.125 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(LucideIcons.plus, size: 28),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- WIDGETS PRIVADOS ---

// _Header no necesita cambios
class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (provider.isLoggedIn) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hola, ${provider.userName} 👋',
                  style: theme.textTheme.headlineMedium),
              const SizedBox(height: 4),
              Text('¿Qué se te antoja hoy?', style: theme.textTheme.bodyLarge),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.star, size: 16, color: colorScheme.primary),
                const SizedBox(width: 6),
                Text('${provider.userPoints} Pts',
                    style: theme.textTheme.labelLarge
                        ?.copyWith(color: colorScheme.primary)),
              ],
            ),
          )
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Bienvenido 👋', style: theme.textTheme.headlineMedium),
              const SizedBox(height: 4),
              Text('Descubre el mejor sabor', style: theme.textTheme.bodyLarge),
            ],
          ),
          OutlinedButton.icon(
            onPressed: () => context.read<AppProvider>().setView(AppView.login),
            icon: const Icon(LucideIcons.logIn, size: 18),
            label: const Text('Ingresar'),
          )
        ],
      );
    }
  }
}

// CORRECCIÓN PRINCIPAL: Arreglamos el layout del HeroBanner
class _HeroBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppProvider>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 190,
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: colorScheme.primary.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8))
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // --- CONTENIDO IZQUIERDO (TEXTO Y BOTÓN) ---
          Padding(
            // 1. Reducimos el padding vertical para tener más espacio
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              // 2. Usamos spaceBetween para empujar los elementos a los extremos
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Agrupamos el texto para que se mantenga junto en la parte superior
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Family Box\nEspecial',
                        style: theme.textTheme.headlineMedium
                            ?.copyWith(color: colorScheme.onPrimary)),
                    const SizedBox(height: 8),
                    Text('¡Solo por tiempo limitado!',
                        style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onPrimary.withOpacity(0.8))),
                  ],
                ),

                // 3. El botón ahora está en la parte inferior sin un Spacer
                ElevatedButton(
                  onPressed: () {
                    provider.setCategoryFilter(CategoryFilter.combos);
                    provider.setView(AppView.menu);
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.onPrimary,
                      foregroundColor: colorScheme.primary),
                  child: const Text('Ver Oferta'),
                )
              ],
            ),
          ),

          // --- IMAGEN DERECHA ---
          Positioned(
            right: 20,
            bottom: 12,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border:
                    Border.all(color: Colors.white.withOpacity(0.2), width: 8),
              ),
              child: const CircleAvatar(
                radius: 70,
                backgroundImage: AssetImage(
                  'assets/images/family_box.png',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// El resto de los widgets están bien.

class _QuickCategories extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Usamos un SingleChildScrollView para que sea escalable
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      // 1. Añadimos el padding horizontal para el efecto "left" y el espaciado general
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      // Usamos clipBehavior.none para que las sombras no se corten en los bordes
      clipBehavior: Clip.none,
      child: Row(
        // 2. Ya no usamos spaceBetween, controlamos el espacio manualmente
        children: [
          _CategoryCard(
              icon: LucideIcons.flame,
              label: 'Populares',
              color: Colors.orange.shade600),
          // 3. Usamos SizedBox para un espaciado consistente y generoso
          const SizedBox(width: 16),
          _CategoryCard(
              icon: LucideIcons.percent,
              label: 'Ofertas',
              color: Colors.red.shade600),
          const SizedBox(width: 16),
          _CategoryCard(
              icon: LucideIcons.timer,
              label: 'Rápido',
              color: Colors.blue.shade600),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _CategoryCard({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  __CategoryCardState createState() => __CategoryCardState();
}

class __CategoryCardState extends State<_CategoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ScaleTransition(
      scale: _scaleAnimation,
      child: InkWell(
        onTap: () {
          // TODO: Implement navigation
        },
        onHighlightChanged: (isHighlighted) {
          if (isHighlighted) {
            _controller.forward();
          } else {
            _controller.reverse();
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 100,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(widget.icon, color: widget.color, size: 28),
              ),
              const SizedBox(height: 10),
              Text(
                widget.label,
                style: theme.textTheme.labelLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FabAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool visible;
  final VoidCallback onTap;
  final Color color;

  const _FabAction({
    required this.icon,
    required this.label,
    required this.visible,
    required this.onTap,
    this.color = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedScale(
      scale: visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                    color: theme.shadowColor.withOpacity(0.1), blurRadius: 4)
              ],
            ),
            child: Text(label,
                style: theme.textTheme.labelLarge
                    ?.copyWith(color: theme.colorScheme.onSurface)),
          ),
          const SizedBox(width: 12),
          FloatingActionButton.small(
            heroTag: label,
            onPressed: onTap,
            backgroundColor: theme.colorScheme.surface,
            foregroundColor: color,
            child: Icon(icon),
          ),
        ],
      ),
    );
  }
}
