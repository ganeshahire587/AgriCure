import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DiagnosisResultScreen extends StatelessWidget {
  final String scannedImageUrl;
  final String diseaseName;

  const DiagnosisResultScreen({
    Key? key,
    this.scannedImageUrl =
        'https://images.unsplash.com/photo-1611314445806-696c1410d52b?q=80&w=800&auto=format&fit=crop',
    this.diseaseName = 'Антракноз',
  }) : super(key: key);

  // Save diagnosis to Firestore
  Future<void> _saveDiagnosis() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      await FirebaseFirestore.instance.collection('diagnoses').add({
        'userId': uid,
        'imageUrl': scannedImageUrl,
        'diseaseName': diseaseName,
        'createdAt': FieldValue.serverTimestamp(),
      });
      Get.snackbar(
        'Збережено',
        'Діагноз збережено в історії',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Помилка',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

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
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Color(0xFF1B5E20)),
            onPressed: () => Get.offAllNamed('/garden'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // Top Section
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  flex: 3,
                  child: Text(
                    'В мене погані\nновини, здається\nваша рослина\nзахворіла',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1B5E20),
                      height: 1.4,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 80,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(
                          'https://cdn-icons-png.flaticon.com/512/5895/5895996.png',
                        ),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Diagnosis Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFC8E6C9), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Схоже це',
                    style: TextStyle(fontSize: 14, color: Color(0xFF2E7D32)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    diseaseName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Scanned Image
            Expanded(
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: scannedImageUrl.isNotEmpty
                      ? Image.network(
                          scannedImageUrl,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: const Color(0xFFE8F5E9),
                            child: const Icon(
                              Icons.image_not_supported,
                              size: 60,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : Container(
                          color: const Color(0xFFE8F5E9),
                          child: const Icon(
                            Icons.eco,
                            size: 80,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Save diagnosis button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _saveDiagnosis,
                icon: const Icon(Icons.save_outlined, color: Color(0xFF2E7D32)),
                label: const Text(
                  'Зберегти діагноз',
                  style: TextStyle(
                    color: Color(0xFF2E7D32),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  side: const BorderSide(color: Color(0xFF2E7D32), width: 1.5),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // More Details button → Plant Details
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Get.toNamed(
                  '/plant-details',
                  arguments: {'diseaseName': diseaseName},
                ),
                icon: const Icon(Icons.info_outline, color: Colors.white),
                label: const Text(
                  'Детальніше',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
