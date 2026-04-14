import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({Key? key}) : super(key: key);

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  String selectedLighting = 'півтінь';
  String selectedDifficulty = 'простий';
  String selectedSize = '20-100 см';
  bool isPetSafe = false;
  bool isAirPurifier = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: TextButton(
          onPressed: () {
            setState(() {
              selectedLighting = '';
              selectedDifficulty = '';
              selectedSize = '';
              isPetSafe = false;
              isAirPurifier = false;
            });
          },
          child: const Text(
            'Очистити',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ),
        leadingWidth: 80,
        title: const Text(
          'Фільтр',
          style: TextStyle(
            color: Color(0xFF1B5E20),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Color(0xFF1B5E20)),
            onPressed: () => Get.back(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(Icons.wb_sunny_outlined, 'Освітлення'),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildChoiceChip(
                  'тінь',
                  selectedLighting,
                  (val) => setState(() => selectedLighting = val),
                ),
                const SizedBox(width: 10),
                _buildChoiceChip(
                  'півтінь',
                  selectedLighting,
                  (val) => setState(() => selectedLighting = val),
                ),
                const SizedBox(width: 10),
                _buildChoiceChip(
                  'сонце',
                  selectedLighting,
                  (val) => setState(() => selectedLighting = val),
                ),
              ],
            ),
            const SizedBox(height: 30),

            _buildSectionHeader(Icons.eco_outlined, 'Складність догляду'),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildChoiceChip(
                  'простий',
                  selectedDifficulty,
                  (val) => setState(() => selectedDifficulty = val),
                ),
                const SizedBox(width: 10),
                _buildChoiceChip(
                  'середній',
                  selectedDifficulty,
                  (val) => setState(() => selectedDifficulty = val),
                ),
                const SizedBox(width: 10),
                _buildChoiceChip(
                  'складний',
                  selectedDifficulty,
                  (val) => setState(() => selectedDifficulty = val),
                ),
              ],
            ),
            const SizedBox(height: 30),

            _buildSectionHeader(Icons.height, 'Розмір рослини'),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildChoiceChip(
                  '< 20 см',
                  selectedSize,
                  (val) => setState(() => selectedSize = val),
                ),
                const SizedBox(width: 10),
                _buildChoiceChip(
                  '20-100 см',
                  selectedSize,
                  (val) => setState(() => selectedSize = val),
                ),
                const SizedBox(width: 10),
                _buildChoiceChip(
                  '> 100 см',
                  selectedSize,
                  (val) => setState(() => selectedSize = val),
                ),
              ],
            ),
            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionHeader(
                  Icons.pets,
                  'Безпечні для тварин',
                  padding: false,
                ),
                Switch(
                  value: isPetSafe,
                  activeColor: Colors.white,
                  activeTrackColor: const Color(0xFF2E7D32),
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: Colors.grey[300],
                  onChanged: (value) => setState(() => isPetSafe = value),
                ),
              ],
            ),
            const Divider(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionHeader(
                  Icons.air,
                  'Очисники повітря',
                  padding: false,
                ),
                Switch(
                  value: isAirPurifier,
                  activeColor: Colors.white,
                  activeTrackColor: const Color(0xFF2E7D32),
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: Colors.grey[300],
                  onChanged: (value) => setState(() => isAirPurifier = value),
                ),
              ],
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Return filters to the previous screen
                  Get.back(
                    result: {
                      'lighting': selectedLighting,
                      'difficulty': selectedDifficulty,
                      'size': selectedSize,
                      'petSafe': isPetSafe,
                      'airPurifier': isAirPurifier,
                    },
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
                child: const Text(
                  'Фільтрувати (210)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    IconData icon,
    String title, {
    bool padding = true,
  }) {
    return Padding(
      padding: padding ? const EdgeInsets.only(left: 4.0) : EdgeInsets.zero,
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF2E7D32)),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B5E20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceChip(
    String label,
    String groupValue,
    Function(String) onSelect,
  ) {
    bool isSelected = label == groupValue;
    return Expanded(
      child: GestureDetector(
        onTap: () => onSelect(label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2E7D32) : Colors.white,
            border: Border.all(
              color: isSelected ? const Color(0xFF2E7D32) : Colors.grey[300]!,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
