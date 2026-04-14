import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PlantDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> plantData;

  const PlantDetailsScreen({Key? key, this.plantData = const {}})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    // Merge route arguments with constructor args
    final args = (Get.arguments as Map<String, dynamic>? ?? {})
      ..addAll(plantData);

    final name = args['name'] ?? 'Пеперомія Пілея Лайм';
    final latinName = args['latinName'] ?? 'Peperomia Pilea Lime';
    final imageUrl =
        args['imageUrl'] ??
        'https://images.unsplash.com/photo-1643477145749-307be5eafec3?q=80&w=800&auto=format&fit=crop';
    final description =
        args['description'] ??
        'Напрочуд гарна екзотична квітка, яка при цьому надзвичайно невибаглива. '
            'Яскраве та незвичайно забарвлене листя порадує будь-якого любителя рослин.\n\n'
            'Так як у природі пеперомія Россо росте на ділянках, затінених від сонця, '
            'необхідно забезпечити зростання рослині розсіяне освітлення.\n\n'
            'Оптимальним варіантом вважається підвіконня розташоване в західній та '
            'східній частині будинку.';
    final List diseases =
        args['diseases'] ?? ['Антракноз', 'Сіра гниль', 'Чорна ніжка'];
    final tempRange = args['tempRange'] ?? '20-30°C';
    final wateringDays = args['wateringDays'] ?? 10;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Background Plant Image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenHeight * 0.45,
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFFE8F5E9),
                child: const Icon(
                  Icons.eco,
                  size: 80,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ),
          ),

          // 2. Floating App Bar Icons
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.8),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF1B5E20),
                      ),
                      onPressed: () => Get.back(),
                    ),
                  ),
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white.withOpacity(0.8),
                        child: IconButton(
                          icon: const Icon(
                            Icons.share_outlined,
                            color: Color(0xFF1B5E20),
                          ),
                          onPressed: () {},
                        ),
                      ),
                      const SizedBox(width: 12),
                      CircleAvatar(
                        backgroundColor: Colors.white.withOpacity(0.8),
                        child: IconButton(
                          icon: const Icon(
                            Icons.grid_view,
                            color: Color(0xFF1B5E20),
                          ),
                          onPressed: () => Get.toNamed('/garden'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 3. Scrollable Detail Sheet
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: screenHeight * 0.62,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      latinName,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Care Requirements
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildCareStat(
                          Icons.thermostat,
                          tempRange,
                          Colors.orange,
                        ),
                        _buildCareStat(
                          Icons.water_drop,
                          'Кожні\n$wateringDays днів',
                          Colors.lightBlue,
                        ),
                        _buildCareStat(
                          Icons.wb_sunny,
                          'Дуже\nсвітло',
                          Colors.amber,
                        ),
                        _buildCareStat(
                          Icons.spa,
                          'Комплексне',
                          Colors.purple[300]!,
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Description
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Diseases Section
                    const Text(
                      'Хвороби',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: diseases
                            .map((d) => _buildDiseaseChip(d.toString()))
                            .toList(),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Add to Garden button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => Get.toNamed('/garden'),
                        icon: const Icon(Icons.eco, color: Colors.white),
                        label: const Text(
                          'Перейти до саду',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCareStat(IconData icon, String text, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[800],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDiseaseChip(String label) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.grey[700],
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
