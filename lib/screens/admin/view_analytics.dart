import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_controller.dart';

class AnalyticsScreen extends StatelessWidget {
  final AdminController adminController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Analytics')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          return Column(
            children: [
              _buildAnalyticsCard('Total Users', adminController.users.length),
              _buildAnalyticsCard('Total Products', adminController.products.length),
              _buildAnalyticsCard('Total Orders', adminController.orders.length),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildAnalyticsCard(String title, int count) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: Icon(Icons.analytics, color: Colors.blue),
        title: Text(title),
        trailing: Text(count.toString(), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
