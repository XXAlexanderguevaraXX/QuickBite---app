// views/main_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../components/custom_bottom_nav.dart';
import '../models/models.dart';

// Importamos todas las vistas que va a manejar
import 'home_view.dart';
import 'menu_view.dart';
import 'rewards_view.dart';
import 'cart_view.dart';
import 'profile_view.dart';
import 'checkout_view.dart';
import 'history_view.dart';
import 'settings_view.dart';
import 'product_detail_view.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  // Este es el mapa "cerebro" de la navegación.
  // Cada AppView apunta a su widget correspondiente.
  static final Map<AppView, Widget> _viewMap = {
    // --- Vistas del Bottom Nav ---
    AppView.home: const HomeView(),
    AppView.menu: const MenuView(),
    AppView.rewards: const RewardsView(),
    AppView.cart: const CartView(),
    AppView.profile: const ProfileView(),

    // --- Vistas secundarias a las que se navega ---
    AppView.checkout: const CheckoutView(),
    AppView.history: const HistoryView(),
    AppView.settings: const SettingsView(),
    AppView.productDetail: const ProductDetailView(),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Selector<AppProvider, AppView>(
              selector: (_, provider) => provider.currentView,
              builder: (context, currentView, _) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  key: ValueKey(currentView),
                  child: _viewMap[currentView] ??
                      Scaffold(
                          body: Center(
                              child:
                                  Text("Vista no encontrada: $currentView"))),
                );
              },
            ),
          ),
          _ConditionalBottomNav(),
        ],
      ),
    );
  }
}

class _ConditionalBottomNav extends StatelessWidget {
  // Lista de vistas que deben mostrar la barra de navegación.
  static const _viewsWithNav = {
    AppView.home,
    AppView.menu,
    AppView.rewards,
    AppView.cart,
    AppView.profile,
  };

  @override
  Widget build(BuildContext context) {
    return Selector<AppProvider, (AppView, int)>(
      selector: (_, provider) => (provider.currentView, provider.cartItemCount),
      builder: (context, data, _) {
        final currentView = data.$1;
        final cartCount = data.$2;
        final provider = context.read<AppProvider>();

        if (!_viewsWithNav.contains(currentView)) {
          return const SizedBox.shrink();
        }

        return CustomBottomNav(
          currentView: currentView,
          onViewChanged: provider.setView,
          cartCount: cartCount,
        );
      },
    );
  }
}
