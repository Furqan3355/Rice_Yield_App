
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:rice_yield_app/core/theme/theme.dart';

// class OtpVerificationScreen extends StatelessWidget {
//   const OtpVerificationScreen({super.key, this.email = ''});

//   final String email;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
//           onPressed: () => context.pop(),
//         ),
//       ),
//       body: SafeArea(
//         child: Center(
//           child: Padding(
//             padding: const EdgeInsets.all(24),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Icon(Icons.check_circle_outline, size: 64, color: AppTheme.primaryGreen),
//                 const SizedBox(height: 12),
//                 Text(
//                   'OTP verification flow has been removed',
//                   style: Theme.of(context).textTheme.titleLarge,
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   'Please use the Forgot Password flow to reset your password via email.',
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: () => context.go('/forgot-password'),
//                   child: const Text('Open Forgot Password'),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

