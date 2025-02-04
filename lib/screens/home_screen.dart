import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'admin/admin_dashboard.dart';
import 'login.dart';
// import '../admin/admin_dashboard.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB0E5FE),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Center(
              child: Image.asset(
                'assets/logo.png',
                height: 300,
                errorBuilder: (context, error, stackTrace) {
                  print('Error loading logo: $error');
                  return Column(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 60,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Unable to load logo',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Enjoy Your Ice Cream",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 35,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 40),
            _buildButton(
              label: "Get Started",
              color: Colors.pinkAccent,
              onPressed: () => Get.to(() => LoginPage()),
            ),
            const SizedBox(height: 20),
            _buildButton(
              label: "Admin Dashboard",
              color: Colors.blueAccent,
              onPressed: () => Get.to(() => AdminDashboard()),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 250, // Fixed width for consistent button sizes
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 5,
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
