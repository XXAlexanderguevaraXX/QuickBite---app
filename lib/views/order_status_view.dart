// views/order_status_view.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../components/custom_button.dart';

class OrderStatusView extends StatelessWidget {
  // CORRECCIÓN: El constructor está limpio. La vista es autónoma.
  const OrderStatusView({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtenemos la última orden creada del provider.
    final order = context.watch<AppProvider>().lastCreatedOrder;
    final provider = context.read<AppProvider>();
    final theme = Theme.of(context);

    // Fallback: Si por alguna razón no hay orden, mostramos un error.
    if (order == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("No se encontró la orden."),
              const SizedBox(height: 16),
              CustomButton(
                text: "Volver al Inicio",
                onPressed: () => provider.setView(AppView.home),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      // CORRECCIÓN: Usamos colores del tema.
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _SuccessAnimation(),
                    const SizedBox(height: 24),
                    Text("¡Orden Recibida!", style: theme.textTheme.displaySmall),
                    const SizedBox(height: 8),
                    Text("Ya estamos preparando tu comida", style: theme.textTheme.bodyLarge),
                    const SizedBox(height: 32),
                    _OrderTicket(order: order),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: CustomButton(
                text: "Volver al Inicio",
                fullWidth: true,
                onPressed: () => provider.setView(AppView.home),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// --- WIDGETS PRIVADOS Y REFACTORIZADOS ---

class _SuccessAnimation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final successColor = Colors.green.shade600;
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: successColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(LucideIcons.check, size: 40, color: successColor),
          ),
        );
      },
    );
  }
}

class _OrderTicket extends StatelessWidget {
  final ActiveOrder order;
  const _OrderTicket({required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        children: [
          Text("CÓDIGO DE RETIRO", style: theme.textTheme.labelMedium),
          const SizedBox(height: 8),
          Text(
            order.pickupCode,
            style: theme.textTheme.displayLarge?.copyWith(color: colorScheme.primary, letterSpacing: 2),
          ),
          const SizedBox(height: 24),
          Divider(color: theme.dividerColor),
          const SizedBox(height: 16),
          _InfoRow(icon: LucideIcons.mapPin, label: "Sucursal", value: order.storeName),
          const SizedBox(height: 16),
          _InfoRow(icon: LucideIcons.clock, label: "Hora", value: DateFormat.jm().format(order.timestamp)),
          const SizedBox(height: 24),
          Divider(color: theme.dividerColor),
          const SizedBox(height: 16),
          ...order.items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              children: [
                Text("${item.quantity}x", style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodySmall?.color)),
                const SizedBox(width: 12),
                Expanded(child: Text(item.product.name, style: theme.textTheme.bodyLarge)),
                Text("\$${item.totalPrice.toStringAsFixed(2)}", style: theme.textTheme.bodyLarge),
              ],
            ),
          )),
          const SizedBox(height: 16),
          Divider(thickness: 1.5, color: theme.dividerColor),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("TOTAL", style: theme.textTheme.titleMedium),
              Text(
                "\$${order.total.toStringAsFixed(2)}",
                style: theme.textTheme.headlineSmall?.copyWith(color: colorScheme.primary),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: theme.dividerColor, shape: BoxShape.circle),
          child: Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label.toUpperCase(), style: theme.textTheme.labelSmall),
            Text(value, style: theme.textTheme.bodyLarge),
          ],
        )
      ],
    );
  }
}