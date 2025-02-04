import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/cart_controller.dart';
import '../controllers/navigation_controller.dart';
import 'favorite_screen.dart';
import 'menu_screen.dart';
import 'profile_screen.dart';

class CartScreen extends GetView<CartController> {
  // ignore: use_super_parameters
  CartScreen({Key? key}) : super(key: key);

  final NavigationController navigationController =
      Get.find<NavigationController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Cart',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Obx(
                () => controller.cartItems.isEmpty
                    ? const Center(
                        child: Text(
                          'Your cart is empty',
                          style: TextStyle(fontSize: 18),
                        ),
                      )
                    : ListView.builder(
                        itemCount: controller.cartItems.length,
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (context, index) {
                          final item = controller.cartItems[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // Product Image
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    item['imageUrl'] ??
                                        'https://via.placeholder.com/60',
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 60,
                                        height: 60,
                                        color: Colors.grey[200],
                                        child: const Icon(
                                            Icons.image_not_supported),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Product Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['name'] ?? 'Unknown Product',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '\$${(item['price'] ?? 0.0).toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Quantity Controls
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove, size: 20),
                                      onPressed: () {
                                        final currentQuantity =
                                            item['quantity'] as int;
                                        if (currentQuantity > 1) {
                                          controller.updateQuantity(
                                            item['id'].toString(),
                                            currentQuantity - 1,
                                          );
                                        }
                                      },
                                    ),
                                    Text(
                                      (item['quantity'] ?? 1).toString(),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add, size: 20),
                                      onPressed: () {
                                        final currentQuantity =
                                            item['quantity'] as int;
                                        controller.updateQuantity(
                                          item['id'].toString(),
                                          currentQuantity + 1,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                // Remove Button
                                IconButton(
                                  icon: const Icon(Icons.close, size: 20),
                                  onPressed: () {
                                    controller
                                        .removeFromCart(item['id'].toString());
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),
            // Bottom Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Total Amount
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Obx(() => Text(
                              '\$${controller.totalAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            )),
                      ],
                    ),
                  ),
                  // Checkout Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: controller.cartItems.isEmpty
                          ? null
                          : () {
                              Get.snackbar(
                                'Success',
                                'Proceeding to checkout...',
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink[100],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        'Checkout',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Bottom Navigation Bar
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(Icons.home, 'Menu', 0),
                  _buildNavItem(Icons.favorite_border, 'Favorite', 1),
                  _buildNavItem(Icons.shopping_cart, 'Cart', 2),
                  _buildNavItem(Icons.person_outline, 'Profile', 3),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    return Obx(() {
      final isSelected = navigationController.currentIndex.value == index;
      return GestureDetector(
        onTap: () {
          navigationController.changePage(index);
          switch (index) {
            case 0:
              Get.off(() => MenuScreen());
              break;
            case 1:
              Get.to(() => FavoritesScreen());
              break;
            case 2:
              // We're already on cart screen
              break;
            case 3:
              Get.to(() => ProfileScreen());
              break;
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.pink[100] : Colors.grey,
            ),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.pink[100] : Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    });
  }
}
