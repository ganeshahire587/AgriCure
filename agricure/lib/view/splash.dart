import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    // Wait 3 seconds for splash, then check auth
    await Future.delayed(const Duration(seconds: 3));

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Get.offAllNamed('/garden');
    } else {
      Get.offAllNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            'https://images.unsplash.com/photo-1518531933037-91b2f5f229cc?q=80&w=800&auto=format&fit=crop',
            fit: BoxFit.cover,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.6),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 32.0, top: 120.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Home',
                  style: TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  'Jungle',
                  style: TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
          // Loading indicator at bottom
          const Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
