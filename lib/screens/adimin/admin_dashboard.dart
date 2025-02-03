import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../controllers/admin_controller.dart';
import '../../screens/menu_screen.dart';

class AdminDashboard extends StatelessWidget {
  AdminDashboard({super.key});

  final AdminController _adminController = Get.find<AdminController>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  final Rx<Uint8List?> selectedImageData = Rx<Uint8List?>(null);

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
        descriptionController.text.isEmpty ||
        selectedImageData.value == null) {
      Get.snackbar(
          "Error", "All fields are required and an image must be selected.");
      return;
    }

    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final imageUrl =
          await _adminController.uploadImage(selectedImageData.value!);
      print('Image uploaded to ImgBB, URL: $imageUrl');

      await _adminController.addNewProduct(
        nameController.text,
        double.parse(priceController.text),
        imageUrl,
        descriptionController.text,
      );

      Get.back(); // Close loading indicator

      nameController.clear();
      priceController.clear();
      descriptionController.clear();
      selectedImageData.value = null;

      Get.snackbar("Success", "Product added successfully!");

      // Navigate to MenuScreen after successful product addition
      Get.off(() => MenuScreen());
    } catch (e) {
      Get.back(); // Close loading indicator
      print('Error occurred: $e');
      Get.snackbar("Error", "Failed to add product: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Product Name'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              Obx(() {
                if (selectedImageData.value == null) {
                  return const Text('No Image Selected',
                      textAlign: TextAlign.center);
                } else {
                  return Image.memory(
                    selectedImageData.value!,
                    height: 150,
                    fit: BoxFit.cover,
                  );
                }
              }),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Select Image'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitProduct,
                child: const Text('Add Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
