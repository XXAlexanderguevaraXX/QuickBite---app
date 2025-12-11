import 'models/models.dart';

// MOCKS
const String MOCK_USER_NAME = "Alex";
const int MOCK_USER_BITES = 450;

final List<Store> STORES = [
  const Store(
      id: '1',
      name: 'QuickBite Centro',
      address: 'Av. Principal 123',
      distance: '0.5 km',
      waitTime: '10-15 min'),
  const Store(
      id: '2',
      name: 'QuickBite Plaza Norte',
      address: 'Mall Plaza, Local 45',
      distance: '2.3 km',
      waitTime: '15-20 min'),
  const Store(
      id: '3',
      name: 'QuickBite Universitario',
      address: 'Frente a la Facultad',
      distance: '5.0 km',
      waitTime: '25-30 min'),
];

final List<Reward> REWARDS = [
  const Reward(
      id: 'r1',
      name: 'Soda Pequeña',
      cost: 100,
      image:
          'https://images.unsplash.com/photo-1622483767028-3f66f32aef97?auto=format&fit=crop&w=200&q=80'),
  const Reward(
      id: 'r2',
      name: 'Papas Medianas',
      cost: 200,
      image:
          'https://images.unsplash.com/photo-1630384060421-cb20d0e0649d?auto=format&fit=crop&w=200&q=80'),
  const Reward(
      id: 'r3',
      name: 'Hamburguesa Clásica',
      cost: 500,
      image:
          'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=200&q=80'),
  const Reward(
      id: 'r4',
      name: 'Combo QuickBite',
      cost: 800,
      image:
          'https://images.unsplash.com/photo-1594212699903-ec8a3eca50f5?auto=format&fit=crop&w=200&q=80'),
];

final List<Product> MENU_ITEMS = [
  Product(
      id: 'b1',
      name: 'Quick Classic',
      description:
          'Carne 100% res, lechuga, tomate, queso cheddar y nuestra salsa secreta.',
      price: 8.50,
      category: Category.burgers,
      calories: 650,
      image:
          'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=500&q=80',
      ingredients: const [
        Ingredient(id: 'i1', name: 'Lechuga', type: IngredientType.removable),
        Ingredient(id: 'i2', name: 'Tomate', type: IngredientType.removable),
        Ingredient(
            id: 'i3', name: 'Queso Cheddar', type: IngredientType.removable),
        Ingredient(id: 'i4', name: 'Cebolla', type: IngredientType.removable),
        Ingredient(
            id: 'i5',
            name: 'Tocino Extra',
            type: IngredientType.addOn,
            price: 1.50),
        Ingredient(
            id: 'i6',
            name: 'Huevo Frito',
            type: IngredientType.addOn,
            price: 1.00),
      ]),
  Product(
      id: 'b2',
      name: 'Bacon Master',
      description:
          'Doble carne, cuádruple tocino, salsa BBQ ahumada y aros de cebolla.',
      price: 10.50,
      category: Category.burgers,
      calories: 890,
      image:
          'https://images.unsplash.com/photo-1594212699903-ec8a3eca50f5?auto=format&fit=crop&w=500&q=80',
      ingredients: const [
        Ingredient(
            id: 'i3', name: 'Queso Cheddar', type: IngredientType.removable),
        Ingredient(id: 'i7', name: 'Salsa BBQ', type: IngredientType.removable),
        Ingredient(
            id: 'i8', name: 'Aros de Cebolla', type: IngredientType.removable),
        Ingredient(
            id: 'i5',
            name: 'Tocino Extra',
            type: IngredientType.addOn,
            price: 1.50),
        Ingredient(
            id: 'i12',
            name: 'Carne Extra',
            type: IngredientType.addOn,
            price: 2.50),
      ]),
  Product(
      id: 's1',
      name: 'Papas Quick',
      description:
          'Papas corte clásico, doradas y crujientes con un toque de sal marina.',
      price: 3.50,
      category: Category.snacks,
      calories: 320,
      image:
          'https://images.unsplash.com/photo-1630384060421-cb20d0e0649d?auto=format&fit=crop&w=500&q=80',
      ingredients: const [
        Ingredient(id: 'i9', name: 'Sal', type: IngredientType.removable),
        Ingredient(
            id: 'i10',
            name: 'Salsa de Queso',
            type: IngredientType.addOn,
            price: 1.00),
        Ingredient(
            id: 'i13',
            name: 'Tocino Picado',
            type: IngredientType.addOn,
            price: 1.50),
      ]),
  Product(
      id: 'd1',
      name: 'Cola Refrescante',
      description: 'Bebida gaseosa helada, perfecta para acompañar tu burger.',
      price: 2.50,
      category: Category.drinks,
      calories: 150,
      image:
          'https://images.unsplash.com/photo-1622483767028-3f66f32aef97?auto=format&fit=crop&w=500&q=80',
      ingredients: const [
        Ingredient(id: 'i11', name: 'Hielo', type: IngredientType.removable),
        Ingredient(
            id: 'i14', name: 'Limón', type: IngredientType.addOn, price: 0.00),
      ]),
  Product(
      id: 'c1',
      name: 'Family Box',
      description: '2 Quick Classics, 2 Papas Medianas y 2 Bebidas grandes.',
      price: 22.00,
      category: Category.combos,
      calories: 1800,
      image:
          'https://images.unsplash.com/photo-1551782450-a2132b4ba21d?auto=format&fit=crop&w=500&q=80',
      ingredients: const [
        Ingredient(
            id: 'i15',
            name: 'Salsas Extra',
            type: IngredientType.addOn,
            price: 2.00),
      ]),
];

final List<ActiveOrder> ORDER_HISTORY = [
  ActiveOrder(
      id: '101',
      storeName: 'QuickBite Centro',
      timestamp: DateTime(2023, 10, 12, 14, 30),
      total: 12.50,
      status: OrderStatus.completed,
      items: [],
      pickupCode: 'QB101'),
  ActiveOrder(
      id: '102',
      storeName: 'QuickBite Plaza Norte',
      timestamp: DateTime(2023, 10, 5, 13, 15),
      total: 8.50,
      status: OrderStatus.completed,
      items: [],
      pickupCode: 'QB102'),
  ActiveOrder(
      id: '103',
      storeName: 'QuickBite Centro',
      timestamp: DateTime(2023, 9, 28, 20, 45),
      total: 24.00,
      status: OrderStatus.cancelled,
      items: [],
      pickupCode: 'QB103'),
];
