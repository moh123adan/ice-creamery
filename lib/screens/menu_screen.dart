import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../controllers/navigation_controller.dart';
import 'details_screen.dart';
import 'favorite_screen.dart';
import 'profile_screen.dart';

class MenuScreen extends StatelessWidget {
  MenuScreen({super.key});

  final NavigationController navigationController =
      Get.put(NavigationController());
  final RxList<DocumentSnapshot> products = RxList<DocumentSnapshot>([]);

  void _toggleFavorite(DocumentSnapshot product) async {
    final data = product.data() as Map<String, dynamic>;
    final favoritesRef = FirebaseFirestore.instance.collection('favorites');

    // Check if product is already in favorites
    final querySnapshot =
        await favoritesRef.where('productId', isEqualTo: product.id).get();

    if (querySnapshot.docs.isEmpty) {
      // Add to favorites
      await favoritesRef.add({
        'productId': product.id,
        'name': data['name'],
        'imageUrl': data['imageUrl'],
        'price': data['price'],
        'addedAt': FieldValue.serverTimestamp(),
      });
      Get.snackbar('Success', 'Added to favorites!');
    } else {
      // Remove from favorites
      await querySnapshot.docs.first.reference.delete();
      Get.snackbar('Success', 'Removed from favorites!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Menu',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.to(() => const ProfileScreen()),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person_outline),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Search Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    icon: Icon(Icons.search, color: Colors.grey[600]),
                    hintText: 'Search',
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Subtitle
              Text(
                'Discover and Enjoy the best flavor',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 20),

              // Products Grid
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('products')
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    products.value = snapshot.data!.docs;

                    return GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.85,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        final data = product.data() as Map<String, dynamic>;

                        return GestureDetector(
                          onTap: () =>
                              Get.to(() => DetailsScreen(product: data)),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFADE2FF),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Product Image
                                Container(
                                  height: 100,
                                  width: 100,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image:
                                          NetworkImage(data['imageUrl'] ?? ''),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                // Product Name
                                Text(
                                  data['name'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                // Product Price
                                Text(
                                  '\$${data['price']?.toStringAsFixed(2) ?? '0.00'}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                                // Favorite Button
                                IconButton(
                                  icon: const Icon(Icons.favorite_border),
                                  onPressed: () => _toggleFavorite(product),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              // Bottom Navigation Bar
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(Icons.home, 'Menu', 0),
                    _buildNavItem(Icons.favorite_border, 'Favorite', 1),
                    _buildNavItem(Icons.shopping_cart_outlined, 'Cart', 2),
                    _buildNavItem(Icons.person_outline, 'Profile', 3),
                  ],
                ),
              ),
            ],
          ),
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
              Get.offAll(() => MenuScreen());
              break;
            case 1:
              Get.to(() => FavoritesScreen());
              break;
            case 2:
              Get.snackbar('Cart', 'Coming soon!');
              break;
            case 3:
              Get.to(() => const ProfileScreen());
              break;
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.pink[200] : Colors.grey,
            ),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.pink[200] : Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    });
  }
}
