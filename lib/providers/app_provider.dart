import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../constants.dart';

class AppProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  // SECCIÓN 1: AUTENTICACIÓN Y GESTIÓN DE VISTAS
  User? _user;
  AppView _currentView = AppView.home;
  Product? _selectedProduct;
  ActiveOrder? _lastCreatedOrder;

  User? get user => _user;
  bool get isLoggedIn => _user != null;
  AppView get currentView => _currentView;
  Product? get selectedProduct => _selectedProduct;
  ActiveOrder? get lastCreatedOrder => _lastCreatedOrder;

  AppProvider() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
    _fetchOrderHistory();
  }

  void _onAuthStateChanged(User? user) {
    _user = user;
    if (user == null) {
      _currentView = AppView.home;
      clearCart();
    } else {
      _currentView = AppView.home;
    }
    notifyListeners();
  }

  void setView(AppView view) {
    if (view != AppView.productDetail) _selectedProduct = null;
    if (view != AppView.orderStatus) _lastCreatedOrder = null;
    _currentView = view;
    notifyListeners();
  }

  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No se encontró un usuario con ese correo.';
      }
      if (e.code == 'wrong-password') return 'La contraseña es incorrecta.';
      if (e.code == 'invalid-credential') {
        return 'Las credenciales no son válidas.';
      }
      return 'Ocurrió un error. Inténtalo de nuevo.';
    }
  }

  Future<String?> register(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') return 'La contraseña es demasiado débil.';
      if (e.code == 'email-already-in-use') {
        return 'Ya existe una cuenta con este correo.';
      }
      if (e.code == 'invalid-email') {
        return 'El formato del correo no es válido.';
      }
      return 'Ocurrió un error durante el registro.';
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  // SECCIÓN 2: CARRITO DE COMPRAS
  final List<CartItem> _cart = [];
  List<CartItem> get cart => UnmodifiableListView(_cart);
  double get cartTotal =>
      _cart.fold(0.0, (total, current) => total + current.totalPrice);
  int get cartItemCount => _cart.length;

  void addToCart(Product product, CartItemCustomizations customizations) {
    final newItem = CartItem(
      cartId: _uuid.v4(),
      product: product,
      quantity: 1,
      customizations: customizations,
    );
    _cart.add(newItem);
    notifyListeners();
  }

  void updateCartItemQuantity(String cartId, int change) {
    final int itemIndex = _cart.indexWhere((item) => item.cartId == cartId);
    if (itemIndex == -1) return;
    final oldItem = _cart[itemIndex];
    final newQuantity = oldItem.quantity + change;
    if (newQuantity <= 0) {
      removeFromCart(cartId);
    } else {
      _cart[itemIndex] = oldItem.copyWith(quantity: newQuantity);
      notifyListeners();
    }
  }

  void removeFromCart(String cartId) {
    _cart.removeWhere((item) => item.cartId == cartId);
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  // SECCIÓN 3: GESTIÓN DE PEDIDOS E HISTORIAL
  List<ActiveOrder> _orderHistory = [];
  List<ActiveOrder> get orderHistory => UnmodifiableListView(_orderHistory);

  Future<bool> createOrder(
      {required String storeId, required String storeName}) async {
    if (!isLoggedIn || _cart.isEmpty) return false;

    final pickupCode =
        'QB${DateTime.now().second}${DateTime.now().millisecond}';
    final newOrder = ActiveOrder(
      id: 'temp_id',
      items: List.from(_cart),
      total: cartTotal,
      status: OrderStatus.pending,
      storeName: storeName,
      pickupCode: pickupCode,
      timestamp: DateTime.now(),
    );
    try {
      final orderItems = _cart
          .map((item) => {
                'productId': item.product.id,
                'productName': item.product.name,
                'quantity': item.quantity,
                'unitPrice': item.product.price,
                'totalItemPrice': item.totalPrice,
                'customizations': item.customizations.toJson(),
              })
          .toList();
      await _firestore.collection('orders').add({
        'userId': _user!.uid,
        'userEmail': _user!.email,
        'items': orderItems,
        'orderTotal': newOrder.total,
        'orderTimestamp': FieldValue.serverTimestamp(),
        'status': newOrder.status.name,
        'storeId': storeId,
        'storeName': newOrder.storeName,
        'pickupCode': newOrder.pickupCode,
      });
      _lastCreatedOrder = newOrder;
      clearCart();
      setView(AppView.orderStatus);
      return true;
    } catch (e) {
      debugPrint("Error al crear la orden: $e");
      return false;
    }
  }

  void _fetchOrderHistory() {
    _orderHistory = ORDER_HISTORY;
  }

  // SECCIÓN 4: ESTADO DEL MENÚ
  CategoryFilter _activeCategoryFilter = CategoryFilter.all;
  final Set<String> _favoriteProductIds = {'b1', 's1'};

  CategoryFilter get activeCategoryFilter => _activeCategoryFilter;
  Set<String> get favoriteProductIds => _favoriteProductIds;

  void setCategoryFilter(CategoryFilter filter) {
    _activeCategoryFilter = filter;
    notifyListeners();
  }

  void toggleFavorite(String productId) {
    _favoriteProductIds.contains(productId)
        ? _favoriteProductIds.remove(productId)
        : _favoriteProductIds.add(productId);
    notifyListeners();
  }

  void selectProduct(Product product) {
    _selectedProduct = product;
    setView(AppView.productDetail);
  }

  // SECCIÓN 5: PERFIL Y RECOMPENSAS
  int _userPoints = MOCK_USER_BITES;
  String get userName =>
      isLoggedIn ? _user?.displayName ?? MOCK_USER_NAME : 'Invitado';
  String? get userEmail => _user?.email;
  String? get userAvatarUrl =>
      _user?.photoURL ?? "https://avatar.iran.liara.run/public";
  int get userPoints => _userPoints;

  Future<bool> redeemReward(Reward reward) async {
    if (_userPoints < reward.cost) return false;
    await Future.delayed(const Duration(milliseconds: 500));
    _userPoints -= reward.cost;
    notifyListeners();
    return true;
  }

  // SECCIÓN 6: AJUSTES
  AppThemeMode _themeMode = AppThemeMode.light;
  bool _notificationsEnabled = true;
  bool _smsPromotionsEnabled = false;

  AppThemeMode get themeMode => _themeMode;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get smsPromotionsEnabled => _smsPromotionsEnabled;

  void setTheme(AppThemeMode newTheme) {
    if (_themeMode != newTheme) {
      _themeMode = newTheme;
      notifyListeners();
    }
  }

  void setNotifications(bool isEnabled) {
    _notificationsEnabled = isEnabled;
    notifyListeners();
  }

  void setSmsPromotions(bool isEnabled) {
    _smsPromotionsEnabled = isEnabled;
    notifyListeners();
  }
}
