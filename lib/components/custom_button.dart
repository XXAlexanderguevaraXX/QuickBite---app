// components/custom_button.dart

import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    // Usamos un ElevatedButton.icon si hay un ícono, si no, un ElevatedButton normal.
    // Lo más importante es que NO definimos colores aquí. Los heredará automáticamente
    // de nuestro ElevatedButtonThemeData en app_theme.dart.
    final button = icon != null
        ? ElevatedButton.icon(
            icon: _buildChild(), // El child se encarga de mostrar el icono o el loader
            label: Text(text),
            onPressed: isLoading ? null : onPressed,
          )
        : ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            child: _buildChild(), // El child muestra el texto o el loader
          );
    
    // Si fullWidth es true, lo envolvemos en un SizedBox para que ocupe todo el ancho.
    if (fullWidth) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }
    
    return button;
  }

  // Widget helper para decidir si mostrar el contenido del botón o un loader.
  Widget _buildChild() {
    if (isLoading) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: Colors.white, // El color del loader siempre será blanco sobre el botón primario.
        ),
      );
    }
    
    // Si no hay icono, el child es solo el texto.
    if (icon == null) {
      return Text(text);
    }
    
    // Si hay icono, el ElevatedButton.icon ya lo pone a la izquierda,
    // así que aquí solo necesitamos el widget del icono para el parámetro `icon`.
    // En el caso de ElevatedButton.icon, `label` se encarga del texto.
    return Icon(icon, size: 18);
  }
}