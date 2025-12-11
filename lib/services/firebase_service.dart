import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- AUTH ---

  // Obtener usuario actual
  User? get currentUser => _auth.currentUser;

  // Iniciar Sesión
  Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  // Registrarse (Opcional por ahora, pero útil)
  Future<void> signUp(String email, String password, String name) async {
    UserCredential cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    // Guardar nombre del usuario en Firestore
    await _db.collection('users').doc(cred.user!.uid).set({
      'name': name,
      'email': email,
      'points': 0, // Puntos iniciales
      'createdAt': DateTime.now(),
    });
  }

  // Cerrar Sesión
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // --- DATABASE (PEDIDOS) ---

  // Guardar un pedido
  Future<void> saveOrder(ActiveOrder order, String userId) async {
    // Convertimos el objeto ActiveOrder a Mapa (JSON) para Firebase
    final orderData = {
      'id': order.id,
      'userId': userId,
      'total': order.total,
      'status': order.status,
      'storeName': order.storeName,
      'pickupCode': order.pickupCode,
      'timestamp': order.timestamp,
      'items': order.items
          .map(
            (item) => {
              'productId': item.product.id,
              'productName': item.product.name,
              'quantity': item.quantity,
              'price': item.totalPrice,
              'customizations': item.customizations, // Guardamos los extras
            },
          )
          .toList(),
    };

    await _db.collection('orders').doc(order.id).set(orderData);

    // Actualizar puntos del usuario (10 ptos por dólar)
    int pointsEarned = (order.total * 10).floor();
    await _db.collection('users').doc(userId).update({
      'points': FieldValue.increment(pointsEarned),
    });
  }

  // Obtener historial de pedidos
  Stream<List<Map<String, dynamic>>> getUserOrders() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value([]);

    return _db
        .collection('orders')
        .where('userId', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // Obtener puntos del usuario en tiempo real
  Stream<int> getUserPoints() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value(0);

    return _db.collection('users').doc(uid).snapshots().map((doc) {
      return doc.data()?['points'] ?? 0;
    });
  }
}
