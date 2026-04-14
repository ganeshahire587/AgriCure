import 'package:agricure/controller/authCntroller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterScreen extends StatelessWidget {
  RegisterScreen({Key? key}) : super(key: key);

  final AuthController authController = Get.find<AuthController>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1B5E20)),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Реєстрація',
          style: TextStyle(
            color: Color(0xFF1B5E20),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              // Logo
              const Center(
                child: Icon(Icons.eco, size: 80, color: Color(0xFF2E7D32)),
              ),
              const SizedBox(height: 40),

              // Name
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: "Ім'я",
                  prefixIcon: const Icon(
                    Icons.person_outline,
                    color: Color(0xFF2E7D32),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Email
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Email',
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: Color(0xFF2E7D32),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Password
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Пароль',
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: Color(0xFF2E7D32),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Confirm Password
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Підтвердіть пароль',
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: Color(0xFF2E7D32),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Register Button
              Obx(
                () => ElevatedButton(
                  onPressed: authController.isLoading.value
                      ? null
                      : () {
                          if (passwordController.text !=
                              confirmPasswordController.text) {
                            Get.snackbar(
                              'Помилка',
                              'Паролі не співпадають',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                            return;
                          }
                          authController.register(
                            emailController.text.trim(),
                            passwordController.text.trim(),
                            nameController.text.trim(),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: authController.isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Створити акаунт',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // Back to Login
              TextButton(
                onPressed: () => Get.back(),
                child: const Text(
                  'Вже є акаунт? Увійти',
                  style: TextStyle(color: Color(0xFF2E7D32), fontSize: 14),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
