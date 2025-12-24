import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../providers/app_providers.dart';
import '../../utils/app_colors.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = ref.watch(loadingProvider);
    
    // ✅ Real Reports data fetch kar rahe hain
    final reportsAsync = ref.watch(reportsProvider);
    
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Profile Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryColor,
                      Colors.blue.shade600,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: Text(
                        authState.userName?[0].toUpperCase() ?? 'U',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      authState.userName ?? 'User Name',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      authState.userEmail ?? 'user@example.com',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ✅ REAL STATS GRID
              reportsAsync.when(
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => Text('Stats error: $e'),
                data: (reports) {
                  // Real calculation
                  final totalReports = reports.length;
                  final completedReports = reports.where((r) => r.status.toLowerCase() == 'completed').length;
                  
                  // Accuracy logic (agar aapke model mein accuracy hai toh wo use karein, varna static ya calculated)
                  const accuracy = "94%"; 

                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: [
                      _buildStatItem('Total', totalReports.toString()),
                      _buildStatItem('Done', completedReports.toString()),
                      _buildStatItem('Accuracy', accuracy),
                    ],
                  );
                },
              ),

              const SizedBox(height: 32),

              // Settings Items
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    _buildSettingsItem(
                      icon: Iconsax.notification,
                      title: 'Notifications',
                      onTap: () {},
                    ),
                    _divider(),
                    _buildSettingsItem(
                      icon: Iconsax.shield_tick,
                      title: 'Privacy',
                      onTap: () {},
                    ),
                    _divider(),
                    _buildSettingsItem(
                      icon: Iconsax.message_question,
                      title: 'Help & Support',
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              // Logout Button
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : () async {
                    ref.read(loadingProvider.notifier).setLoading(true);
                    await ref.read(authNotifierProvider.notifier).logout();
                    ref.read(loadingProvider.notifier).setLoading(false);
                  },
                  icon: isLoading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Iconsax.logout),
                  label: Text(isLoading ? 'Logging out...' : 'Logout'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.red.shade50,
                    foregroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.red.shade200),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryColor),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      trailing: const Icon(Iconsax.arrow_right_3, size: 18),
      onTap: onTap,
    );
  }

  Widget _divider() => Divider(height: 1, color: Colors.grey.shade100, indent: 16, endIndent: 16);
}