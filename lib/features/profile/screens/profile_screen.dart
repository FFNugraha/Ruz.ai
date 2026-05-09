import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            // Profile Header
            const CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primaryLight,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              'Petani Cerdas',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'petani.cerdas@ruz.ai',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            
            // Stats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatItem('Ladang', '2', Icons.landscape, AppColors.success),
                  _buildStatItem('Scan', '124', Icons.document_scanner, AppColors.info),
                  _buildStatItem('Konsultasi', '45', Icons.chat, AppColors.warning),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Menu Items
            _buildMenuSection(
              title: 'Pengaturan Akun',
              items: [
                _buildMenuItem(Icons.person_outline, 'Edit Profil'),
                _buildMenuItem(Icons.security, 'Keamanan & Sandi'),
                _buildMenuItem(Icons.notifications_outlined, 'Notifikasi'),
              ],
            ),
            
            _buildMenuSection(
              title: 'Lainnya',
              items: [
                _buildMenuItem(Icons.help_outline, 'Bantuan & Dukungan'),
                _buildMenuItem(Icons.info_outline, 'Tentang ruz.ai'),
                _buildMenuItem(
                  Icons.logout, 
                  'Keluar', 
                  textColor: AppColors.danger, 
                  iconColor: AppColors.danger,
                  hideArrow: true,
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildMenuSection({required String title, required List<Widget> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        ),
        ...items,
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildMenuItem(
    IconData icon, 
    String title, {
    Color? textColor, 
    Color? iconColor,
    bool hideArrow = false,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      leading: Icon(icon, color: iconColor ?? Colors.grey[700]),
      title: Text(
        title,
        style: TextStyle(color: textColor ?? Colors.black87),
      ),
      trailing: hideArrow ? null : const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () {},
    );
  }
}
