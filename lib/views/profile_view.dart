// views/profile_view.dart

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/models.dart'; // Para AppView

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos context.watch para que la UI se actualice si los datos del usuario cambian.
    final provider = context.watch<AppProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      // El color de fondo se hereda del tema, no se fija.
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 20, 20, 20),
        child: Column(
          children: [
            // --- HEADER (Avatar, Nombre y Email) ---
            _ProfileHeader(
              // CORRECCIÓN: Datos dinámicos del provider
              name: provider.userName,
              email: provider.userEmail ?? 'No hay correo electrónico',
              avatarUrl: provider.userAvatarUrl,
            ),
            
            const SizedBox(height: 30),
            
            // --- TARJETA DE PUNTOS ---
            _PointsCard(
              // CORRECCIÓN: Puntos dinámicos del provider
              points: provider.userPoints,
            ),
            
            const SizedBox(height: 30),
            
            // --- LISTA DE OPCIONES ---
            // CORRECCIÓN: Navegación segura con enums
            _ProfileOption(
              icon: LucideIcons.history,
              label: "Historial de Pedidos",
              onTap: () => provider.setView(AppView.history),
            ),
            _ProfileOption(
              icon: LucideIcons.mapPin,
              label: "Direcciones Guardadas",
              onTap: () { /* Futura implementación */ },
            ),
            _ProfileOption(
              icon: LucideIcons.creditCard,
              label: "Métodos de Pago",
              onTap: () { /* Futura implementación */ },
            ),
            _ProfileOption(
              icon: LucideIcons.settings,
              label: "Configuración",
              onTap: () => provider.setView(AppView.settings),
            ),

            const SizedBox(height: 30),
            
            // --- BOTÓN CERRAR SESIÓN ---
            // CORRECCIÓN: Usamos OutlinedButton que ya está estilizado por nuestro tema.
            // Es visualmente similar a un "ghost button".
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(LucideIcons.logOut, size: 18),
                label: const Text("Cerrar Sesión"),
                onPressed: () async {
                  // Es buena práctica mostrar un diálogo de confirmación.
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Cerrar Sesión'),
                      content: const Text('¿Estás seguro de que quieres salir?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Salir'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    provider.logout();
                  }
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                  side: BorderSide(color: theme.colorScheme.error.withOpacity(0.5)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- WIDGETS PRIVADOS Y REFACTORIZADOS ---

class _ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final String? avatarUrl;

  const _ProfileHeader({required this.name, required this.email, this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: colorScheme.primary.withOpacity(0.1),
          // Usamos un errorBuilder para el fallback
          backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
          child: avatarUrl == null ? Icon(LucideIcons.user, size: 40, color: colorScheme.primary) : null,
        ),
        const SizedBox(height: 16),
        Text(name, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(email, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}

class _PointsCard extends StatelessWidget {
  final int points;
  const _PointsCard({required this.points});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.star, color: colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text("Mis Quick Bites", style: theme.textTheme.titleSmall?.copyWith(color: colorScheme.primary)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            points.toString(),
            style: theme.textTheme.displayMedium?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text("Puntos disponibles", style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ProfileOption({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: theme.dividerColor, // Color del tema para fondos sutiles
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.surface, // Fondo de la superficie
            borderRadius: BorderRadius.circular(8)
          ),
          child: Icon(icon, size: 20, color: colorScheme.onSurface),
        ),
        title: Text(label, style: theme.textTheme.titleMedium),
        trailing: Icon(LucideIcons.chevronRight, size: 18, color: colorScheme.onSurfaceVariant),
      ),
    );
  }
}