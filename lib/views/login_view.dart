// views/login_view.dart

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../components/custom_button.dart';
import '../models/models.dart'; // Importamos para usar AppView

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  bool _isLoading = false;
  final _emailController = TextEditingController();
  final _passController = TextEditingController();

  Future<void> _handleLogin() async {
    // Usamos context.read porque estamos en un callback.
    final provider = context.read<AppProvider>();
    final email = _emailController.text.trim();
    final password = _passController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, completa todos los campos")),
      );
      return;
    }

    setState(() => _isLoading = true);

    // CORRECCIÓN: Capturamos el mensaje de error del provider.
    final String? errorMessage = await provider.login(email, password);

    if (!mounted) return;

    setState(() => _isLoading = false);
    
    // Si hubo un error, errorMessage no será null.
    if (errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage), // Mostramos el error específico.
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
    // Si fue exitoso (errorMessage es null), el listener del provider se encargará
    // de cambiar la vista a 'home' automáticamente.
  }

  @override
  void dispose() {
    // Es buena práctica limpiar los controllers.
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppProvider>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // CORRECCIÓN: Usamos Scaffold sin backgroundColor fijo para que se adapte al tema.
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- LOGO Y BIENVENIDA ---
                _buildHeader(theme, colorScheme),
                const SizedBox(height: 48),

                // --- FORMULARIO DE INPUTS ---
                _buildFormFields(theme, colorScheme),

                const SizedBox(height: 24),

                // --- BOTÓN DE LOGIN ---
                CustomButton(
                  text: "Iniciar Sesión",
                  fullWidth: true,
                  isLoading: _isLoading,
                  onPressed: _handleLogin,
                ),

                const SizedBox(height: 24),

                // --- LINKS (REGISTRO / INVITADO) ---
                _buildFooterLinks(provider, colorScheme),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  // --- WIDGETS PRIVADOS (REFACTORIZACIÓN) ---

  Widget _buildHeader(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      children: [
        Container(
          height: 80,
          width: 80,
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(LucideIcons.chefHat, size: 40, color: colorScheme.primary),
        ),
        const SizedBox(height: 24),
        Text("¡Bienvenido! 👋", style: theme.textTheme.displaySmall, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(
          "Inicia sesión para acumular puntos y ordenar más rápido.",
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge,
        ),
      ],
    );
  }

  Widget _buildFormFields(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      children: [
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            prefixIcon: Icon(LucideIcons.mail, size: 20, color: colorScheme.onSurfaceVariant),
            hintText: 'Correo electrónico',
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passController,
          obscureText: true,
          decoration: InputDecoration(
            prefixIcon: Icon(LucideIcons.lock, size: 20, color: colorScheme.onSurfaceVariant),
            hintText: 'Contraseña',
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () { /* Lógica para recuperar contraseña */ },
            child: const Text("¿Olvidaste tu contraseña?"),
          ),
        ),
      ],
    );
  }

  Widget _buildFooterLinks(AppProvider provider, ColorScheme colorScheme) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("¿No tienes una cuenta?"),
            TextButton(
              // CORRECCIÓN: Usamos el enum AppView.
              onPressed: () => provider.setView(AppView.register),
              child: const Text("Regístrate ahora"),
            ),
          ],
        ),
        TextButton(
          onPressed: () => provider.setView(AppView.home),
          style: TextButton.styleFrom(
            foregroundColor: colorScheme.onSurface.withOpacity(0.7),
          ),
          child: const Text("O entra como Invitado"),
        ),
      ],
    );
  }
}