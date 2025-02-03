import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/admin_controller.dart';

class ManageUsers extends StatelessWidget {
  final AdminController _controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Manage Users")),
      body: Obx(() {
        return ListView.builder(
          itemCount: _controller.users.length,
          itemBuilder: (context, index) {
            final user = _controller.users[index];
            return ListTile(
              title: Text(user.name),
              subtitle: Text(user.email),
              trailing: IconButton(
                icon: Icon(user.isAdmin ? Icons.star : Icons.star_border),
                onPressed: () {
                  _controller.updateUserRole(user.id, !user.isAdmin);
                },
              ),
            );
          },
        );
      }),
    );
  }
}
