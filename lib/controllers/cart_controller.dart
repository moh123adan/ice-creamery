import 'package:get/get.dart';

class CartController extends GetxController {
  static CartController get instance => Get.find();
  final RxList<Map<String, dynamic>> cartItems = <Map<String, dynamic>>[].obs;

  void addToCart(Map<String, dynamic> product, int quantity) {
    final existingItemIndex =
        cartItems.indexWhere((item) => item['id'] == product['id']);

    if (existingItemIndex != -1) {
      // Update quantity if item exists
      cartItems[existingItemIndex]['quantity'] += quantity;
    } else {
      // Add new item
      cartItems.add({
        ...product,
        'quantity': quantity,
      });
    }
    update();
    Get.snackbar(
      'Success',
      'Added to cart',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void removeFromCart(String productId) {
    cartItems.removeWhere((item) => item['id'] == productId);
    update();
  }

  void updateQuantity(String productId, int newQuantity) {
    final index = cartItems.indexWhere((item) => item['id'] == productId);
    if (index != -1) {
      if (newQuantity > 0) {
        cartItems[index]['quantity'] = newQuantity;
      } else {
        cartItems.removeAt(index);
      }
      update();
    }
  }

  double get totalAmount {
    return cartItems.fold(0.0, (sum, item) {
      final quantity = item['quantity'] as int;
      final price = (item['price'] as num).toDouble();
      return sum + (price * quantity);
    });
  }

  int get itemCount => cartItems.length;

  void clearCart() {
    cartItems.clear();
    update();
  }
}
