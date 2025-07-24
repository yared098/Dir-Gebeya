import 'package:dirgebeya/Provider/profile_provider.dart';
import 'package:dirgebeya/Provider/theme_provider.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoggingOut = false;

  Future<void> _handleLogout(BuildContext context) async {
    setState(() => _isLoggingOut = true);

    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );
    final success = await profileProvider.logout();

    if (success) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (!mounted) return;
      setState(() => _isLoggingOut = false);
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      // Navigator.pushReplacementNamed(context, '/login');
      if (!mounted) return;
      setState(() => _isLoggingOut = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(profileProvider.error ?? "Logout failed")),
      );
    }
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    Widget? trailing,
  }) {
    return Card(
      elevation: 1,
      color: Theme.of(context).cardColor,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text(
              "Settings",
              style: TextStyle(
                color: Theme.of(context).appBarTheme.foregroundColor,
              ),
            ),
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
            centerTitle: true,
            elevation: 0,
            iconTheme: Theme.of(context).iconTheme,
          ),

          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSettingTile(
                icon: Icons.person_outline,
                title: "Account Info",
              ),
              _buildSettingTile(
                icon: Icons.notifications_none,
                title: "Notifications",
              ),
              // Card(
              //   elevation: 1,
              //   color: Theme.of(context).cardColor,
              //   shadowColor: Colors.black.withOpacity(0.05),
              //   shape: RoundedRectangleBorder(
              //     borderRadius: BorderRadius.circular(12),
              //   ),
              //   child: ListTile(
              //     leading: const Icon(
              //       Icons.dark_mode_outlined,
              //       color: Colors.blue,
              //     ),
              //     title: const Text(
              //       "Dark Mode",
              //       style: TextStyle(fontWeight: FontWeight.w600),
              //     ),
              //     trailing: Switch(
              //       value: themeProvider.isDarkMode,
              //       onChanged: themeProvider.toggleTheme,
              //     ),
              //   ),
              // ),
              
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isLoggingOut ? null : () => _handleLogout(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
              ),
            ],
          ),
        ),
        if (_isLoggingOut)
          Container(
            color: Colors.black54,
            alignment: Alignment.center,
            child: const CircularProgressIndicator(color: Colors.white),
          ),
      ],
    );
  }
}
