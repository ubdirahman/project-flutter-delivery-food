import 'package:flutter/material.dart';
import '../data/models/food_model.dart';

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => {..._items};

  int get itemCount => _items.length;

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  void addItem(FoodModel food) {
    if (_items.containsKey(food.id)) {
      _items.update(
        food.id,
        (existing) => CartItem(
          id: existing.id,
          name: existing.name,
          price: existing.price,
          quantity: existing.quantity + 1,
          image: existing.image,
        ),
      );
    } else {
      _items.putIfAbsent(
        food.id,
        () => CartItem(
          id: food.id,
          name: food.name,
          price: food.price,
          quantity: 1,
          image: food.image,
        ),
      );
    }
    notifyListeners();
  }

  void incrementQuantity(String foodId) {
    if (_items.containsKey(foodId)) {
      _items.update(
        foodId,
        (existing) => CartItem(
          id: existing.id,
          name: existing.name,
          price: existing.price,
          quantity: existing.quantity + 1,
          image: existing.image,
        ),
      );
      notifyListeners();
    }
  }

  void decrementQuantity(String foodId) {
    if (_items.containsKey(foodId)) {
      if (_items[foodId]!.quantity > 1) {
        _items.update(
          foodId,
          (existing) => CartItem(
            id: existing.id,
            name: existing.name,
            price: existing.price,
            quantity: existing.quantity - 1,
            image: existing.image,
          ),
        );
        notifyListeners();
      }
      // If quantity is 1, do nothing - don't remove the item
    }
  }

  void removeItem(String foodId) {
    _items.remove(foodId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}

class CartItem {
  final String id;
  final String name;
  final double price;
  final int quantity;
  final String image;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.image,
  });
}
