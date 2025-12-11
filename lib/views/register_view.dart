// views/register_view.dart

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../components/custom_button.dart';
import '../models/models.dart'; // Para AppView

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  bool _isLoading = false;
  final _emailController = TextEditingController();
  final _passController = TextEditingController();

  Future<void> _handleRegister() async {
    final provider = context.read<AppProvider>();
    final email = _emailController.text.trim();
    final password = _passController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, completa todos los campos")),
      );
      return;
    }
    // La validación de longitud de contraseña de Firebase es a menudo suficiente.
    // Podemos quitar la validación local para no duplicar lógica.

    setState(() => _isLoading = true);

    // CORRECCIÓN: Capturamos el mensaje de error específico del provider.
    final String? errorMessage = await provider.register(email, password);

    if (!mounted) return;

    setState(() => _isLoading = false);
    
    if (errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage), // Mostramos el error específico de Firebase.
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
    // Si el registro fue exitoso (errorMessage es null), el listener de autenticación
    // del provider se encargará de navegar a la vista 'home' automáticamente.
  }

  @override
  void dispose() {
    // CORRECCIÓN: Limpiamos los controllers para evitar memory leaks.
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppProvider>();
    final theme = Theme.of(context);

    // CORRECCIÓN: Usamos Scaffold sin backgroundColor para que se adapte al tema.
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(theme),
                const SizedBox(height: 48),
                _buildFormFields(),
                const SizedBox(height: 24),
                CustomButton(
                  text: "Registrarse",
                  fullWidth: true,
                  isLoading: _isLoading,
                  onPressed: _handleRegister,
                ),
                const SizedBox(height: 24),
                _buildFooterLink(provider),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGETS PRIVADOS (REFACTORIZACIÓN) ---

  Widget _buildHeader(ThemeData theme) {
    return Column(
      children: [
        Container(
          height: 80,
          width: 80,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            LucideIcons.userPlus,
            size: 40,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 24),
        Text("Crea tu Cuenta", style: theme.textTheme.displaySmall, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(
          "Es rápido y fácil para empezar a ordenar.",
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge,
        ),
      ],
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            prefixIcon: Icon(LucideIcons.mail, size: 20),
            hintText: 'Correo electrónico',
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passController,
          obscureText: true,
          decoration: const InputDecoration(
            prefixIcon: Icon(LucideIcons.lock, size: 20),
            hintText: 'Contraseña (mín. 6 caracteres)',
          ),
        ),
      ],
    );
  }

  Widget _buildFooterLink(AppProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("¿Ya tienes una cuenta?"),
        TextButton(
          // CORRECCIÓN: Usamos el enum AppView para una navegación segura.
          onPressed: () => provider.setView(AppView.login),
          child: const Text("Inicia Sesión"),
        ),
      ],
    );
  }
}