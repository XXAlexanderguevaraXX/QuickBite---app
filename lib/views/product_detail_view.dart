// views/product_detail_view.dart

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/app_provider.dart';
import '../models/models.dart';
import '../components/custom_button.dart';

class ProductDetailView extends StatefulWidget {
  const ProductDetailView({super.key});

  @override
  State<ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<ProductDetailView> {
  int _quantity = 1;
  Set<String> _removedIngredientIds = {};
  Set<String> _addedExtraIds = {};

  double _calculateCurrentPrice(Product product) {
    double extrasPrice = _addedExtraIds.fold(0.0, (sum, extraId) {
      final ingredient = product.ingredients.firstWhereOrNull(
        (i) => i.id == extraId,
      );
      return sum + (ingredient?.price ?? 0);
    });
    return (product.price + extrasPrice);
  }

  void _handleAddToCart(BuildContext context, Product product) {
    final provider = context.read<AppProvider>();

    // CORRECCIÓN: Construimos el objeto CartItemCustomizations directamente.
    final customizations = CartItemCustomizations(
      removedIngredientIds: _removedIngredientIds,
      addedExtraIds: _addedExtraIds,
    );

    // CORRECCIÓN: Llamamos al método addToCart del provider con la firma correcta.
    // El provider se encarga de crear el CartItem.
    for (int i = 0; i < _quantity; i++) {
      provider.addToCart(product, customizations);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$_quantity x ${product.name} añadido(s) al pedido.'),
        backgroundColor: Colors.green.shade600,
        duration: const Duration(seconds: 2),
      ),
    );

    // CORRECCIÓN: Usamos el enum para navegar.
    provider.setView(AppView.menu);
  }

  void _resetState() {
    // Si la vista se reutiliza, reseteamos el estado.
    _quantity = 1;
    _removedIngredientIds = {};
    _addedExtraIds = {};
  }

  @override
  void didChangeDependencies() {
    // Reseteamos el estado si el producto cambia.
    // Esto es más robusto que hacerlo en el build.
    final product = context.watch<AppProvider>().selectedProduct;
    // Si no hay producto, no hacemos nada.
    if (product != null) {
      _resetState();
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final product = context.watch<AppProvider>().selectedProduct;

    if (product == null) {
      return const Scaffold(
        body: Center(child: Text("Producto no encontrado")),
      );
    }

    final currentPrice = _calculateCurrentPrice(product);

    return Scaffold(
      // CORRECCIÓN: El color de fondo se deriva del tema.
      body: Stack(
        children: [
          _buildProductImage(context, product),
          _buildDraggableSheet(context, product, currentPrice),
        ],
      ),
      // CORRECCIÓN: El BottomBar ahora está dentro del Scaffold y es un widget separado.
      bottomNavigationBar: _BottomBar(
        totalPrice: currentPrice * _quantity,
        onAddToCart: () => _handleAddToCart(context, product),
      ),
    );
  }

  Widget _buildProductImage(BuildContext context, Product product) {
    final theme = Theme.of(context);
    return Positioned.fill(
      child: Stack(
        children: [
          Image.network(
            product.image,
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.55,
            fit: BoxFit.cover,
            color: Colors.black.withOpacity(0.3),
            colorBlendMode: BlendMode.darken,
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            child: GestureDetector(
              onTap: () => context.read<AppProvider>().setView(AppView.menu),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  LucideIcons.chevronLeft,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDraggableSheet(
    BuildContext context,
    Product product,
    double currentPrice,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.60,
      minChildSize: 0.60,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(
              24,
              24,
              24,
              120,
            ), // Padding para no chocar con el bottom bar
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: theme.textTheme.displaySmall),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${currentPrice.toStringAsFixed(2)}',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: colorScheme.primary,
                      ),
                    ),
                    _QuantityCounter(
                      quantity: _quantity,
                      onChanged: (newQuantity) =>
                          setState(() => _quantity = newQuantity),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(product.description, style: theme.textTheme.bodyLarge),
                const SizedBox(height: 24),
                Divider(color: theme.dividerColor),

                // --- INGREDIENTES ---
                if (product.ingredients.any(
                  (i) => i.type == IngredientType.removable,
                ))
                  _buildIngredientsSection(
                    product: product,
                    title: '¿Deseas quitar algo?',
                    type: IngredientType.removable,
                  ),
                if (product.ingredients.any(
                  (i) => i.type == IngredientType.addOn,
                ))
                  _buildIngredientsSection(
                    product: product,
                    title: 'Personaliza con Extras',
                    type: IngredientType.addOn,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIngredientsSection({
    required Product product,
    required String title,
    required IngredientType type,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final items = product.ingredients.where((i) => i.type == type).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(title, style: theme.textTheme.titleLarge),
        ),
        ...items.map((ing) {
          final isSelected =
              (type == IngredientType.removable &&
                  _removedIngredientIds.contains(ing.id)) ||
              (type == IngredientType.addOn && _addedExtraIds.contains(ing.id));
          return CheckboxListTile(
            title: Text(ing.name, style: theme.textTheme.bodyLarge),
            subtitle: type == IngredientType.addOn
                ? Text(
                    '+\$${ing.price!.toStringAsFixed(2)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.primary,
                    ),
                  )
                : null,
            value: isSelected,
            onChanged: (bool? value) {
              setState(() {
                final idSet = type == IngredientType.removable
                    ? _removedIngredientIds
                    : _addedExtraIds;
                if (value == true) {
                  idSet.add(ing.id);
                } else {
                  idSet.remove(ing.id);
                }
              });
            },
            activeColor: colorScheme.primary,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          );
        }),
      ],
    );
  }
}

// --- WIDGETS PRIVADOS Y REFACTORIZADOS ---

class _BottomBar extends StatelessWidget {
  final double totalPrice;
  final VoidCallback onAddToCart;

  const _BottomBar({required this.totalPrice, required this.onAddToCart});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        MediaQuery.of(context).padding.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: theme.dividerColor, width: 1.5)),
      ),
      child: CustomButton(
        text: 'Agregar - \$${totalPrice.toStringAsFixed(2)}',
        fullWidth: true,
        icon: LucideIcons.shoppingBag,
        onPressed: onAddToCart,
      ),
    );
  }
}

class _QuantityCounter extends StatelessWidget {
  final int quantity;
  final ValueChanged<int> onChanged;

  const _QuantityCounter({required this.quantity, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.dividerColor,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(LucideIcons.minus),
            onPressed: quantity > 1 ? () => onChanged(quantity - 1) : null,
            iconSize: 18,
          ),
          Text('$quantity', style: theme.textTheme.titleMedium),
          IconButton(
            icon: const Icon(LucideIcons.plus),
            onPressed: () => onChanged(quantity + 1),
            iconSize: 18,
          ),
        ],
      ),
    );
  }
}
