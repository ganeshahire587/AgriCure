import 'package:agricure/controller/gardenController.dart';
import 'package:agricure/controller/authCntroller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyGardenScreen extends StatelessWidget {
  const MyGardenScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Ensure controller is available
    final gardenController = Get.put(GardenController());
    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE8F5E9),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Мій сад',
              style: TextStyle(
                color: Color(0xFF1B5E20),
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            Obx(
              () => Text(
                authController.userName.isNotEmpty
                    ? '@${authController.userName}'
                    : authController.userEmail,
                style: const TextStyle(fontSize: 12, color: Color(0xFF2E7D32)),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Color(0xFF1B5E20)),
            onPressed: () => Get.toNamed('/settings'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats row
          Obx(() {
            final plants = gardenController.plants;
            final needWater = gardenController.plantsNeedingWater;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _buildStatCard(
                    '${plants.length}',
                    'Рослин',
                    Icons.eco,
                    const Color(0xFF2E7D32),
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    '${needWater.length}',
                    'Полити',
                    Icons.water_drop,
                    Colors.blue,
                  ),
                ],
              ),
            );
          }),

          // Plant list
          Expanded(
            child: Obx(() {
              if (gardenController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (gardenController.plants.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.eco_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Ваш сад порожній',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Додайте першу рослину',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () =>
                            _showAddPlantDialog(context, gardenController),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Додати рослину',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: gardenController.plants.length,
                itemBuilder: (context, index) {
                  final plant = gardenController.plants[index];
                  return _buildPlantCard(plant, gardenController, context);
                },
              );
            }),
          ),
        ],
      ),

      // Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        selectedItemColor: const Color(0xFF2E7D32),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 0) Get.toNamed('/calendar');
          if (index == 1) Get.toNamed('/camera');
          if (index == 3) Get.toNamed('/filter');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline, size: 32),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.eco_outlined),
            label: 'Garden',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'Menu'),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2E7D32),
        onPressed: () => _showAddPlantDialog(context, gardenController),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStatCard(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20),
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlantCard(
    Map<String, dynamic> plant,
    GardenController controller,
    BuildContext context,
  ) {
    final nextWatering = (plant['nextWatering'] as Timestamp?)?.toDate();
    final daysUntilWater = nextWatering != null
        ? nextWatering.difference(DateTime.now()).inDays
        : null;

    return GestureDetector(
      onTap: () => Get.toNamed('/plant-details', arguments: plant),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Plant image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child:
                  plant['imageUrl'] != null &&
                      plant['imageUrl'].toString().isNotEmpty
                  ? Image.network(
                      plant['imageUrl'],
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 60,
                      height: 60,
                      color: const Color(0xFFE8F5E9),
                      child: const Icon(
                        Icons.eco,
                        color: Color(0xFF2E7D32),
                        size: 30,
                      ),
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plant['name'] ?? 'Рослина',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B5E20),
                      fontSize: 15,
                    ),
                  ),
                  if (plant['location'] != null)
                    Text(
                      plant['location'],
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  if (daysUntilWater != null)
                    Row(
                      children: [
                        Icon(
                          Icons.water_drop,
                          size: 14,
                          color: daysUntilWater <= 0 ? Colors.red : Colors.blue,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          daysUntilWater <= 0
                              ? 'Потребує поливу!'
                              : 'Полити через $daysUntilWater дн.',
                          style: TextStyle(
                            fontSize: 12,
                            color: daysUntilWater <= 0
                                ? Colors.red
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            // Water button
            IconButton(
              icon: const Icon(
                Icons.water_drop_outlined,
                color: Color(0xFF2E7D32),
              ),
              onPressed: () => controller.waterPlant(
                plant['id'],
                plant['wateringDays'] ?? 7,
              ),
              tooltip: 'Полити',
            ),
            // Delete button
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.grey),
              onPressed: () => _confirmDelete(context, plant['id'], controller),
              tooltip: 'Видалити',
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    String plantId,
    GardenController controller,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Видалити рослину?',
          style: TextStyle(color: Color(0xFF1B5E20)),
        ),
        content: const Text('Це незворотня дія'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Скасувати'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.deletePlant(plantId);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'Видалити',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddPlantDialog(BuildContext context, GardenController controller) {
    final nameCtrl = TextEditingController();
    final latinCtrl = TextEditingController();
    final locationCtrl = TextEditingController();
    final imageUrlCtrl = TextEditingController();
    final wateringCtrl = TextEditingController(text: '7');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Додати рослину',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B5E20),
              ),
            ),
            const SizedBox(height: 16),
            _dialogField(nameCtrl, "Назва рослини", Icons.eco_outlined),
            const SizedBox(height: 12),
            _dialogField(latinCtrl, "Латинська назва", Icons.science_outlined),
            const SizedBox(height: 12),
            _dialogField(
              locationCtrl,
              "Кімната/місце",
              Icons.location_on_outlined,
            ),
            const SizedBox(height: 12),
            _dialogField(
              imageUrlCtrl,
              "URL фото (необов'язково)",
              Icons.image_outlined,
            ),
            const SizedBox(height: 12),
            _dialogField(
              wateringCtrl,
              "Полив кожні N днів",
              Icons.water_drop,
              inputType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                controller.addPlant(
                  name: nameCtrl.text.trim(),
                  latinName: latinCtrl.text.trim(),
                  location: locationCtrl.text.trim(),
                  imageUrl: imageUrlCtrl.text.trim(),
                  wateringDays: int.tryParse(wateringCtrl.text) ?? 7,
                );
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Додати',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dialogField(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    TextInputType inputType = TextInputType.text,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: inputType,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF2E7D32)),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}
