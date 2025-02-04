import 'package:flutter/material.dart';
import 'package:get/get.dart';


import '../../controllers/admin_controller.dart';

class ManageProducts extends StatelessWidget {
  final AdminController _controller = Get.find();

   ManageProducts({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Manage Products")),
      body: Obx(() {
        return ListView.builder(
          itemCount: _controller.products.length,
          itemBuilder: (context, index) {
            final product = _controller.products[index];
            return ListTile(
              title: Text(product.name),
              subtitle: Text("\$${product.price}"),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  _controller.deleteProduct(product.id);
                },
              ),
            );
          },
        );
      }),
    );
  }
}
