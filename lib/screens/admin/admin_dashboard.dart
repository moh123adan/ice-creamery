import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../controllers/admin_controller.dart';
import '../../controllers/auth_controller.dart';
import '../menu_screen.dart';
import '../../models/product.dart';

class AdminDashboard extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  AdminDashboard({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final AdminController _adminController = Get.find<AdminController>();
  final AuthController _authController = Get.find<AuthController>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  final Rx<Uint8List?> selectedImageData = Rx<Uint8List?>(null);

  Product? editingProduct;

  @override
  void initState() {
    super.initState();
    _adminController.fetchProducts();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        selectedImageData.value = await pickedFile.readAsBytes();
        print(
            'Image picked successfully. Size: ${selectedImageData.value!.length} bytes');
      }
    } catch (e) {
      print('Error picking image: $e');
      Get.snackbar('Error', 'Failed to pick image: $e');
    }
  }

  Future<void> _submitProduct() async {
    if (nameController.text.isEmpty ||
        priceController.text.isEmpty ||
        descriptionController.text.isEmpty) {
      Get.snackbar("Error", "All fields are required.",
          colorText: Colors.white, backgroundColor: Colors.red);
      return;
    }

    try {
      Get.dialog(
        Center(
            child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue))),
        barrierDismissible: false,
      );

      String imageUrl = editingProduct?.imageUrl ?? '';
      if (selectedImageData.value != null) {
        imageUrl = await _adminController.uploadImage(selectedImageData.value!);
        print('Image uploaded to ImgBB, URL: $imageUrl');
      }

      if (editingProduct == null) {
        await _adminController.addNewProduct(
          nameController.text,
          double.parse(priceController.text),
          imageUrl,
          descriptionController.text,
        );
      } else {
        await _adminController.updateProduct(
          editingProduct!.id,
          nameController.text,
          double.parse(priceController.text),
          imageUrl,
          descriptionController.text,
        );
      }

      Get.back(); // Close loading indicator

      _clearForm();
      Get.snackbar(
        "Success",
        editingProduct == null
            ? "Product added successfully!"
            : "Product updated successfully!",
        colorText: Colors.white,
        backgroundColor: Colors.green,
      );
    } catch (e) {
      Get.back(); // Close loading indicator
      print('Error occurred: $e');
      Get.snackbar(
        "Error",
        "Failed to ${editingProduct == null ? 'add' : 'update'} product: $e",
        colorText: Colors.white,
        backgroundColor: Colors.red,
      );
    }
  }

  void _clearForm() {
    nameController.clear();
    priceController.clear();
    descriptionController.clear();
    selectedImageData.value = null;
    editingProduct = null;
    setState(() {});
  }

  void _editProduct(Product product) {
    editingProduct = product;
    nameController.text = product.name;
    priceController.text = product.price.toString();
    descriptionController.text = product.description;
    selectedImageData.value = null;
    setState(() {});
  }

  Future<void> _deleteProduct(String productId) async {
    try {
      await _adminController.deleteProduct(productId);
      Get.snackbar("Success", "Product deleted successfully!",
          colorText: Colors.white, backgroundColor: Colors.green);
    } catch (e) {
      print('Error deleting product: $e');
      Get.snackbar("Error", "Failed to delete product: $e",
          colorText: Colors.white, backgroundColor: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () => _authController.signOut(),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue, Colors.blue.shade100],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          editingProduct == null
                              ? 'Add New Product'
                              : 'Edit Product',
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue),
                        ),
                        SizedBox(height: 20),
                        _buildTextField(
                            nameController, 'Product Name', Icons.shopping_bag),
                        SizedBox(height: 10),
                        _buildTextField(
                            priceController, 'Price', Icons.attach_money,
                            isNumber: true),
                        SizedBox(height: 10),
                        _buildTextField(descriptionController, 'Description',
                            Icons.description,
                            maxLines: 3),
                        SizedBox(height: 20),
                        _buildImagePicker(),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _submitProduct,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  padding: EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                child: Text(editingProduct == null
                                    ? 'Add Product'
                                    : 'Update Product'),
                              ),
                            ),
                            if (editingProduct != null) ...[
                              SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _clearForm,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey,
                                    padding: EdgeInsets.symmetric(vertical: 15),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: Text('Cancel'),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Get.to(() => MenuScreen()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('View Menu'),
                ),
                SizedBox(height: 20),
                Text(
                  'Existing Products',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                SizedBox(height: 10),
                _buildProductList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {bool isNumber = false, int maxLines = 1}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.white,
      ),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Product Image',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Obx(() {
          if (selectedImageData.value == null &&
              editingProduct?.imageUrl == null) {
            return Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(child: Text('No Image Selected')),
            );
          } else {
            return Container(
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: selectedImageData.value != null
                      ? MemoryImage(selectedImageData.value!)
                      : NetworkImage(editingProduct!.imageUrl) as ImageProvider,
                ),
              ),
            );
          }
        }),
        SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: _pickImage,
          icon: Icon(Icons.image),
          label: Text('Select Image'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  Widget _buildProductList() {
    return Obx(() => ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: _adminController.products.length,
          itemBuilder: (context, index) {
            final product = _adminController.products[index];
            return Card(
              elevation: 2,
              margin: EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    product.imageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.error),
                  ),
                ),
                title: Text(product.name,
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _editProduct(product),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteProduct(product.id),
                    ),
                  ],
                ),
              ),
            );
          },
        ));
  }
}
