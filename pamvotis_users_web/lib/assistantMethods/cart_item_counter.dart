import 'package:flutter/material.dart';

import '../global/global.dart';

class CartItemCounter extends ChangeNotifier {
  int _cartListItemCounter = 0;

  CartItemCounter() {
    // Initialize counter in constructor
    _cartListItemCounter = _getCartCount();
  }

  int get count => _cartListItemCounter;

  int _getCartCount() {
    var cartList = sharedPreferences!.getStringList("userCart");
    if (cartList == null || cartList.isEmpty) {
      return 0;
    }
    // Subtract 1 to account for the 'garbageValue'
    return cartList.length - 1;
  }

  void displayCartListItemsNumber() {
    _cartListItemCounter = _getCartCount();
    notifyListeners();
  }
}