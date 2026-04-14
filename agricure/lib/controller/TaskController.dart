import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class TaskController extends GetxController {
  static TaskController get instance => Get.find();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _userId = FirebaseAuth.instance.currentUser?.uid ?? '';

  RxList<Map<String, dynamic>> tasks = <Map<String, dynamic>>[].obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTasks();
  }

  // ── Fetch all tasks for current user ─────────────────────────────────────
  void fetchTasks() {
    _firestore
        .collection('tasks')
        .where('userId', isEqualTo: _userId)
        .orderBy('dueDate')
        .snapshots()
        .listen((snapshot) {
          tasks.value = snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList();
        });
  }

  // ── Tasks for a specific date ─────────────────────────────────────────────
  List<Map<String, dynamic>> tasksForDate(DateTime date) {
    return tasks.where((t) {
      final due = (t['dueDate'] as Timestamp?)?.toDate();
      if (due == null) return false;
      return due.year == date.year &&
          due.month == date.month &&
          due.day == date.day;
    }).toList();
  }

  List<Map<String, dynamic>> get completedTasks =>
      tasks.where((t) => t['isCompleted'] == true).toList();

  List<Map<String, dynamic>> get pendingTasks =>
      tasks.where((t) => t['isCompleted'] != true).toList();

  // ── Add task ──────────────────────────────────────────────────────────────
  Future<void> addTask({
    required String plantName,
    required String taskDesc,
    required String taskType, // 'water', 'fertilize', 'spray'
    required DateTime dueDate,
  }) async {
    try {
      await _firestore.collection('tasks').add({
        'userId': _userId,
        'plantName': plantName,
        'taskDesc': taskDesc,
        'taskType': taskType,
        'dueDate': Timestamp.fromDate(dueDate),
        'isCompleted': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      Get.snackbar(
        'Помилка',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ── Toggle task completion ────────────────────────────────────────────────
  Future<void> toggleTask(String taskId, bool currentValue) async {
    try {
      await _firestore.collection('tasks').doc(taskId).update({
        'isCompleted': !currentValue,
        'completedAt': !currentValue ? FieldValue.serverTimestamp() : null,
      });
    } catch (e) {
      Get.snackbar(
        'Помилка',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ── Delete task ───────────────────────────────────────────────────────────
  Future<void> deleteTask(String taskId) async {
    try {
      await _firestore.collection('tasks').doc(taskId).delete();
    } catch (e) {
      Get.snackbar(
        'Помилка',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
