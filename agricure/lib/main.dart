import 'package:agricure/controller/authCntroller.dart';
import 'package:agricure/view/splash.dart';
import 'package:agricure/view/loginScreen.dart';
import 'package:agricure/view/MyGardenScreen.dart';
import 'package:agricure/view/calendarTaskScreen.dart';
import 'package:agricure/view/cameraScreen.dart';
import 'package:agricure/view/DiagnosisResultScreen.dart';
import 'package:agricure/view/PlantDetailsScreen.dart';
import 'package:agricure/view/FilterScreen.dart';
import 'package:agricure/view/SettingsScreen.dart';
import 'package:agricure/view/DeleteProfileScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'AgriCure',
      debugShowCheckedModeBanner: false,
      initialBinding: BindingsBuilder(() {
        Get.put(AuthController(), permanent: true);
      }),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const SplashScreen()),
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/garden', page: () => const MyGardenScreen()),
        GetPage(name: '/calendar', page: () => const CalendarTaskScreen()),
        GetPage(name: '/camera', page: () => const CameraScannerScreen()),
        GetPage(
          name: '/diagnosis',
          page: () {
            final args = Get.arguments as Map<String, dynamic>? ?? {};
            return DiagnosisResultScreen(
              scannedImageUrl: args['imageUrl'] ?? '',
              diseaseName: args['diseaseName'] ?? 'Unknown',
            );
          },
        ),
        GetPage(
          name: '/plant-details',
          page: () {
            final args = Get.arguments as Map<String, dynamic>? ?? {};
            return PlantDetailsScreen(plantData: args);
          },
        ),
        GetPage(name: '/filter', page: () => const FilterScreen()),
        GetPage(name: '/settings', page: () => const SettingsScreen()),
        GetPage(
          name: '/delete-profile',
          page: () => const DeleteProfileScreen(),
        ),
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),
        useMaterial3: true,
      ),
    );
  }
}
