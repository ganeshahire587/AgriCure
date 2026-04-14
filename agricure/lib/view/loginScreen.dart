import 'package:agricure/controller/authCntroller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({Key? key}) : super(key: key);

  final AuthController authController = Get.find<AuthController>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),

              // App Logo / Header Image
              Center(
                child: Container(
                  height: 150,
                  width: 150,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage(
                        'https://images.unsplash.com/photo-1416879598555-220f8c27e362?q=80&w=400&auto=format&fit=crop',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'Home\nJungle',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(color: Colors.black45, blurRadius: 10),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 50),

              // Email Input
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Email',
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

              // Password Input
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Password',
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

              // Login Button with loading state
              Obx(
                () => ElevatedButton(
                  onPressed: authController.isLoading.value
                      ? null
                      : () {
                          authController.login(
                            emailController.text.trim(),
                            passwordController.text.trim(),
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
                          'Увійти',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // Register Button → navigates to register screen
              TextButton(
                onPressed: () => Get.toNamed('/register'),
                child: const Text(
                  'Зареєструватися',
                  style: TextStyle(color: Color(0xFF2E7D32), fontSize: 16),
                ),
              ),

              const SizedBox(height: 30),
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('Або', style: TextStyle(color: Colors.grey)),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 30),

              // Facebook (placeholder — not yet integrated)
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.facebook, color: Colors.blue),
                label: const Text(
                  'Продовжити з Facebook',
                  style: TextStyle(color: Colors.black87),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  side: const BorderSide(color: Colors.grey, width: 0.5),
                ),
              ),

              const SizedBox(height: 16),

              // Google Sign-In
              Obx(
                () => OutlinedButton.icon(
                  onPressed: authController.isLoading.value
                      ? null
                      : () => authController.signInWithGoogle(),
                  icon: const Icon(
                    Icons.g_mobiledata,
                    color: Colors.red,
                    size: 32,
                  ),
                  label: const Text(
                    'Продовжити з Google',
                    style: TextStyle(color: Colors.black87),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    side: const BorderSide(color: Colors.grey, width: 0.5),
                  ),
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
