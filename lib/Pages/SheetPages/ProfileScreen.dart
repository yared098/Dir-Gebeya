import 'package:dirgebeya/Provider/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  bool _isDarkMode = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<ProfileProvider>(context, listen: false).fetchProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        final user = profileProvider.userProfile;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black54),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'My Profile',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: profileProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : user == null
              ? Center(
                  child: Text(
                    profileProvider.error ?? "Failed to load profile",
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildProfileHeader(user),
                      const SizedBox(height: 24),
                      _buildStatsGrid(user),
                      const SizedBox(height: 24),
                      _buildDarkModeToggle(),
                      const SizedBox(height: 16),
                      _buildSettingsList(),
                      const SizedBox(height: 32),
                      _buildAppVersion(),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildProfileHeader(UserProfile user) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: const Color(0xFF1D4ED8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(right: -30, top: -20, child: Text("")),
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: const Color(0xFFE0E7FF),
                  child: user.avatar.isNotEmpty
                      ? ClipOval(
                          child: Image.network(
                            user.avatar,
                            fit: BoxFit.cover,
                            width: 56,
                            height: 56,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/image/logo.png', 
                                fit: BoxFit.cover,
                                width: 56,
                                height: 56,
                              );
                            },
                          ),
                        )
                      : Text(
                          user.firstName.isNotEmpty
                              ? user.firstName[0].toUpperCase()
                              : '',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1D4ED8),
                          ),
                        ),
                ),
              ),

              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${user.firstName} ${user.lastName}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.phone,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
              const Spacer(),
              const Icon(Icons.edit_outlined, color: Colors.white, size: 24),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(UserProfile user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatCard(
          icon: Icons.inventory_2_outlined,
          value: user.totalProducts.toString(),
          label: 'Products',
        ),
        _buildStatCard(
          icon: Icons.list_alt_outlined,
          value: user.totalOrders.toString(),
          label: 'Orders',
        ),
        _buildStatCard(
          icon: Icons.monetization_on_outlined,
          value: '\$ ${user.totalWalletBalance}',
          label: 'Withdrawable\nBalance',
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      width: MediaQuery.of(context).size.width / 3.8,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFFDBEAFE),
            child: Icon(icon, color: const Color(0xFF1D4ED8), size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildDarkModeToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.brightness_6_outlined, color: Colors.orange),
          const SizedBox(width: 12),
          const Text('Dark Mode', style: TextStyle(fontSize: 16)),
          const Spacer(),
          Switch(
            value: _isDarkMode,
            onChanged: (value) {
              setState(() => _isDarkMode = value);
            },
            activeColor: Colors.white,
            activeTrackColor: const Color(0xFF60A5FA),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey.shade300,
            thumbIcon: MaterialStateProperty.resolveWith<Icon?>((states) {
              if (states.contains(MaterialState.selected)) {
                return const Icon(Icons.wb_sunny, color: Colors.orange);
              }
              return const Icon(Icons.nightlight_round, color: Colors.grey);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildSettingsItem(
            context: context,
            icon: Icons.settings_outlined,
            title: 'Settings',
            iconColor: Colors.grey.shade600,
            routeName: '/settings', // only if exists in main.dart
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildSettingsItem(
            context: context,
            icon: Icons.account_balance_wallet_outlined,
            title: 'Bank Info',
            iconColor: const Color(0xFF3B82F6),
            routeName: '/bank-info',
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildSettingsItem(
            context: context,
            icon: Icons.delete_outline_rounded,
            title: 'Delete Account',
            iconColor: Colors.red.shade400,
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Account'),
                  content: const Text(
                    'Are you sure you want to delete your account?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // your deletion logic
                        Navigator.pop(context);
                      },
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color iconColor,
    String? routeName,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: () {
        if (routeName != null) {
          try {
            Navigator.pushNamed(context, routeName).catchError((error) {
              _showRouteError(context);
            });
          } catch (e) {
            _showRouteError(context);
          }
        } else if (onTap != null) {
          onTap();
        }
      },
      leading: Icon(icon, color: iconColor),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  void _showRouteError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("This feature is not available yet or route is missing."),
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget _buildAppVersion() {
    return const Text(
      'App Version 15.2',
      style: TextStyle(color: Colors.grey, fontSize: 14),
    );
  }
}
