import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../components/custom_button.dart';
import '../models/models.dart';

class CartView extends StatelessWidget {
  const CartView({super.key});

  Future<void> _handleCheckout(
      BuildContext context, AppProvider provider) async {
    if (!provider.isLoggedIn) {
      provider.setView(AppView.login);
      return;
    }
    // Navegamos a la vista de checkout para que el usuario elija la tienda.
    provider.setView(AppView.checkout);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        if (provider.cart.isEmpty) {
          return _EmptyCartView(
              onGoToMenu: () => provider.setView(AppView.menu));
        }

        return Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 20,
                left: 20,
                right: 20,
                bottom: 10,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Tu Pedido',
                    style: Theme.of(context).textTheme.displaySmall),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                itemCount: provider.cart.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final item = provider.cart[index];
                  return _CartItemCard(
                    item: item,
                    onIncrease: () =>
                        provider.updateCartItemQuantity(item.cartId, 1),
                    onDecrease: () =>
                        provider.updateCartItemQuantity(item.cartId, -1),
                    onRemove: () => provider.removeFromCart(item.cartId),
                  );
                },
              ),
            ),
            _CartFooter(
              total: provider.cartTotal,
              isLoggedIn: provider.isLoggedIn,
              onCheckout: () => _handleCheckout(context, provider),
            ),
          ],
        );
      },
    );
  }
}

// --- WIDGETS PRIVADOS DE CARTVIEW ---
class _EmptyCartView extends StatelessWidget {
  final VoidCallback onGoToMenu;
  const _EmptyCartView({required this.onGoToMenu});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(LucideIcons.shoppingBag,
                size: 48, color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 24),
          Text("Tu pedido está vacío", style: theme.textTheme.headlineSmall),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: Text("Parece que aún no has agregado nada a tu orden.",
                textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: 200,
            child: CustomButton(text: "Ir al Menú", onPressed: onGoToMenu),
          ),
        ],
      ),
    );
  }
}

class _CartFooter extends StatelessWidget {
  final double total;
  final bool isLoggedIn;
  final VoidCallback onCheckout;

  const _CartFooter(
      {required this.total,
      required this.isLoggedIn,
      required this.onCheckout});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(context).padding.bottom + 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
              color: theme.shadowColor.withOpacity(0.05),
              offset: const Offset(0, -4),
              blurRadius: 10)
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Subtotal", style: theme.textTheme.bodyLarge),
              Text('\$${total.toStringAsFixed(2)}',
                  style: theme.textTheme.bodyLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Total", style: theme.textTheme.titleLarge),
              Text('\$${total.toStringAsFixed(2)}',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(color: theme.colorScheme.primary)),
            ],
          ),
          const SizedBox(height: 20),
          CustomButton(
            text: isLoggedIn ? "Continuar al Pago" : "Inicia sesión para pagar",
            fullWidth: true,
            icon: LucideIcons.creditCard,
            onPressed: onCheckout,
          ),
        ],
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItem item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  const _CartItemCard({
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final List<String> extraNames = item.customizations.addedExtraIds
        .map((extraId) {
          final ingredient = item.product.ingredients
              .firstWhereOrNull((ing) => ing.id == extraId);
          return ingredient?.name;
        })
        .whereType<String>()
        .toList();

    return Dismissible(
      key: Key(item.cartId),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onRemove(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
            color: colorScheme.error.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16)),
        child: Icon(LucideIcons.trash2, color: colorScheme.error),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                item.product.image,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, st) => Container(
                    width: 80,
                    height: 80,
                    color: theme.dividerColor,
                    child: Icon(Icons.fastfood,
                        color: colorScheme.onSurface.withOpacity(0.4))),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: Text(item.product.name,
                              style: theme.textTheme.titleMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis)),
                      InkWell(
                          onTap: onRemove,
                          child: Icon(LucideIcons.x,
                              size: 18,
                              color: colorScheme.onSurface.withOpacity(0.5))),
                    ],
                  ),
                  if (extraNames.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: extraNames
                            .map((name) => Text('+ $name',
                                style: theme.textTheme.bodySmall))
                            .toList()),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('\$${item.totalPrice.toStringAsFixed(2)}',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(color: colorScheme.primary)),
                      Container(
                        decoration: BoxDecoration(
                            color: theme.dividerColor,
                            borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          children: [
                            _QuantityBtn(
                                icon: LucideIcons.minus, onTap: onDecrease),
                            Text('${item.quantity}',
                                style: theme.textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.bold)),
                            _QuantityBtn(
                                icon: LucideIcons.plus, onTap: onIncrease),
                          ],
                        ),
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

class _QuantityBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QuantityBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Icon(icon,
            size: 16, color: Theme.of(context).colorScheme.onSurface),
      ),
    );
  }
}
