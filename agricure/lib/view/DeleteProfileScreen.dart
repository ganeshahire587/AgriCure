import 'package:agricure/controller/authCntroller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeleteProfileScreen extends StatefulWidget {
  const DeleteProfileScreen({Key? key}) : super(key: key);

  @override
  State<DeleteProfileScreen> createState() => _DeleteProfileScreenState();
}

class _DeleteProfileScreenState extends State<DeleteProfileScreen> {
  String? selectedReason;
  final AuthController authController = Get.find<AuthController>();

  void _showProfileDeletedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: const Color(0xFFE8F5E9),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () => Get.offAllNamed('/login'),
                    child: const Icon(Icons.close, color: Colors.grey),
                  ),
                ),
                const Text(
                  'Профіль видалено',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  height: 120,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                        'https://cdn-icons-png.flaticon.com/512/6552/6552966.png',
                      ),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Get.offAllNamed('/login'),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      side: BorderSide(color: Colors.grey[300]!),
                    ),
                    child: const Text(
                      'Повернутися',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleDelete() async {
    if (selectedReason == null) {
      Get.snackbar(
        'Вкажіть причину',
        'Оберіть причину видалення',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Confirm dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Підтвердження',
          style: TextStyle(color: Color(0xFF1B5E20)),
        ),
        content: const Text('Ви впевнені? Цю дію не можна скасувати.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Скасувати'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
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

    if (confirmed != true) return;

    // Delete via Firebase
    final success = await authController.deleteAccount();
    if (success) {
      _showProfileDeletedDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1B5E20)),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Видалити профіль',
          style: TextStyle(
            color: Color(0xFF1B5E20),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ви дійсно хочете видалити Ваш профіль?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B5E20),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Всі ваші збережені рослини, а також загальний сад і історія догляду зникнуть назавжди після 15 днів.',
                style: TextStyle(color: Colors.red[800], height: 1.4),
              ),
            ),
            const SizedBox(height: 40),

            _buildRadioOption('Занадто складний додаток у використанні'),
            const SizedBox(height: 10),
            _buildRadioOption('Мій варіант'),

            const Spacer(),

            // Cancel button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Я зміню свою думку',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Confirm delete — calls Firebase
            Center(
              child: Obx(
                () => authController.isLoading.value
                    ? const CircularProgressIndicator(color: Color(0xFF2E7D32))
                    : TextButton(
                        onPressed: _handleDelete,
                        child: const Text(
                          'Так, я хочу видалити свій профіль',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                            decoration: TextDecoration.underline,
                          ),
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

  Widget _buildRadioOption(String title) {
    return GestureDetector(
      onTap: () => setState(() => selectedReason = title),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selectedReason == title
                ? const Color(0xFF2E7D32)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selectedReason == title
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: selectedReason == title
                  ? const Color(0xFF2E7D32)
                  : Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: selectedReason == title
                      ? const Color(0xFF1B5E20)
                      : Colors.grey[700],
                  fontWeight: selectedReason == title
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
