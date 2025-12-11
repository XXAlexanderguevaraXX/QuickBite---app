// views/history_view.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatear fechas
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/models.dart';

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuchamos el provider para obtener los datos del historial.
    final provider = context.watch<AppProvider>();
    final history = provider.orderHistory;
    final theme = Theme.of(context);

    return Column(
      children: [
        // --- HEADER ---
        _HistoryHeader(
          // CORRECCIÓN: Navegación con enum
          onBackPressed: () => provider.setView(AppView.profile),
        ),

        // --- LISTA DE PEDIDOS ---
        Expanded(
          child: history.isEmpty
              ? _EmptyHistoryView() // Vista para cuando no hay historial
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: history.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final order = history[index];
                    // Pasamos el objeto 'order' completo a la tarjeta.
                    return _OrderHistoryCard(order: order);
                  },
                ),
        ),

        // --- MENSAJE FINAL ---
        if (history.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + 20,
              top: 10,
            ),
            child: Text(
              "No hay más pedidos recientes.",
              style: theme.textTheme.bodySmall,
            ),
          ),
      ],
    );
  }
}

// --- WIDGETS PRIVADOS Y REFACTORIZADOS ---

class _HistoryHeader extends StatelessWidget {
  final VoidCallback onBackPressed;
  const _HistoryHeader({required this.onBackPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 10, right: 20, bottom: 10,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
            blurRadius: 4, offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(LucideIcons.chevronLeft, color: theme.colorScheme.onSurface),
            onPressed: onBackPressed,
          ),
          const SizedBox(width: 8),
          Text("Historial de Pedidos", style: theme.textTheme.titleLarge),
        ],
      ),
    );
  }
}

class _EmptyHistoryView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.receipt, size: 64, color: theme.colorScheme.onSurface.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text("Sin Pedidos Anteriores", style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text("Tu historial de pedidos aparecerá aquí.", style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _OrderHistoryCard extends StatelessWidget {
  final ActiveOrder order;
  const _OrderHistoryCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    // Formateador para la fecha
    final formattedDate = DateFormat('dd MMM yyyy, h:mm a').format(order.timestamp);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(order.storeName, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(formattedDate, style: theme.textTheme.bodySmall),
                ],
              ),
              // CORRECCIÓN: Chip de estado basado en el enum OrderStatus.
              _StatusChip(status: order.status),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: theme.dividerColor, height: 1),
          const SizedBox(height: 12),
          // CORRECCIÓN: Generamos los items dinámicamente (si existieran en el modelo)
          // Por ahora, un texto de ejemplo ya que la lista de items está vacía.
          Text(
            "ID de Orden: ${order.id}", // Ejemplo de qué mostrar aquí
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$${order.total.toStringAsFixed(2)}',
                style: theme.textTheme.headlineSmall?.copyWith(color: colorScheme.primary),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () {},
                    child: Text("Ayuda", style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7))),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () { /* Lógica para repetir pedido */ },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.primary,
                      side: BorderSide(color: colorScheme.primary.withOpacity(0.5)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: const Text("Repetir"),
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final OrderStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    String text;
    Color backgroundColor;
    Color foregroundColor;

    switch (status) {
      case OrderStatus.completed:
        text = 'Entregado';
        backgroundColor = Colors.green.withOpacity(0.1);
        foregroundColor = Colors.green.shade800;
        break;
      case OrderStatus.cancelled:
        text = 'Cancelado';
        backgroundColor = Colors.red.withOpacity(0.1);
        foregroundColor = Colors.red.shade800;
        break;
      default: // pending, preparing, etc.
        text = status.name.capitalize(); // Helper para poner la primera en mayúscula
        backgroundColor = Colors.orange.withOpacity(0.1);
        foregroundColor = Colors.orange.shade800;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: foregroundColor),
      ),
    );
  }
}

// Pequeña extensión para poner en mayúscula la primera letra de un string.
extension StringExtension on String {
    String capitalize() {
      return "${this[0].toUpperCase()}${substring(1)}";
    }
}