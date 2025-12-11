// views/rewards_view.dart

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../constants.dart'; // Importa la lista REWARDS (List<Reward>)
import '../models/models.dart'; // Importa el modelo Reward

class RewardsView extends StatelessWidget {
  const RewardsView({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuchamos los cambios en el provider, especialmente los puntos.
    final provider = context.watch<AppProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          20,
          MediaQuery.of(context).padding.top + 20,
          20,
          20,
        ),
        children: [
          // TARJETA DE PUNTOS
          _PointsCard(points: provider.userPoints),

          const SizedBox(height: 30),

          Text("Canjear Recompensas", style: theme.textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(
            "Usa tus puntos por comida gratis",
            style: theme.textTheme.bodyLarge,
          ),

          const SizedBox(height: 20),

          // LISTA DE RECOMPENSAS
          // CORRECCIÓN: Usamos la lista de objetos Reward
          ...REWARDS.map((reward) {
            final bool canAfford = provider.userPoints >= reward.cost;

            return _RewardCard(
              reward: reward,
              canAfford: canAfford,
              // Usamos context.read en el callback para ejecutar la acción.
              onRedeem: () async {
                final success = await context.read<AppProvider>().redeemReward(
                  reward,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? "¡Has canjeado ${reward.name}!"
                            : "Error al canjear",
                      ),
                      backgroundColor: success
                          ? Colors.green.shade600
                          : theme.colorScheme.error,
                    ),
                  );
                }
              },
            );
          }),
        ],
      ),
    );
  }
}

// --- WIDGETS PRIVADOS Y REFACTORIZADOS ---

class _PointsCard extends StatelessWidget {
  final int points;
  const _PointsCard({required this.points});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // CORRECCIÓN: La tarjeta se adapta al tema. Es oscura si el tema es oscuro.
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark
        ? theme.colorScheme.surfaceContainerHighest
        : const Color(0xFF1F2937);
    final onCardColor = isDark
        ? theme.colorScheme.onSurfaceVariant
        : Colors.white;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "MIS PUNTOS BITES",
                style: theme.textTheme.labelMedium?.copyWith(
                  color: onCardColor.withOpacity(0.7),
                ),
              ),
              Icon(LucideIcons.crown, color: colorScheme.primary, size: 24),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            points.toString(),
            style: theme.textTheme.displayLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (points % 1000) / 1000,
              backgroundColor: onCardColor.withOpacity(0.12),
              color: colorScheme.primary,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "${1000 - (points % 1000)} puntos para el siguiente nivel",
              style: theme.textTheme.labelSmall?.copyWith(
                color: onCardColor.withOpacity(0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RewardCard extends StatelessWidget {
  final Reward reward;
  final bool canAfford;
  final VoidCallback onRedeem;

  const _RewardCard({
    required this.reward,
    required this.canAfford,
    required this.onRedeem,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Opacity(
      opacity: canAfford ? 1.0 : 0.6, // Efecto visual si no se puede pagar
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                reward.image,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(width: 70, height: 70, color: theme.dividerColor),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(reward.name, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        LucideIcons.star,
                        size: 14,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "${reward.cost} Bites",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: canAfford ? onRedeem : null,
              child: Text(canAfford ? "Canjear" : "Faltan"),
            ),
          ],
        ),
      ),
    );
  }
}
