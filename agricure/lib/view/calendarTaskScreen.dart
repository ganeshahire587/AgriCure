import 'package:agricure/controller/TaskController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // ← FIX: needed for 'uk' locale

class CalendarTaskScreen extends StatefulWidget {
  const CalendarTaskScreen({Key? key}) : super(key: key);

  @override
  State<CalendarTaskScreen> createState() => _CalendarTaskScreenState();
}

class _CalendarTaskScreenState extends State<CalendarTaskScreen> {
  int selectedDateIndex = DateTime.now().weekday - 1; // 0=Mon
  late DateTime _weekStart;
  final TaskController taskController = Get.put(TaskController());

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('uk', null); // ← FIX: initialize Ukrainian locale
    final now = DateTime.now();
    _weekStart = now.subtract(Duration(days: now.weekday - 1));
  }

  DateTime get selectedDate =>
      _weekStart.add(Duration(days: selectedDateIndex));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Text(
              DateFormat('MMMM yyyy', 'uk').format(_weekStart),
              style: const TextStyle(
                color: Color(0xFF1B5E20),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: Color(0xFF1B5E20)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: Color(0xFF1B5E20)),
            onPressed: () => Get.toNamed('/settings'),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          _buildWeeklyCalendar(),
          const SizedBox(height: 24),

          // Tasks Section
          Expanded(
            child: Obx(() {
              final dayTasks = taskController.tasksForDate(selectedDate);
              final pending = dayTasks
                  .where((t) => t['isCompleted'] != true)
                  .toList();
              final completed = dayTasks
                  .where((t) => t['isCompleted'] == true)
                  .toList();

              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                children: [
                  const Text(
                    'Завдання',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (pending.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Text(
                        'Немає завдань на цей день',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),

                  ...pending.map(
                    (task) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildTaskTile(
                        icon: _taskIcon(task['taskType']),
                        iconBgColor: _taskBgColor(task['taskType']),
                        iconColor: _taskColor(task['taskType']),
                        plantName: task['plantName'] ?? '',
                        taskDesc: task['taskDesc'] ?? '',
                        isCompleted: false,
                        onToggle: () =>
                            taskController.toggleTask(task['id'], false),
                      ),
                    ),
                  ),

                  if (completed.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    const Row(
                      children: [
                        Icon(Icons.check, color: Color(0xFF2E7D32)),
                        SizedBox(width: 8),
                        Text(
                          'Виконані завдання',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B5E20),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...completed.map(
                      (task) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildTaskTile(
                          icon: _taskIcon(task['taskType']),
                          iconBgColor: Colors.transparent,
                          iconColor: Colors.grey,
                          plantName: task['plantName'] ?? '',
                          taskDesc: task['taskDesc'] ?? '',
                          isCompleted: true,
                          onToggle: () =>
                              taskController.toggleTask(task['id'], true),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 80),
                ],
              );
            }),
          ),
        ],
      ),

      // Add Task FAB
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2E7D32),
        onPressed: () => _showAddTaskDialog(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: const Color(0xFF2E7D32),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 1) Get.toNamed('/camera');
          if (index == 2) Get.toNamed('/garden');
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
    );
  }

  // ── Weekly Calendar Strip ─────────────────────────────────────────────────
  Widget _buildWeeklyCalendar() {
    const List<String> dayNames = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Нд'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(7, (index) {
          bool isSelected = selectedDateIndex == index;
          final date = _weekStart.add(Duration(days: index));
          return GestureDetector(
            onTap: () => setState(() => selectedDateIndex = index),
            child: Column(
              children: [
                Text(
                  dayNames[index],
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.grey,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF2E7D32)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${date.day}',
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                CircleAvatar(
                  radius: 3,
                  backgroundColor: isSelected
                      ? const Color(0xFF2E7D32)
                      : Colors.transparent,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ── Task Tile ─────────────────────────────────────────────────────────────
  Widget _buildTaskTile({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String plantName,
    required String taskDesc,
    required bool isCompleted,
    required VoidCallback onToggle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCompleted ? Colors.grey[100] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCompleted ? Colors.transparent : const Color(0xFFE0E0E0),
        ),
        boxShadow: isCompleted
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plantName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isCompleted ? Colors.grey : const Color(0xFF1B5E20),
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  taskDesc,
                  style: TextStyle(
                    fontSize: 14,
                    color: isCompleted ? Colors.grey : Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onToggle,
            child: Icon(
              isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isCompleted ? Colors.grey : const Color(0xFF2E7D32),
            ),
          ),
        ],
      ),
    );
  }

  // ── Add Task Dialog ───────────────────────────────────────────────────────
  void _showAddTaskDialog(BuildContext context) {
    final plantCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String taskType = 'water';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setInnerState) => Padding(
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
                'Додати завдання',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: plantCtrl,
                decoration: InputDecoration(
                  hintText: 'Назва рослини',
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
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                decoration: InputDecoration(
                  hintText: 'Опис завдання',
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
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _typeChip(
                    'water',
                    'Полив',
                    taskType,
                    (v) => setInnerState(() => taskType = v),
                  ),
                  const SizedBox(width: 8),
                  _typeChip(
                    'spray',
                    'Зволоження',
                    taskType,
                    (v) => setInnerState(() => taskType = v),
                  ),
                  const SizedBox(width: 8),
                  _typeChip(
                    'fertilize',
                    'Добриво',
                    taskType,
                    (v) => setInnerState(() => taskType = v),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (plantCtrl.text.isEmpty) return;
                  taskController.addTask(
                    plantName: plantCtrl.text.trim(),
                    taskDesc: descCtrl.text.trim(),
                    taskType: taskType,
                    dueDate: selectedDate,
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
                  'Зберегти',
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
      ),
    );
  }

  Widget _typeChip(
    String value,
    String label,
    String groupValue,
    Function(String) onTap,
  ) {
    final selected = value == groupValue;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF2E7D32) : Colors.grey[100],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.grey,
                fontSize: 12,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Helper: icons & colors per task type ─────────────────────────────────
  IconData _taskIcon(String? type) {
    switch (type) {
      case 'spray':
        return Icons.sanitizer;
      case 'fertilize':
        return Icons.spa;
      default:
        return Icons.water_drop;
    }
  }

  Color _taskBgColor(String? type) {
    switch (type) {
      case 'spray':
        return Colors.grey[200]!;
      case 'fertilize':
        return Colors.purple[50]!;
      default:
        return Colors.blue[100]!;
    }
  }

  Color _taskColor(String? type) {
    switch (type) {
      case 'spray':
        return Colors.grey[600]!;
      case 'fertilize':
        return Colors.purple;
      default:
        return Colors.blue;
    }
  }
}
