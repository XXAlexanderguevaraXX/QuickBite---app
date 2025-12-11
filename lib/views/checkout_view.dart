// views/checkout_view.dart

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../components/custom_button.dart'; // Asumiendo que este componente está bien.
import '../constants.dart'; // Accedemos a la lista STORES de tipo List<Store>
import '../models/models.dart'; // Accedemos al enum AppView

class CheckoutView extends StatefulWidget {
  const CheckoutView({super.key});

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  // Estado local para la tienda seleccionada y el proceso de pago.
  String? _selectedStoreId;
  Store? _selectedStore;
  bool _isProcessing = false;

  Future<void> _handleConfirmOrder() async {
    // Usamos context.read porque estamos en un callback, no necesitamos escuchar cambios.
    final provider = context.read<AppProvider>();

    if (_selectedStore == null) return; // Doble chequeo de seguridad.

    setState(() => _isProcessing = true);

    // CORRECCIÓN: Llamamos al método renombrado 'createOrder'.
    bool success = await provider.createOrder(
      storeId: _selectedStore!.id,
      storeName: _selectedStore!.name,
    );

    // Es crucial verificar si el widget sigue montado después de una operación asíncrona.
    if (!mounted) return;

    setState(() => _isProcessing = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("¡Tu orden ha sido confirmada!"),
          backgroundColor: Colors.green.shade600,
        ),
      );
      // CORRECCIÓN: Usamos el enum AppView para navegar.
      provider.setView(AppView.home); 
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Error al confirmar la orden. Inténtalo de nuevo."),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos el provider una vez, preferiblemente solo para lectura inicial
    // o para pasar a los métodos.
    final provider = context.read<AppProvider>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Usamos context.watch para escuchar específicamente el total del carrito.
    // Esto es más eficiente que reconstruir todo por cualquier cambio en el provider.
    final total = context.watch<AppProvider>().cartTotal;

    return Column(
      children: [
        // --- HEADER ---
        _CheckoutHeader(
          onBackPressed: () => provider.setView(AppView.cart),
        ),

        // --- CONTENIDO SCROLLABLE ---
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Sección de selección de Sucursal
              Text("Selecciona Sucursal", style: theme.textTheme.titleLarge),
              const SizedBox(height: 4),
              Text("Elige dónde recoger tu pedido", style: theme.textTheme.bodyMedium),
              const SizedBox(height: 16),

              // CORRECCIÓN: Mapeo de la lista de objetos Store.
              ...STORES.map((store) {
                final isSelected = _selectedStoreId == store.id;
                return _StoreCard(
                  store: store,
                  isSelected: isSelected,
                  onTap: () {
                    setState(() {
                      _selectedStoreId = store.id;
                      _selectedStore = store;
                    });
                  },
                );
              }),

              const SizedBox(height: 24),

              // Sección de Método de Pago
              Text("Método de Pago", style: theme.textTheme.titleLarge),
              const SizedBox(height: 12),
              _PaymentMethodCard(),
            ],
          ),
        ),

        // --- FOOTER CON TOTAL Y BOTÓN DE CONFIRMACIÓN ---
        Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).padding.bottom + 20,
          ),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.05),
                offset: const Offset(0, -4),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Total a Pagar", style: theme.textTheme.bodyLarge),
                  Text(
                    '\$${total.toStringAsFixed(2)}',
                    style: theme.textTheme.headlineSmall?.copyWith(color: colorScheme.primary),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: _isProcessing ? "Procesando..." : "Confirmar Orden",
                icon: _isProcessing ? null : LucideIcons.check,
                isLoading: _isProcessing,
                fullWidth: true,
                onPressed: _selectedStoreId == null ? null : _handleConfirmOrder,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// --- WIDGETS PRIVADOS Y REFACTORIZADOS ---

class _CheckoutHeader extends StatelessWidget {
  final VoidCallback onBackPressed;
  const _CheckoutHeader({required this.onBackPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 10, right: 20, bottom: 10,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(LucideIcons.chevronLeft, color: colorScheme.onSurface),
            onPressed: onBackPressed,
          ),
          const SizedBox(width: 8),
          Text("Finalizar Pedido", style: theme.textTheme.titleLarge),
        ],
      ),
    );
  }
}

class _StoreCard extends StatelessWidget {
  final Store store;
  final bool isSelected;
  final VoidCallback onTap;

  const _StoreCard({
    required this.store,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary.withOpacity(0.1) : colorScheme.surface,
          border: Border.all(
            color: isSelected ? colorScheme.primary : theme.dividerColor,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // CORRECCIÓN: Acceso a propiedades de objeto
                Text(
                  store.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                  ),
                ),
                if (isSelected)
                  Icon(LucideIcons.checkCircle2, color: colorScheme.primary, size: 20),
              ],
            ),
            const SizedBox(height: 4),
            Text(store.address, style: theme.textTheme.bodySmall),
            const SizedBox(height: 10),
            Row(children: [
              _InfoChip(icon: LucideIcons.mapPin, text: store.distance),
              const SizedBox(width: 8),
              _InfoChip(icon: LucideIcons.clock, text: store.waitTime, color: Colors.blue.shade700),
            ]),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;

  const _InfoChip({required this.icon, required this.text, this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: effectiveColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(icon, size: 12, color: effectiveColor),
          const SizedBox(width: 4),
          Text(text, style: theme.textTheme.labelSmall?.copyWith(color: effectiveColor)),
        ],
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(16),
        color: colorScheme.surface,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(LucideIcons.banknote, color: Colors.green.shade700, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Pago en Caja", style: theme.textTheme.titleMedium),
                Text(
                  "Presenta tu código al recoger para pagar.",
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}