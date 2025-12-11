// views/menu_view.dart

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../constants.dart';
import '../models/models.dart';

class MenuView extends StatefulWidget {
  const MenuView({super.key});

  @override
  State<MenuView> createState() => _MenuViewState();
}

class _MenuViewState extends State<MenuView> {
  String _searchTerm = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Usamos context.watch para reconstruir cuando cambien los filtros o favoritos.
    final provider = context.watch<AppProvider>();
    final activeFilter = provider.activeCategoryFilter;
    final favoriteIds = provider.favoriteProductIds;

    // --- LÓGICA DE FILTRADO MEJORADA ---
    final filteredItems = MENU_ITEMS.where((item) {
      final bool matchesFilter;
      switch (activeFilter) {
        case CategoryFilter.all:
          matchesFilter = true;
          break;
        case CategoryFilter.favorites:
          matchesFilter = favoriteIds.contains(item.id);
          break;
        default: // burgers, snacks, etc.
          // Compara el nombre del enum de filtro con el nombre del enum de categoría del producto.
          matchesFilter = item.category.name == activeFilter.name;
          break;
      }
      final matchesSearch = item.name.toLowerCase().contains(_searchTerm.toLowerCase());
      return matchesFilter && matchesSearch;
    }).toList();

    return Column(
      children: [
        _MenuHeader(
          searchController: _searchController,
          searchTerm: _searchTerm,
          onSearchChanged: (val) => setState(() => _searchTerm = val),
          onClearSearch: () {
            _searchController.clear();
            setState(() => _searchTerm = '');
          },
        ),
        Expanded(
          child: filteredItems.isEmpty
              ? _EmptyState()
              : GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.72,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    final isFavorite = favoriteIds.contains(item.id);
                    return _ProductCard(
                      product: item,
                      isFavorite: isFavorite,
                      // Usamos context.read en los callbacks
                      onTap: () => context.read<AppProvider>().selectProduct(item),
                      onFavoriteToggle: () => context.read<AppProvider>().toggleFavorite(item.id),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// --- WIDGETS PRIVADOS Y REFACTORIZADOS ---

class _MenuHeader extends StatelessWidget {
  final TextEditingController searchController;
  final String searchTerm;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;

  const _MenuHeader({
    required this.searchController,
    required this.searchTerm,
    required this.onSearchChanged,
    required this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 20, 20, 20),
      color: theme.colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nuestro Menú', style: theme.textTheme.displaySmall),
          const SizedBox(height: 16),
          TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Buscar hamburguesa, papas...',
              prefixIcon: Icon(LucideIcons.search, size: 20, color: theme.colorScheme.onSurfaceVariant),
              suffixIcon: searchTerm.isNotEmpty
                  ? IconButton(
                      icon: const Icon(LucideIcons.x, size: 18),
                      onPressed: onClearSearch,
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 20),
          // CORRECCIÓN: Generación dinámica de categorías
          _CategoryList(),
        ],
      ),
    );
  }
}

class _CategoryList extends StatelessWidget {
  // Helper para mapear enums a sus etiquetas e iconos.
  static const _categoryDetails = {
    CategoryFilter.favorites: ('', LucideIcons.heart),
    CategoryFilter.all: ('Todo', null),
    CategoryFilter.burgers: ('Burgers', null),
    CategoryFilter.combos: ('Combos', null),
    CategoryFilter.snacks: ('Snacks', null),
    CategoryFilter.drinks: ('Bebidas', null),
  };

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final activeFilter = provider.activeCategoryFilter;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: CategoryFilter.values.map((filter) {
          final details = _categoryDetails[filter]!;
          return _CategoryPill(
            label: details.$1,
            icon: details.$2,
            isActive: activeFilter == filter,
            onTap: () => context.read<AppProvider>().setCategoryFilter(filter),
          );
        }).toList(),
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final bool isActive;
  final VoidCallback onTap;

  const _CategoryPill({this.label, this.icon, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(25),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? colorScheme.primary : colorScheme.surface,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: isActive ? colorScheme.primary : theme.dividerColor),
            boxShadow: isActive
                ? [BoxShadow(color: colorScheme.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
                : [],
          ),
          child: Row(
            children: [
              if (icon != null) Icon(icon, size: 16, color: isActive ? colorScheme.onPrimary : colorScheme.onSurfaceVariant),
              if (icon != null && label != null && label!.isNotEmpty) const SizedBox(width: 6),
              if (label != null && label!.isNotEmpty)
                Text(
                  label!,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: isActive ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  const _ProductCard({
    required this.product,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: theme.shadowColor.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: Image.network(
                      product.image,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, st) => Container(color: theme.dividerColor, child: Center(child: Icon(Icons.broken_image, color: colorScheme.onSurface.withOpacity(0.3)))),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: onFavoriteToggle,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: colorScheme.surface, shape: BoxShape.circle),
                        child: Icon(
                          isFavorite ? LucideIcons.heart : LucideIcons.heart,
                          size: 16,
                          color: isFavorite ? Colors.red.shade400 : colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    product.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('\$${product.price.toStringAsFixed(2)}', style: theme.textTheme.titleMedium?.copyWith(color: colorScheme.primary)),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: colorScheme.primary, borderRadius: BorderRadius.circular(10)),
                        child: Icon(LucideIcons.plus, size: 16, color: colorScheme.onPrimary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.searchX, size: 64, color: theme.colorScheme.onSurface.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text("No encontramos productos", style: theme.textTheme.bodyLarge),
        ],
      ),
    );
  }
}