import 'package:collection/collection.dart';

// --- ENUMS ---
enum Category { burgers, snacks, drinks, combos }

enum IngredientType { removable, addOn }

enum OrderStatus { pending, preparing, readyForPickup, completed, cancelled }

enum AppView {
  home,
  menu,
  rewards,
  cart,
  profile,
  productDetail,
  checkout,
  orderStatus,
  history,
  settings,
  login,
  register
}

enum CategoryFilter { all, favorites, burgers, snacks, drinks, combos }

enum AppThemeMode { light, softDark, midnight }

// --- MODELOS ---
class Ingredient {
  final String id;
  final String name;
  final IngredientType type;
  final double? price;
  const Ingredient(
      {required this.id, required this.name, required this.type, this.price});
}

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final Category category;
  final String image;
  final int calories;
  final List<Ingredient> ingredients;
  const Product(
      {required this.id,
      required this.name,
      required this.description,
      required this.price,
      required this.category,
      required this.image,
      required this.calories,
      required this.ingredients});
}

class CartItemCustomizations {
  final Set<String> removedIngredientIds;
  final Set<String> addedExtraIds;
  const CartItemCustomizations(
      {this.removedIngredientIds = const {}, this.addedExtraIds = const {}});
  bool get isCustomized =>
      removedIngredientIds.isNotEmpty || addedExtraIds.isNotEmpty;
  Map<String, dynamic> toJson() => {
        'removedIngredientIds': removedIngredientIds.toList(),
        'addedExtraIds': addedExtraIds.toList()
      };
  CartItemCustomizations copyWith(
          {Set<String>? removedIngredientIds, Set<String>? addedExtraIds}) =>
      CartItemCustomizations(
          removedIngredientIds:
              removedIngredientIds ?? this.removedIngredientIds,
          addedExtraIds: addedExtraIds ?? this.addedExtraIds);
}

class CartItem {
  final String cartId;
  final Product product;
  final int quantity;
  final CartItemCustomizations customizations;
  const CartItem(
      {required this.cartId,
      required this.product,
      required this.quantity,
      required this.customizations});
  bool get isCustomized => customizations.isCustomized;
  double get totalPrice {
    double extrasPrice = customizations.addedExtraIds.fold(0.0, (sum, extraId) {
      final ingredient =
          product.ingredients.firstWhereOrNull((ing) => ing.id == extraId);
      return sum + (ingredient?.price ?? 0);
    });
    return (product.price + extrasPrice) * quantity;
  }

  CartItem copyWith({int? quantity, CartItemCustomizations? customizations}) =>
      CartItem(
          cartId: cartId,
          product: product,
          quantity: quantity ?? this.quantity,
          customizations: customizations ?? this.customizations);
}

class ActiveOrder {
  final String id;
  final List<CartItem> items;
  final double total;
  final OrderStatus status;
  final String storeName;
  final String pickupCode;
  final DateTime timestamp;
  const ActiveOrder(
      {required this.id,
      required this.items,
      required this.total,
      required this.status,
      required this.storeName,
      required this.pickupCode,
      required this.timestamp});
}

class Store {
  final String id;
  final String name;
  final String address;
  final String distance;
  final String waitTime;
  const Store(
      {required this.id,
      required this.name,
      required this.address,
      required this.distance,
      required this.waitTime});
}

class Reward {
  final String id;
  final String name;
  final int cost;
  final String image;
  const Reward(
      {required this.id,
      required this.name,
      required this.cost,
      required this.image});
}
