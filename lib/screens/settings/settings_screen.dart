import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/theme_service.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    final authService = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          _buildSectionHeader(context, 'Giao diện'),
          ListTile(
            leading: Icon(themeService.isDarkMode ? Icons.dark_mode : Icons.light_mode),
            leading: Icon(
              themeService.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            ),
            title: const Text('Chế độ tối'),
            trailing: Switch(
              value: themeService.isDarkMode,
              onChanged: (value) => themeService.toggleTheme(),
            ),
          ),
          const Divider(),
          _buildSectionHeader(context, 'Tài khoản'),
          FutureBuilder<String?>(
            future: authService.getUsername(),
            builder: (context, snapshot) {
              return ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Tên người dùng'),
                subtitle: Text(snapshot.data ?? 'Admin'),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
            onTap: () async {
              await authService.logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
          const Divider(),
          _buildSectionHeader(context, 'Ứng dụng'),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: const Text('Phiên bản'),
            trailing: Text('1.0.0'),
          ),
          const ListTile(
            leading: Icon(Icons.description_outlined),
            title: const Text('Điều khoản & Chính sách'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
