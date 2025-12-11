// views/settings_view.dart

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/models.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          _SettingsHeader(
            onBackPressed: () => provider.setView(AppView.profile), // Volver al perfil
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildSectionHeader(context, "Apariencia"),
                Row(
                  children: [
                    Expanded(
                      child: _ThemeOption(
                        theme: AppThemeMode.light,
                        label: 'Claro',
                        icon: LucideIcons.sun,
                        current: provider.themeMode,
                        onTap: (theme) => provider.setTheme(theme),
                      )
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ThemeOption(
                        theme: AppThemeMode.softDark,
                        label: 'Oscuro',
                        icon: LucideIcons.moon,
                        current: provider.themeMode,
                        onTap: (theme) => provider.setTheme(theme),
                      )
                    ),
                    // Opcional: Añadir el tercer tema
                    // const SizedBox(width: 12),
                    // Expanded(
                    //   child: _ThemeOption(
                    //     theme: AppThemeMode.midnight,
                    //     label: 'Medianoche',
                    //     icon: LucideIcons.moonStar,
                    //     current: provider.themeMode,
                    //     onTap: (theme) => provider.setTheme(theme),
                    //   )
                    // ),
                  ],
                ),
                const SizedBox(height: 32),
                _buildSectionHeader(context, "Preferencias"),
                _SettingsGroup(
                  children: [
                    const _SettingsItem(icon: LucideIcons.globe, label: "Idioma", value: "Español"),
                    _SettingsItem(
                      icon: LucideIcons.bell,
                      label: "Notificaciones",
                      isSwitch: true,
                      switchValue: provider.notificationsEnabled,
                      onSwitchChanged: provider.setNotifications,
                    ),
                    _SettingsItem(
                      icon: LucideIcons.smartphone,
                      label: "Promociones SMS",
                      isSwitch: true,
                      switchValue: provider.smsPromotionsEnabled,
                      onSwitchChanged: provider.setSmsPromotions,
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                _buildSectionHeader(context, "Soporte y Legal"),
                const _SettingsGroup(
                  children: [
                    _SettingsItem(icon: LucideIcons.helpCircle, label: "Centro de Ayuda"),
                    _SettingsItem(icon: LucideIcons.shield, label: "Política de Privacidad"),
                    _SettingsItem(icon: LucideIcons.fileText, label: "Términos de Servicio"),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text(
                      "QuickBite v1.0.0",
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium,
      ),
    );
  }
}

// --- WIDGETS PRIVADOS ---

class _SettingsHeader extends StatelessWidget {
  final VoidCallback onBackPressed;
  const _SettingsHeader({required this.onBackPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(10, MediaQuery.of(context).padding.top + 10, 20, 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(LucideIcons.chevronLeft, color: theme.colorScheme.onSurface),
            onPressed: onBackPressed,
          ),
          const SizedBox(width: 8),
          Text("Ajustes", style: theme.textTheme.titleLarge),
        ],
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;
  const _SettingsGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) => children[index],
        separatorBuilder: (context, index) => Divider(height: 1, indent: 50, color: Theme.of(context).dividerColor),
        itemCount: children.length,
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final AppThemeMode theme;
  final String label;
  final IconData icon;
  final AppThemeMode current;
  final Function(AppThemeMode) onTap;

  const _ThemeOption({
    required this.theme,
    required this.label,
    required this.icon,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = current == theme;
    final themeData = Theme.of(context);
    final colorScheme = themeData.colorScheme;
    
    return GestureDetector(
      onTap: () => onTap(theme),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary.withOpacity(0.1) : colorScheme.surfaceContainerHighest.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? colorScheme.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
              size: 28,
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: themeData.textTheme.labelLarge?.copyWith(
                color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final bool isSwitch;
  final bool switchValue;
  final Function(bool)? onSwitchChanged;

  const _SettingsItem({
    required this.icon,
    required this.label,
    this.value,
    this.isSwitch = false,
    this.switchValue = false,
    this.onSwitchChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: colorScheme.onSurface),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(label, style: theme.textTheme.bodyLarge)),
          if (value != null) ...[
            Text(value!, style: theme.textTheme.bodyMedium),
            const SizedBox(width: 8),
          ],
          if (isSwitch)
            Switch(
              value: switchValue,
              onChanged: onSwitchChanged,
              activeThumbColor: colorScheme.primary,
            )
          else
            Icon(LucideIcons.chevronRight, size: 18, color: colorScheme.onSurfaceVariant),
        ],
      ),
    );
  }
}