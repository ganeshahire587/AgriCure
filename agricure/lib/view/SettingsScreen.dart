import 'package:agricure/controller/authCntroller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isSyncEnabled = true;
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE8F5E9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1B5E20)),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Налаштування',
          style: TextStyle(
            color: Color(0xFF1B5E20),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header — populated from Firebase
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: authController.userPhotoUrl.isNotEmpty
                      ? NetworkImage(authController.userPhotoUrl)
                      : const NetworkImage(
                              'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?q=80&w=200&auto=format&fit=crop',
                            )
                            as ImageProvider,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(
                      () => Text(
                        authController.userName.isNotEmpty
                            ? '@${authController.userName}'
                            : authController.userEmail,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Load account type from Firestore
                    FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc(authController.userId)
                          .get(),
                      builder: (context, snapshot) {
                        String type = 'Basic';
                        if (snapshot.hasData && snapshot.data!.exists) {
                          type =
                              (snapshot.data!.data()
                                  as Map<String, dynamic>)['accountType'] ??
                              'Basic';
                        }
                        return Text(
                          'Тип облікового запису: $type',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.green[800],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 40),

            const Row(
              children: [
                Icon(Icons.settings, color: Color(0xFF2E7D32)),
                SizedBox(width: 8),
                Text(
                  'Налаштування',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Settings List
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  _buildSettingsTile(
                    icon: Icons.language,
                    title: 'Мова додатку',
                    trailing: const Text(
                      'UA',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _buildSettingsTile(
                    icon: Icons.notifications_none,
                    title: 'Нагадування',
                    trailing: const Icon(Icons.more_vert, color: Colors.grey),
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _buildSettingsTile(
                    icon: Icons.sync,
                    title: 'Синхронізація',
                    trailing: Switch(
                      value: isSyncEnabled,
                      activeColor: Colors.white,
                      activeTrackColor: const Color(0xFF2E7D32),
                      onChanged: (value) =>
                          setState(() => isSyncEnabled = value),
                    ),
                    onTap: () => setState(() => isSyncEnabled = !isSyncEnabled),
                  ),
                  _buildDivider(),
                  _buildSettingsTile(
                    icon: Icons.help_outline,
                    title: 'Допомога',
                    trailing: const Icon(Icons.more_vert, color: Colors.grey),
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _buildSettingsTile(
                    icon: Icons.info_outline,
                    title: 'Про додаток',
                    trailing: const Icon(Icons.more_vert, color: Colors.grey),
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'AgriCure',
                        applicationVersion: '1.0.0',
                        applicationLegalese:
                            '© 2024 AgriCure. Всі права захищені.',
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Logout / Destructive Actions
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  _buildSettingsTile(
                    icon: Icons.logout,
                    title: 'Вийти',
                    titleColor: Colors.orange[800],
                    iconColor: Colors.orange[800],
                    trailing: const SizedBox.shrink(),
                    onTap: () => _confirmLogout(context),
                  ),
                  _buildDivider(),
                  _buildSettingsTile(
                    icon: Icons.delete_outline,
                    title: 'Видалити профіль',
                    titleColor: Colors.red[700],
                    iconColor: Colors.red[700],
                    trailing: const Icon(Icons.more_vert, color: Colors.grey),
                    onTap: () => Get.toNamed('/delete-profile'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Вийти з акаунту?',
          style: TextStyle(color: Color(0xFF1B5E20)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Скасувати'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              authController.signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[800],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Вийти', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required Widget trailing,
    required VoidCallback onTap,
    Color? titleColor,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 20,
          color: iconColor ?? const Color(0xFF2E7D32),
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: titleColor ?? const Color(0xFF1B5E20),
        ),
      ),
      trailing: trailing,
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      indent: 60,
      endIndent: 20,
      color: Color(0xFFF0F0F0),
    );
  }
}
