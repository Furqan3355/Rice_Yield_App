// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:rice_yield_app/features/auth/application/auth_notifier.dart';

// class ProfileScreen extends ConsumerWidget {
//   const ProfileScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final authState = ref.watch(authNotifierProvider);
//     final user = authState.user;

//     return Scaffold(
//       appBar: AppBar(title: const Text('Profile')),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             CircleAvatar(
//               radius: 50,
//               child: Text(user?.name?.substring(0, 1) ?? 'U', style: const TextStyle(fontSize: 30)),
//             ),
//             const SizedBox(height: 20),
//             Text(user?.name ?? 'User', style: const TextStyle(fontSize: 24)),
//             Text(user?.email ?? ''),
            
//             const SizedBox(height: 30),
            
//             // Settings
//             Column(
//               children: [
//                 ListTile(
//                   leading: const Icon(Icons.edit),
//                   title: const Text('Edit Profile'),
//                   onTap: () {},
//                 ),
//                 ListTile(
//                   leading: const Icon(Icons.settings),
//                   title: const Text('Settings'),
//                   onTap: () {},
//                 ),
//                 ListTile(
//                   leading: const Icon(Icons.help),
//                   title: const Text('Help & Support'),
//                   onTap: () {},
//                 ),
//               ],
//             ),
            
//             const Spacer(),
            
//             // Logout Button
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () async {
//                   await ref.read(authNotifierProvider.notifier).logout();
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.red,
//                   foregroundColor: Colors.white,
//                 ),
//                 child: const Text('Logout'),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }