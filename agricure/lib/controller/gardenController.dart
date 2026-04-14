import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class GardenController extends GetxController {
  static GardenController get instance => Get.find();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _userId = FirebaseAuth.instance.currentUser?.uid ?? '';

  RxList<Map<String, dynamic>> plants = <Map<String, dynamic>>[].obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPlants();
  }

  // ── Fetch all plants for this user ────────────────────────────────────────
  void fetchPlants() {
    _firestore
        .collection('plants')
        .where('userId', isEqualTo: _userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
          plants.value = snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList();
        });
  }

  // ── Add plant ─────────────────────────────────────────────────────────────
  Future<void> addPlant({
    required String name,
    required String latinName,
    required String imageUrl,
    required String location,
    int wateringDays = 7,
  }) async {
    try {
      isLoading.value = true;
      await _firestore.collection('plants').add({
        'userId': _userId,
        'name': name,
        'latinName': latinName,
        'imageUrl': imageUrl,
        'location': location,
        'wateringDays': wateringDays,
        'lastWatered': null,
        'nextWatering': Timestamp.fromDate(
          DateTime.now().add(Duration(days: wateringDays)),
        ),
        'createdAt': FieldValue.serverTimestamp(),
      });
      Get.snackbar(
        'Успіх',
        'Рослину додано до саду',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Помилка',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ── Delete plant ──────────────────────────────────────────────────────────
  Future<void> deletePlant(String plantId) async {
    try {
      await _firestore.collection('plants').doc(plantId).delete();
      Get.snackbar(
        'Видалено',
        'Рослину видалено',
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

  // ── Water a plant (update lastWatered) ────────────────────────────────────
  Future<void> waterPlant(String plantId, int wateringDays) async {
    try {
      final now = DateTime.now();
      await _firestore.collection('plants').doc(plantId).update({
        'lastWatered': Timestamp.fromDate(now),
        'nextWatering': Timestamp.fromDate(
          now.add(Duration(days: wateringDays)),
        ),
      });
    } catch (e) {
      Get.snackbar(
        'Помилка',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ── Get plants needing water today ────────────────────────────────────────
  List<Map<String, dynamic>> get plantsNeedingWater {
    final now = DateTime.now();
    return plants.where((p) {
      final next = (p['nextWatering'] as Timestamp?)?.toDate();
      return next != null && next.isBefore(now.add(const Duration(days: 1)));
    }).toList();
  }
}
