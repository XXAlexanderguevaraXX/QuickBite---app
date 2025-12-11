// views/auth_wrapper.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import 'login_view.dart';
import 'main_screen.dart';
import 'register_view.dart'; // Import the register view

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // We watch the current view from the provider.
    final currentView = context.watch<AppProvider>().currentView;

    // AnimatedSwitcher for smooth transitions between different views.
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: _getViewFor(currentView),
    );
  }

  Widget _getViewFor(AppView view) {
    switch (view) {
      case AppView.login:
        return const LoginView(key: ValueKey('LoginView'));
      case AppView.register:
        return const RegisterView(key: ValueKey('RegisterView'));
      case AppView.home:
      case AppView.menu:
      case AppView.cart:
      case AppView.rewards:
      case AppView.profile:
      case AppView.productDetail:
      case AppView.orderStatus:
      case AppView.checkout:
      case AppView.history:
      case AppView.settings:
        return const MainScreen(key: ValueKey('MainScreen'));
      default:
        return const LoginView(key: ValueKey('LoginView'));
    }
  }
}